# 附录 D 从零写一个插件：端到端练习

> 这是全书唯一的"抄代码"附录，目的是让你**亲手跑通一个插件**。我们做一个最简单的工具：统计一个文件的行数。本附录基于 DSH 0.2.1-alpha.2（相对上一版基准 0.1.7-rc.2，插件 API 本身没有变化，变的是版本范围、`dsh plugin` 的参数位置和子路径插件的展示元数据），走两条路：路线 A 在源码仓库里用 `--patch` 临时挂载，最快看到效果；路线 B 把它打包成一个可安装的 **bundle**，用 `dsh plugin` 或 Web 插件页装进 profile。做完之后，再去读 `packages/fs/tool-fs/src/read.ts` 这样的生产级工具，会发现结构几乎一样。

## D.1 我们要做什么

目标：写一个工具 `count_lines`，模型可以调用它统计文件的行数。注册一个工具，模型就能在工具列表里看到它的名字、说明和参数 schema，并在需要时自己调用（第 8 章）。

```mermaid
flowchart LR
    A[你的插件 apply] -->|ctx.tools.register| B[工具注册表]
    B -->|名称、说明、参数 schema| C[模型请求中的工具列表]
    C --> D[模型决定调用 count_lines]
    D --> E[tools/pre-execute 策略判断]
    E -->|allow| F[你的 execute]
    F --> G[output.render 生成模型可见内容]
    G --> H[会话日志 tool/result]
```

## D.2 准备

- 一个完成了第 2 章"从源码运行"的 deepseek-harness 仓库，以下命令都在仓库根目录的 Windows PowerShell 里执行；
- 构建过一次：`corepack pnpm run build`（Web 运行器需要构建产物）。

## D.3 路线 A：一个文件 + 一个补丁，最快跑通

### 写工具：scratch\count-lines.ts

在仓库根目录新建 `scratch\count-lines.ts`：

```ts
import { readFile } from 'node:fs/promises'
import type { Context } from '@deepseek-ai/cordis'
import { defineTool } from '@deepseek-ai/dsh-tools'

export const name = 'count-lines'
export const inject = ['tools']

export function apply(ctx: Context) {
  ctx.tools.register(defineTool({
    name: 'count_lines',
    description: '统计一个 UTF-8 文本文件的行数。',
    parameters: {
      file_path: { type: 'string', required: true, description: '要统计的文件的绝对路径' },
    },
    output: {
      schema: {
        type: 'object',
        additionalProperties: false,
        properties: {
          path: { type: 'string', required: true },
          lines: { type: 'integer', required: true },
        },
      },
      render: (_args, value) => [{ type: 'text', text: `文件 ${value.path} 共 ${value.lines} 行` }],
    },
    async execute(args, exec) {
      const content = await readFile(args.file_path, { encoding: 'utf8', signal: exec.signal })
      const lines = content === '' ? 0 : content.split(/\r?\n/).length - (content.endsWith('\n') ? 1 : 0)
      return { path: args.file_path, lines }
    },
  }))
}
```

五个必须回答的"为什么"：

1. **`inject: ['tools']`**：声明依赖。Cordis 等 `ctx.tools` 就绪后才运行 `apply`；如果工具注册表后来消失，你的插件会跟着卸载；
2. **`parameters` 用对象映射**：`defineTool` 从它推导 `args` 的类型并做校验，`required: true` 的字段才保证存在；
3. **`output.schema` 声明规范值（canonical value）**：`execute` 返回的就是这个结构。对象 schema 写 `additionalProperties: false`，每个必有属性写 `required: true`；
4. **`output.render` 是纯函数**：它把规范值转成模型可见的内容块。不要在里面做 I/O——规范值本身不进持久化日志，进日志的是渲染结果；
5. **`exec.signal`**：用户停止或整轮被取消时，它会被触发。不把它传给 `readFile` 之类的异步操作，取消后工作还在跑（第 7 章）。

`register` 的返回值就是注销函数，而且注册本身已经挂在插件的生命周期上：插件卸载时工具自动注销，不需要自己写清理逻辑（第 3 章）。

### 挂载：scratch\count-lines.yml

先查看仓库的绝对路径：

```powershell
(Get-Location).Path
```

然后新建 `scratch\count-lines.yml`，用 `insert` 把插件插入配置。路径写**绝对路径**、用正斜杠（把下面的前缀换成你的实际路径）：

```yaml
- insert:
    - id: count-lines
      name: 'D:/code/deepseek-harness/scratch/count-lines.ts'
```

启动 Web 界面并带上这个补丁：

```powershell
corepack pnpm dsh web --patch .\scratch\count-lines.yml
```

打开 `http://127.0.0.1:3080`，新建一个会话，输入：`用 count_lines 工具统计 D:/code/deepseek-harness/README.md 有几行`。模型会调用 `count_lines`；如果当前权限模式要求确认，界面会弹出审批，允许即可。

> 源码运行时，入口通过 `node --import tsx/esm` 启动，所以 `.ts` 文件可以直接加载。这条路线只适合开发：补丁是临时的，关掉进程就没了。

## D.4 路线 B：打包成可安装的 bundle

真正分发给别人的插件是一个 npm 包，并在 `package.json` 里声明自己是 **bundle**：安装进 profile 后，它的补丁文件会成为 profile 的一个配置层（第 4 章）。

### 目录结构

```text
count-lines/
├── package.json        # 声明 dsh.bundle，以及展示元数据
├── cordis.patch.yml    # bundle 的配置层：插入插件行
├── index.js            # 插件入口
├── icon.svg            # 可选：插件页显示的图标
└── locale/
    ├── en.json         # 本地化的标题与说明
    └── zh.json
```

入口写成 `index.js`，是因为安装后的包由正式运行时加载，不经过源码模式的 tsx；如果你用 TypeScript 写，就像仓库里的包一样先构建出 `lib/`，把 `main` 指向构建产物（从 git 地址安装时还需要 `prepare` 脚本，见 D.8）。

### package.json

```json
{
  "name": "dsh-count-lines",
  "version": "0.1.0",
  "description": "Count lines in a UTF-8 text file",
  "icon": "./icon.svg",
  "type": "module",
  "main": "index.js",
  "exports": {
    ".": "./index.js",
    "./locale/*.json": "./locale/*.json",
    "./package.json": "./package.json"
  },
  "files": ["index.js", "cordis.patch.yml", "icon.svg", "locale/*.json"],
  "engines": {
    "dsh": ">=0.2.1-alpha.2"
  },
  "peerDependencies": {
    "@deepseek-ai/cordis": "^4.0.5-alpha.1",
    "@deepseek-ai/dsh-tools": "^0.2.1-alpha.2"
  },
  "devDependencies": {
    "@deepseek-ai/cordis": "^4.0.5-alpha.1",
    "@deepseek-ai/dsh-tools": "^0.2.1-alpha.2"
  },
  "dsh": {
    "manifestVersion": 1,
    "bundle": {
      "patch": "./cordis.patch.yml"
    }
  }
}
```

逐项说明（类型定义见 `@deepseek-ai/dsh-package-manifest` 的 `DshPackageManifest` / `DshManifest`）：

- **`dsh.bundle.patch`**：必需。它让这个包成为 bundle；也可以写成有序数组，多个文件按顺序合成一层，每个文件里的相对插件路径相对该文件解析。没有这个声明的包，`dsh plugin add` 仍会把它装成普通依赖，但只打印警告、不激活任何层；Web 插件页的引导式安装则会在安装前直接拒绝它；
- **`peerDependencies`**：需要与宿主**共享同一实例**的 DSH 包放在这里（`@deepseek-ai/cordis`、`@deepseek-ai/dsh-tools`）。运行时解析会让这些 peer 使用正在运行的 dsh 安装里的那一份；同样的包再写进 `devDependencies`，供你的类型检查和单元测试使用——仓库里的包都这么做；
- **兼容性**：真正生效的检查是 `@deepseek-ai/dsh` 与 `@deepseek-ai/dsh-*` 形式的 peer 范围对比运行时版本（`packages/boot/app-boot/src/plugin-compatibility.ts`，用 `includePrerelease` 匹配，所以预发布版本参与范围匹配）。它在两个时刻生效：**安装前**——`add` 一个本地路径或 registry 包时，插件管理器先读出它声明的 peer，不兼容就在 pnpm 运行前拒绝（git 地址和 tarball 要先取回，所以装完再判、不兼容就还原）；**启动时**——不匹配的 bundle 会被跳过（stderr 打印一次 `skipping profile bundle ...` 并附上不兼容的 peer），它的配置层不生效。两处都可以被 profile 的 `compatibility.json` 里"精确包版本 + 精确 dsh 版本"的豁免放行；
- **0.x 的脱字符陷阱**：semver 里 `^0.1.7-rc.2` 的意思是 `>=0.1.7-rc.2 <0.2.0`，所以上一版写法在 0.2.1-alpha.2 上**会被判为不兼容**。DSH 仍处于 0.x，`^0.2.1-alpha.2` 也只覆盖到 `<0.3.0`——跨 minor 升级时记得更新 peer 范围；`@deepseek-ai/cordis` 不在 `dsh-*` 名字空间里，不参与这项检查，但仍应与运行时一致；
- **`engines.dsh` 与 `dsh.manifestVersion`**：都是可选的声明性字段，当前安装器和加载器**不强制检查**，写上是为了让读者和未来的工具知道你面向哪个版本、用哪版声明格式；
- **`icon` 与 `./package.json` 导出**：插件页不激活插件，直接读取包的 `package.json` 和 `locale/*.json` 来展示图标、标题和说明，所以要把它们导出并放进 `files`。图标支持 SVG、PNG、JPEG、WebP，最大 256 KiB，且必须位于包内；包根插件不写 `icon` 时，也可以导出一个 `./icon` 资源代替。

### locale\zh.json 与 locale\en.json

```json
{
  "meta": {
    "title": "行数统计",
    "description": "提供 count_lines 工具，统计文本文件的行数。"
  }
}
```

```json
{
  "meta": {
    "title": "Line Counter",
    "description": "Adds a count_lines tool that counts lines in a text file."
  }
}
```

Host 以 `locale/en.json` 为锚点发现同目录下的其他语言文件，界面按当前语言选择 `meta.title` / `meta.description`。两个字段各自独立回落：标题回落到 `package.json` 的 `name`，再回落到配置里的插件名；说明回落到 `package.json` 的 `description`。字段存在但不合法（比如空字符串）会报诊断，而不是悄悄回落。路线 A 那种文件路径形式的插件不查找任何本地化资源，只显示配置的路径。

**一个包里放多个插件（子路径插件）时**，规则不同（0.2.1-alpha.1 起，升级指南 `v0.2.0-rc.2/subpath-plugin-display-manifest`）：子路径不是包，插件页**永远不会**为它读取 `package.json`。假设配置行写的是 `name: dsh-count-lines/words`，那么标题和说明只来自 `dsh-count-lines/words/locale/*.json`，图标只来自导出的 `dsh-count-lines/words/icon`：

```json
{
  "exports": {
    "./words": "./words.js",
    "./words/locale/*.json": "./locale/words/*.json",
    "./words/icon": "./assets/words.svg"
  },
  "files": ["words.js", "locale/words/*.json", "assets/words.svg"]
}
```

以前那种为子路径导出一份 `./words/package.json` 的写法已经不再被读取。改完后打开插件页确认这一行的标题、说明和图标；如果包是 DSH 仓库里的 workspace 包，也可以跑 `corepack pnpm run verify-package-meta`。

### cordis.patch.yml

```yaml
- insert:
    - id: count-lines
      name: dsh-count-lines
```

注意 `name` 写的是**包名**，由 Node 解析从 profile 里找到已安装的代码，而不是路线 A 里的文件路径。

### index.js

逻辑和路线 A 相同，只是去掉了类型标注：

```js
import { readFile } from 'node:fs/promises'
import { defineTool } from '@deepseek-ai/dsh-tools'

export const name = 'count-lines'
export const inject = ['tools']

export function apply(ctx) {
  ctx.tools.register(defineTool({
    name: 'count_lines',
    description: '统计一个 UTF-8 文本文件的行数。',
    parameters: {
      file_path: { type: 'string', required: true, description: '要统计的文件的绝对路径' },
    },
    output: {
      schema: {
        type: 'object',
        additionalProperties: false,
        properties: {
          path: { type: 'string', required: true },
          lines: { type: 'integer', required: true },
        },
      },
      render: (_args, value) => [{ type: 'text', text: `文件 ${value.path} 共 ${value.lines} 行` }],
    },
    async execute(args, exec) {
      const content = await readFile(args.file_path, { encoding: 'utf8', signal: exec.signal })
      const lines = content === '' ? 0 : content.split(/\r?\n/).length - (content.endsWith('\n') ? 1 : 0)
      return { path: args.file_path, lines }
    },
  }))
}
```

## D.5 安装进 profile

### 用命令行

`dsh plugin --profile <名称> <pnpm 参数...>` 在 profile 目录里转发给 pnpm，所以所有 pnpm 动词都能用。在 `count-lines` 目录的上一级执行（源码运行时写成 `corepack pnpm dsh ...`，并在仓库根目录执行、使用相对仓库根目录的路径）：

```powershell
corepack pnpm dsh plugin --profile demo add .\count-lines
```

注意 `--profile demo` 必须写在 `add` **之前**：0.2.1-alpha.1 起，`dsh plugin` 只在转发给 pnpm 的参数之前识别 `--profile`，写成 `dsh plugin add .\count-lines --profile demo` 会失败并提示 `required option '--profile <name>' not specified`。`corepack pnpm dsh plugin --help` 打印的是 `dsh plugin` 自己的帮助；想看 pnpm 的 `add` 帮助，写 `dsh plugin --profile demo add --help`。

第一次使用会初始化 `demo` profile（第一个 bundle 是 `@deepseek-ai/dsh-base`）；pnpm 链接这个目录；因为包声明了 `dsh.bundle`，dsh 把 `dsh-count-lines` 追加到 profile 的 `dsh.profile.bundles` 列表末尾。

不启动就能验证层是否生效：

```powershell
corepack pnpm dsh demo --dump-config | Select-String "dsh-count-lines" -Context 0,3
```

输出里应该有一段以 `# == dsh-count-lines` 开头的层注释和你的 `insert` 行。然后启动：

```powershell
corepack pnpm dsh demo
```

`dsh demo` 是 `dsh --profile demo` 的简写。卸载用 `corepack pnpm dsh plugin --profile demo remove dsh-count-lines`，依赖和配置层会一起移除。

### 用 Web 插件页

在 Web 界面的插件页点"安装"，输入包名、tarball、git 地址或本地目录的**绝对路径**，引导式安装会：

1. **先检查再安装**：Host 读取包名、版本、说明和 bundle 声明；没有 bundle 补丁的包在 pnpm 运行前就被拒绝，拼写错误、已安装、路径不存在、仓库不可达等问题各自显示为一句说明；
2. **失败即还原**：安装前快照 profile 的 `package.json` 和 `pnpm-lock.yaml`，pnpm 失败、被取消或装上的包没有 bundle 补丁时恢复原样；
3. **装完再启用**：安装时不启用，完成页提供"立即启用"；
4. **脚本审批**：pnpm 拦下的依赖安装脚本会在失败页列出，确认后可以"允许这些脚本并重试"。

插件页从 npm 仓库安装时，使用插件管理器插件（`@deepseek-ai/dsh-plugin-manager`）配置里的 `registry` 与 `fallbackRegistries`（默认备用源是 `https://registry.npmmirror.com/`）；配置了私有仓库时，不会回落到公共源。命令行安装则直接给 pnpm 传 `--registry`（`dsh plugin --profile demo add --registry <源地址> dsh-count-lines`）。

在 Web profile（带 HMR）里装好并启用之后，插件管理器会为 profile 发布新的一代运行时解析表（第 4 章 4.8 节），你的 bundle 的私有依赖和包名立刻可解析，不需要重启；但**覆盖一个已安装的版本**（例如重新安装改过的 `count-lines`）会报告 `restart-required`，需要重启进程才能加载新代码。

插件页的"官方"分组里还会看到两类不需要你自己打包的 bundle：随安装附带的可选 bundle（只需打开开关）和按需安装的 Claude Code / Codex 集成（第 4 章 4.5 节）。它们走的是和你的 `dsh-count-lines` 同一个安装器——这也说明，一个第三方 bundle 只要按本附录的格式写好，就和官方 bundle 处在同一条通路上。

## D.6 成功标准（怎么确认做对了）

按顺序检查，任何一步失败都能定位原因：

| # | 检查 | 成功标准 | 失败时看哪里 |
| --- | --- | --- | --- |
| 1 | 行已进入配置 | `--dump-config` 输出里能找到 `id: count-lines` | 补丁的缩进、`insert` 结构；路线 B 看 `dsh.profile.bundles` 是否包含包名、stderr 有没有 `skipping profile bundle` |
| 2 | 插件已激活 | 启动时 stderr 没有提到 `count-lines` 的 `did not activate` 警告 | 警告里写明是失败还是在等待哪个服务；路线 A 查绝对路径，路线 B 查 `main`/`exports`，两者都查 `inject` 的服务名 |
| 3 | 模型看到工具 | 在对话里问"你有哪些工具"，列表中有 `count_lines` | `defineTool` 的 `name`、`description`、`parameters` |
| 4 | 工具被调用且结果正确 | 界面出现 `count_lines` 调用卡片，结果与 `(Get-Content 文件).Count` 一致 | `execute` 的实现；prompt 是否明确要求使用该工具 |
| 5 | 取消生效 | 统计大文件时点停止，调用以取消结束，进程不残留工作 | `exec.signal` 是否传给了 `readFile` |

> `(Get-Content 文件).Count` 对"末尾有换行"的文件与我们的算法一致；对空文件返回 0。

## D.7 进阶：同一插件里再加几件事

工具只是插件的一种形态。同一个 `apply` 里还可以：

- **加系统提示段**，告诉模型什么时候该用你的工具。需要把 `systemPrompt` 加进 `inject`：

```ts
export const inject = ['tools', 'systemPrompt']

export function apply(ctx: Context) {
  // ...注册工具...
  ctx.systemPrompt.section({
    name: 'tool:count-lines',
    order: 100,
    text: '统计文件行数时使用 count_lines 工具，不要用 shell 命令。',
  })
}
```

`section` 返回一个注销函数，并同样随插件卸载自动移除。

- **观察工具结果**。只想看、不想改，就监听 emit 事件 `tools/result`，而不是 waterfall 的 `tools/post-execute`（后者用来替换或拦截结果）：

```ts
ctx.on('tools/result', (exec, result) => {
  if (exec.name !== 'count_lines') return
  ctx.logger.info('count_lines %s', result.isError ? '失败' : '成功')
})
```

- **做策略**。想在执行前拒绝某些路径，监听 `tools/pre-execute` 并返回 `{ kind: 'deny', reason }`，其余情况 `return next()`（第 5 章）。

- **接入文件系统抽象**。本例直接用 `node:fs`，绕过了 DSH 的文件系统服务。生产级的 `tool-fs` 注入 `fs` 服务，通过 `ctx.fs.readText(target, exec.signal)` 读取，这样沙箱、工作区边界和文件观察策略都会生效（第 8、10 章）。正式发布的工具应该这样做。

- **加配置**。导出 Schemastery 的 `Config`，在补丁行的 `config` 里传值，Cordis 会校验并填默认值（第 3 章）。

## D.8 发布：让别人也能装你的插件

完整流程见第 14 章。要点：

- **发布到 npm**：在发布时构建好产物，用户执行 `dsh plugin --profile <名称> add dsh-count-lines`；
- **分发 tarball**：`pnpm pack` 生成 `.tgz`，用户 `add .\dsh-count-lines-0.1.0.tgz`；
- **从 git 安装**：拿到的是源码而不是构建产物。作者要提供自包含的 `prepare` 脚本；pnpm 默认不运行 git 依赖的构建脚本，用户需要在 profile 的 `pnpm-workspace.yaml` 里用 `allowBuilds` 放行该包。这等于允许它在安装时在你的机器上执行代码，而且不在任何 agent 沙箱之内——只放行你信任的源码，并固定到某个提交。

如果你把插件做成仓库里的一个 workspace 包（放到 `packages/<分组>/<名称>`），提交前还要过仓库的检查：`corepack pnpm hygiene`、`corepack pnpm verify-package-meta`、`corepack pnpm constraints`。

## D.9 常见错误速查

- **补丁里的 `id` 写错**：用 `id` 定位的补丁在找不到目标行时只打印警告、跳过该补丁，不会让启动失败——所以"改了没效果"时先查 `--dump-config`；
- **空的补丁文件**：只有注释或完全为空的补丁文件会让启动失败；想表示"什么都不改"，写 `[]`；
- **`inject` 写错服务名**：依赖永远不就绪，插件停在 PENDING 状态，`apply` 不会运行（第 3 章）。启动审计会在 stderr 打印 `warning: ... did not activate`，并注明 `pending (waiting for service: ...)`，缺的服务名就写在那里；
- **路线 A 用了相对路径或反斜杠**：路径解析不到时，加载器记录解析失败并继续启动，你的工具就是"没出现"；
- **路线 B 的 `name` 写成文件路径**：bundle 补丁里要写包名，让 Node 从 profile 里解析；
- **包没有 `dsh.bundle`**：命令行安装后只有警告、没有配置层；Web 插件页直接拒绝安装；
- **peer 范围不覆盖当前 dsh 版本**：安装时被拒绝，或启动时打印 `skipping profile bundle "dsh-count-lines": ...`，整个 bundle 层被跳过；更新 peer 范围（注意 0.x 下 `^0.1.x` 不覆盖 `0.2.x`），或按提示在 `compatibility.json` 里登记精确版本豁免；
- **`--profile` 写在了 pnpm 命令之后**：`dsh plugin add <包> --profile demo` 会报 `required option '--profile <name>' not specified`，改成 `dsh plugin --profile demo add <包>`；
- **子路径插件导出了 `package.json` 当展示清单**：0.2.1-alpha.1 起不再读取，标题和说明改放 `<子路径>/locale/*.json`，图标改为导出 `<子路径>/icon`；
- **`parameters` 少了 `required: true`**：模型可能不传这个参数，`execute` 里拿到 `undefined`；
- **`render` 里读文件**：render 必须是纯函数，只根据参数和规范值生成内容；
- **忘了 `exec.signal`**：取消后读取还在进行，留下悬空的工作。

做完这个练习，你已经走完了 DSH 插件开发的闭环：写代码 → 挂载 → 验证 → 打包安装 → 发布。现在打开 `packages/fs/tool-fs/src/read.ts`，你会看到同样的 `defineTool` 结构，外加分块读取、截断、展示元数据和并发安全声明这些生产级细节。

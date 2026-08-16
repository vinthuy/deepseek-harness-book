# 第 8 章 工具与 Capability Seam：模型与真实世界之间的那道闸门

> 前两章看了循环怎么转、事件怎么流。这一章回答一个更具体的问题：**模型说"我要读文件"，这句话是怎么变成真实世界的文件读取的？** 答案是一个统一管线（`ctx.tools`）+ 一组可替换的"能力接缝"。

## 8.1 工具是什么：模型面与系统面

对模型来说，工具是"一个可以调用的函数"：有名字、描述、参数 schema、返回值。但对 DSH 来说，工具不只是函数——它是**模型与真实世界之间的闸门**：所有工具调用都经过 `ctx.tools` 的统一管线，做四件事：

1. **参数校验**：模型生成的 arguments 是 JSON 字符串，必须先按 schema 校验，非法直接拒绝——模型会幻觉出各种离谱参数；
2. **执行**：真正调用底层能力（文件系统、shell、网络）；
3. **结果规范化**：把返回值变成规范 JSON，供模型消费；
4. **UI 呈现**：把结果渲染成用户能看的卡片（diff、终端、表格）。

还有一条隐性的第五条：**工具的 schema 会自动汇入 system prompt 组装**（`ctx.systemPrompt`）——所以"注册一个工具 = 模型自动知道怎么用它"，不需要手工把工具说明写进 prompt。

## 8.2 一个工具的最小形态：代码在回答什么

```ts
ctx.tools.register(defineTool({
  name: 'read_file',
  description: '读取一个文件的内容。',
  parameters: {
    path: { type: 'string', required: true, description: '文件的绝对路径' },
    limit: { type: 'number' } // 可选参数
  },
  output: {
    schema: { type: 'string' },
    render: (_args, value) => [{ type: 'text', text: value }],
  },
  async execute(args, exec) {
    // args 已被 schema 校验过，类型是 { path: string; limit?: number }
    return readFile(args.path, { encoding: 'utf8', signal: exec.signal })
  },
}))
```

这段骨架里的每个字段，都在回答一个"为什么"：

1. **参数自动校验**：模型生成的 `arguments` 先按 schema 校验，`execute` 里拿到的 `args` 是类型安全的——**边界在门口，不在屋里**；
2. **返回值必须是规范 JSON 值**，而不是 prose：模型解析 prose 费劲，UI 也无从渲染。`output.render` 负责把值转成模型可读文本——**值和呈现分离**；
3. **必须遵守 `exec.signal`**：取消时停止在途工作——这是取消契约（第 7 章），不响应会留下僵尸任务；
4. **注册即 effect**：插件卸载，工具自动注销（第 3 章的可逆副作用在这里兑现）；
5. **不要直接改 schema**：注册借用的是只读定义，热替换用"注销旧 effect + 注册新工具"。

## 8.3 工具的执行契约：异常、快照、身份

- **抛出异常 = isError**：`execute` 抛错会被捕获并标记失败，模型看到结构化错误而不是裸异常——**错误也是数据**；
- **输出快照与冻结**：参数和结果会被做无损 JSON 快照并冻结，防止执行中篡改——审计需要"当时到底是什么"；
- **身份保护**：`exec.token`、`callId`、`agent` 在执行期间不可变；
- **后台运行**：长任务用 `ctx.jobs.start(...)` 注册，工具立刻返回，模型用 `job_output`/`job_list`/`job_kill` 轮询/停止（第 13 章）。

### 设计思考：为什么"返回值必须结构化"？

早期 Agent demo 常见一个坏习惯：工具返回一大段人类可读文本（"文件读取成功，内容如下：……"），让模型自己去解析。这等于把"解析逻辑"外包给模型的幻觉。DSH 的纪律是：**工具返回数据，render 负责说话**——模型拿到的是干净的 JSON 值，UI 拿到的是可渲染的卡片，两者互不污染。这个分离让"模型面"和"UI 面"可以独立演化。

## 8.4 Capability Seam：服务定义 / Provider / Consumer

工具只是"模型可见的消费者"。DSH 更一般的抽象是**能力接缝（Seam）**，每个接缝有三个角色：

1. **Service Definition（服务定义）**：声明接口（如 `ctx.fs` 有哪些方法）；
2. **Service Provider（服务提供者）**：实现接口（本地实现 or 远程沙箱实现）；
3. **Consumer（消费者）**：使用接口的一方，通常是模型工具（如 `tool-fs`）。

以 `ctx.fs`（文件系统）接缝为例：

| 角色 | 包 |
| --- | --- |
| 定义 | `dsh-fs` |
| 本地 Provider | `dsh-fs-local` |
| 远程 Provider（E2B 沙箱 POC） | `dsh-e2b` 里的 fs adapter |
| 消费者（工具） | `dsh-tool-fs` |

### 设计思考：接缝 = 依赖倒置的极致

"面向接口编程"大家都会说，但接缝把它做到了极端：**换 Provider 换整个产品**。本地 fs + 本地 bash + 本地 PTY + 本地 LSP 共享一个执行世界；把它们都指到 E2B 沙箱，就变成"全部在远程沙箱里跑"——而工具代码一行不改。

这回答了第 1 章的问题："一切皆插件"为什么值钱？因为**执行环境**（本地/远程/沙箱）和**产品功能**（工具、UI、循环）被解耦了。你可以先在本地产出功能，再决定把它部署到什么环境——这个决定可以推迟到配置层。

## 8.5 常用接缝速查

| ctx 键 | 能力 | 内置 Provider |
| --- | --- | --- |
| `ctx.llm` | 模型 | deepseek、pi-ai、replay |
| `ctx.tools` | 工具管线 | 核心，非接缝 |
| `ctx.fs` | 文件系统 | local、e2b |
| `ctx.subprocess` | 子进程 | local |
| `ctx.shell` | shell 执行 | bash-local、pwsh |
| `ctx.terminals` | 持久终端（PTY） | local |
| `ctx.sandbox` | 进程沙箱 | sandbox-local（平台原生） |
| `ctx.web` | 搜索/抓取 | exa、perplexity、deepseek、http |
| `ctx.skills` | 技能 | skills-filesystem 等 |
| `ctx.subagents` | 子 Agent | in-process、acp、codex、claude-code、dsh-sdk |
| `ctx.credentials` | 凭据 | credentials-local（env/.env） |
| `ctx.settings` | 用户设置 | settings-file |
| `ctx.storage` | 非会话存储 | storage-json、storage-sqlite |

注意这张表的读法：**每一行都是一条"换 Provider 的选项"**。产品在左，实现在右，中间是稳定的接口。

## 8.6 动手实验：读一个真实工具

1. 打开 `packages/shell/tool-bash` 的源码（生产级参考实现），回答：
   - 它的 `defineTool` 用了什么 `output.render`？（terminal 卡片）
   - 它怎么把 argv 交给 `ctx.subprocess`/`ctx.sandbox` 的？
   - 它支持 `run_in_background` 吗？条件是什么？
2. 打开 `packages/fs/tool-fs`，看 `write`/`edit` 工具的 `presentCall`/`presentResult`（diff 卡片）；
3. 画一张图：工具 → tools 管线 → 能力接缝（fs/shell）→ Provider（local/sandbox）。

## 8.7 常见坑

- **工具返回"人类可读的 prose"而不是结构化值**：模型解析费劲，UI 也无从渲染；
- **`output.render` 里做 I/O**：render 会在直播和重放两个场景运行，必须纯函数；
- **不遵守 `exec.signal`**：取消后还在干活，会成为僵尸任务；
- **把 UI 格式化塞进模型结果**：模型看到的是规范值 + render 文本；UI 卡片是独立的呈现投影（`presentCall`/`presentResult`），别混在一起。

## 8.8 思考题

1. 接缝让"换 Provider"变成一行配置。但 Provider 的接口（比如 `ctx.fs` 的方法集）是谁定的？如果两个 Provider 的能力有差异（本地能 chmod，远程沙箱不能），接口怎么处理这种差异？（提示：能力探测 vs 降级）
2. "工具返回数据，render 负责说话"。如果某个工具的结果特别大（比如整个仓库的 grep 输出），谁负责截断？这个决定应该放在工具里还是管线里？
3. 想一想：如果 DSH 没有接缝，而是让工具直接 import 本地 fs 实现，第 10 章的沙箱还能工作吗？接缝和沙箱是什么关系？

## 小结

- 工具 = 模型与世界的闸门：参数校验、执行、结果规范化、UI 呈现，schema 自动进 prompt；
- 接缝三角：定义 / Provider / Consumer——换 Provider 换产品行为，执行环境与产品功能解耦；
- `output.render` 面向模型，`present*` 面向 UI，值与呈现分离；
- 生产级参考：`tool-bash`（terminal 卡片）、`tool-fs`（diff 卡片）。

下一章：把模型接进来——ctx.llm 与凭据，以及"密钥绝不进配置"这条纪律。
# 附录 B 命令速查

所有命令默认在 `deepseek-harness` 仓库根目录执行，基准为 `0.2.1-alpha.2`；本机没有全局 pnpm 时统一用 `corepack pnpm`。根 `package.json` 里的脚本是唯一真源——本附录只收常用的那部分，完整清单请直接看 `package.json` 的 `scripts` 与 `scripts/run-gates.ts`；`dsh` 各命令的完整帮助生成在 `docs/cli-help.md`。

> Windows 注意：少数脚本采用 POSIX 写法 `VAR=value 命令`（如 `test:snapshot:record`、`test:snapshot:refresh`、`test:expected:refresh`、`test:web:refresh`、`test:web:perf:built`），在 Windows 的 cmd 下无法直接运行。可以先在 PowerShell 里设置环境变量，再直接调用 vitest，例如：
>
> ```powershell
> $env:DSH_SNAPSHOT = 'record'; corepack pnpm exec vitest run --config vitest.snapshot.config.ts --update
> ```

## 环境与安装

```powershell
corepack pnpm --version              # 验证 corepack 可用（首次自动下载 pnpm 11.28.5）
git clone --depth 1 https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
corepack pnpm install                # 安装依赖；postinstall 安装 lefthook 钩子
corepack pnpm run build              # 完整构建：build:native-system → build:lib → build:web
```

`build` 依赖 Node 的 TypeScript 类型剥离（tsdown 以 `--config-loader native` 加载配置）；`NODE_OPTIONS` 里不要带 `--no-experimental-strip-types`。

## 运行（`dsh` 启动器）

根脚本 `dsh` = `node --import tsx/esm apps/cli/src/bin.ts`，它使用已有构建产物，不会自动构建。

```powershell
corepack pnpm dsh web                                   # 启动 Web UI（127.0.0.1:3080，本机自动开浏览器）
corepack pnpm dsh web --no-open                         # 只起服务，不开浏览器
corepack pnpm dsh web --port 3081                       # 换端口（0 = 由系统挑选）
corepack pnpm dsh web --host 10.0.0.7                   # 绑定一个具体的本机地址（通配地址被拒绝）
corepack pnpm dsh web --public-url https://app.example/ui/ --trusted-host app.example   # 反向代理之后：公告地址 + 信任 authority
corepack pnpm dsh web --tls-cert .\server-chain.pem --tls-key .\server-key.pem         # 监听器直接提供 HTTPS
corepack pnpm dsh web --help                            # web 应用自己的帮助
corepack pnpm dsh --help                                # 启动器自己的帮助
corepack pnpm dsh --version                             # 版本号
corepack pnpm dsh headless "任务描述"                    # 一次性任务：答案到 stdout，推理到 stderr
corepack pnpm dsh headless --json "任务描述"             # stdout 改为按行 JSON 事件流
corepack pnpm dsh headless --session-id <id> "继续"      # 在已持久化的会话上继续
corepack pnpm dsh --profile sdk                         # stdio 上的 SDK JSON-RPC 服务
corepack pnpm dsh --profile acp                         # stdio 上的 ACP 服务
corepack pnpm dsh web --patch .\my-patch.yml            # 带额外补丁层启动（可重复）
corepack pnpm dsh rescue --from-default-profile web     # 从 web 模板创建新 profile 并启动
npx @deepseek-ai/dsh web                                # 快速体验（不克隆源码）
```

`web` 的全部应用参数：`--host`、`--port`、`--public-url`、可重复的 `--trusted-host`、`--tls-cert`/`--tls-key`（必须成对）、`--no-open`。`headless` 的应用参数：任务文本（省略或 `-` 时读 stdin）、`--json`、`--session-id`。`sdk`、`sdk-minimal`、`acp` 没有应用参数。

随附 profile 模板：`web`、`headless`、`sdk`、`sdk-minimal`、`acp`（首次使用自动初始化）。`desktop` 是桌面应用保留名，npm/源码版 CLI 拒绝操作它；只有桌面端自带的 `dsh` 命令能管理已初始化的 desktop profile 的插件。

## 查看配置

三种 dump 互斥，且都不接受应用参数：

```powershell
corepack pnpm dsh web --dump-default-config     # 只看组合包各层
corepack pnpm dsh web --dump-config             # + profile 层 + home 层 + --patch，带来源注释
corepack pnpm dsh web --dump-config-schema      # 输出配置条目与 patch 的 JSON Schema（不挂载插件）
```

## 插件管理（`dsh plugin`）

在 profile 目录里把参数原样转发给 pnpm；profile 不存在时先初始化。`--profile <name>` 必须写在被转发参数之前。组合包成员变化后需要重启该 profile。

```powershell
corepack pnpm dsh plugin --profile web add <package-or-git-spec>
corepack pnpm dsh plugin --profile web remove <package>
corepack pnpm dsh plugin --profile web why <package>
corepack pnpm dsh plugin --profile web add @deepseek-ai/dsh-subagent-codex      # 可选子 Agent 提供方
corepack pnpm dsh plugin --profile web add @deepseek-ai/dsh-hooks-claude-code @deepseek-ai/dsh-hook-protocol   # 实验性 hook 桥接（peer 需一并安装）
corepack pnpm dsh plugin --profile web add @deepseek-ai/dsh-webhook @deepseek-ai/dsh-webhook-github            # 实验性 GitHub webhook 适配器
corepack pnpm dsh plugin --profile tui add github:deepseek-harness/turtle-ui    # 外部终端界面插件示例
dsh plugin --profile desktop add <package>                                        # 仅限桌面端注册的 dsh 命令，且需先退出桌面端
```

profile 关闭了自动安装 peer，所以实验性包的 peer 依赖要写在同一条命令里；安装一个包并不会自动把它挂进配置树，参见升级指南 `experimental-package-composition`。

## 验证与排查

```powershell
curl.exe -s -o NUL -w '%{http_code}' http://127.0.0.1:3080/   # 401 = 服务在监听、令牌认证在工作；403 = Host 不在信任围栏内
Get-NetTCPConnection -LocalPort 3080                           # 谁在监听 3080（桌面端默认由系统分配端口）
Stop-Process -Id <pid>                                         # 停止服务
Get-Content ~\.dsh\profiles\web\cordis.patch.yml               # 看 web profile 的用户补丁层
Get-Content ~\.dsh\profiles\web\package.json                   # 看 profile manifest（dsh.profile.bundles）
Get-ChildItem ~\.dsh\logs                                      # 启动失败诊断：startup-<时间戳>-<uuid>.log
```

## 测试与质量

```powershell
corepack pnpm run test                  # 先 build:native-system，再 vitest 单元测试
corepack pnpm run test:coverage         # 覆盖率门禁（packages/*/*/src 按文件 100%）
corepack pnpm run test:e2e              # 真实 API 测试（缺密钥的套件自动跳过）
corepack pnpm run test:expected         # 无密钥的 CLI/进程预期输出（针对构建产物）
corepack pnpm run test:snapshot         # 无密钥快照回放
corepack pnpm run test:web              # 构建后跑 Web 浏览器快照（Chromium/WebKit）
corepack pnpm run test:bench            # 性能基准（先构建）
corepack pnpm run test:bench:memory     # 内存压力基准（scripts/run-memory-pressure-bench.ts）
corepack pnpm run typecheck             # 先 build:lib:host，再 tsc -b tsconfig.client.json
corepack pnpm run lint                  # 先 build:lib:host，再 oxlint（scripts/run-oxlint.ts）
corepack pnpm run lint:fix              # oxlint 自动修复
corepack pnpm run hygiene               # 包卫生门禁：publint、workspace 约束、包依赖/入口/许可证等
corepack pnpm run doc-sync              # 文档同步门禁（文档改动用它）
corepack pnpm run test:docs             # 文档快速检查
corepack pnpm run verify-cli-help       # 检查 docs/cli-help.md 是否与当前 CLI 一致（gen-cli-help 重新生成）
corepack pnpm run verify-upgrade-guides # 检查 docs/upgrade-guide 的目录布局、元数据、章节与字数上限
corepack pnpm run check:all             # 全面本地门禁集（可选，耗时长）
corepack pnpm run change-scope          # 报告当前改动的已提交/工作区范围
```

需要重新录制快照时（Windows 写法见本附录开头）：`test:snapshot:record`（模型 transcript 变化时）、`test:snapshot:refresh`（回放输入仍有效时）。

> 已移除：上一版存在的 `verify-package-invariants`、`verify-built-package-invariants`（随运行时不变式一起删除）与 `gen-scoped-events`/`verify-scoped-events` 脚本在 `0.2.1-alpha.2` 中已不存在。

## 开发

```powershell
corepack pnpm run build:lib             # 只构建库（host + client；改 Remote 签名后必跑）
corepack pnpm run build:web             # 只构建 Web 前端（= --filter @deepseek-ai/dsh-web-frontend run build）
corepack pnpm run start:web             # 用源码启动器运行已构建的 Web（等同 dsh web）
corepack pnpm run dev:web               # 构建一次、启动服务，并在源码修改时重建客户端 bundle
corepack pnpm run dev:web --no-open --port 3081   # 参数转发给 dsh web；另支持 --skip-build、--no-serve
corepack pnpm run demo:ptc -- "summarize this workspace"   # 以 DSH_TOOLS_MODE=ptc 跑一次 headless（需凭据）
corepack pnpm run demo:inspector        # web + packages/experimental/inspector/cordis.source.patch.yml
corepack pnpm run mock:llm              # 启动可编脚本的 Messages 兼容 mock LLM 服务
corepack pnpm run dev:bundle-registry   # 构建并在 loopback 上提供官方按需 bundle 的本地 registry（测试打包应用用）
corepack pnpm run clean                 # 清理构建产物与已删除包遗留的安全残留（lib、.typecheck 等）
corepack pnpm run migrate:sessions-to-v4   # 一次性贡献者命令：把会话发布为 v4 后继代际（慎用）
```

## 桌面应用

```powershell
corepack pnpm run dev:desktop                        # 构建后启动（隔离的开发 home）
corepack pnpm run start:desktop                      # 跳过构建，启动已有产物
corepack pnpm run build:desktop                      # 只构建 Electron 壳
corepack pnpm run prepare:desktop                    # 只准备打包资源（诊断用，不产出安装包）
corepack pnpm run package:desktop:dir                # 生成可直接运行的应用目录
corepack pnpm run package:desktop:win:x64:unsigned   # 未签名 Windows x64 安装包（需 DSH_DESKTOP_APP_ID）
corepack pnpm run package:desktop:win:x64            # 正式签名 Windows x64 安装包（需 EV 签名配置）
corepack pnpm run package:desktop:mac:arm64          # macOS arm64（需 Apple Silicon 与签名/公证配置）
corepack pnpm run package:desktop:mac:x64            # macOS x64
corepack pnpm run package:desktop:mac:arm64:unsigned # macOS arm64 本地构建（不签名、不公证）
corepack pnpm run package:desktop:mac:x64:unsigned   # macOS x64 本地构建（不签名、不公证）
corepack pnpm run prepare:primary-runtime            # 准备桌面端自带的第一方运行时（Python/Node/pnpm）
```

根目录 `Makefile` 用 `make web`、`make dev-web`、`make desktop`、`make dev-desktop`、`make build`、`make clean` 命名同一套命令（`make help` 列出全部 target，`ARGS='--no-open'` 转发参数）；Windows 上需要自行安装 make。

## 文档站

```powershell
corepack pnpm run docs:dev              # 本地预览文档站（website/）
corepack pnpm run docs:build            # 构建文档站
```

## 用户级目录（`~/.dsh`，可用 `DSH_HOME` 覆盖）

```text
~/.dsh/profiles/<name>/package.json        # profile manifest：dsh.profile.bundles + 树外插件依赖
~/.dsh/profiles/<name>/cordis.patch.yml    # profile 用户补丁层（设置页也写这里）
~/.dsh/profiles/desktop/                   # 桌面应用独占
~/.dsh/cordis.patch.yml                    # home 级补丁（跨 profile，优先于 profile 层）
~/.dsh/.credentials.yaml                   # 提供方凭据（设置页保存的 API Key）
~/.dsh/.env                                # home 级环境变量层
~/.dsh/sessions/                           # 会话日志
~/.dsh/storages/                           # 结构化数据
~/.dsh/logs/                               # 启动失败诊断报告
~/.dsh/cache/                              # 缓存
~/.dsh/dsh-runtimes/                       # 第一方运行时安装目录
~/.dsh/AGENTS.md                           # 用户级 Agent 指令（可选；指令加载器只从 $DSH_HOME 或 ~/.dsh 读取）
```

早期版本的 `~/.dsh/settings.yaml` 已废弃：启动时会被导入一次并改名为 `settings.yaml.imported`。桌面端自身的本地设置（如 `updates.allowTestAuthPopupWindow`）在 Electron 的 `userData` 目录下的 `desktop/settings.json`，不在 `~/.dsh` 里。

## 环境变量

| 变量 | 用途 |
| --- | --- |
| `DEEPSEEK_API_KEY` | DeepSeek API Key（`deepseek-official` 路由的默认凭据引用；搜索也用它）；缺失时该路由返回空模型目录 |
| `DEEPSEEK_BASE_URL` | 覆盖 DeepSeek Messages 根地址（默认 `https://api.deepseek.com/anthropic`） |
| `DEEPSEEK_SEARCH_BASE_URL` | 覆盖 `web_search` 使用的搜索地址 |
| `DSH_HOME` | 覆盖 Harness home（默认 `~/.dsh`；空白值视为未设置）；指令加载器也只认它 |
| `DSH_PERMISSION_MODE` | 覆盖进程级权限预设后备值（默认 `workspace-write`） |
| `DSH_TOOLS_MODE` | 工具呈现方式：`native` 或 `ptc`（`both` 已被移除，其他值启动失败） |
| `DSH_TELEMETRY_MODE` | OTel 会话上传模式；`DISABLED` 禁止投递（默认 `FEEDBACK_ONLY`，`FULL` 被拒绝） |
| `DSH_TELEMETRY_DISABLED` | 任意非空值禁用 OTel 上传配置行 |
| `DSH_TELEMETRY_OTLP_URL` | 选择 OTel 采集端 |
| `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY` / `NO_PROXY` | 出站代理；可来自继承环境或 `$DSH_HOME/.env`，**不**从调用目录的 `.env` 读取 |
| `DSH_WEB_URL` | 由 Web 应用注入到 Agent 的受管 bash 环境，指向公告的应用地址（不含凭据）；不是给用户设置的 |
| `DSH_SNAPSHOT` | 快照模式：`record` / `refresh` / `replay` |
| `DSH_DESKTOP_APP_ID` | 桌面端应用 ID（`package:desktop:win:x64:unsigned` 等打包命令要求设置） |
| `DSH_DESKTOP_USER_DATA_DIR` | 开发时隔离桌面端快捷键等 Electron 偏好的目录 |

> 已移除：`E2B_API_KEY` 随 E2B 提供方一起删除，远程执行由 `ssh` 分组（`dsh-ssh`、`dsh-fs-ssh`、`dsh-subprocess-ssh`、`dsh-sandbox-ssh`）承担；`DSH_TOOLS_MODE=both` 自 `0.2.1-alpha.1` 起被拒绝（升级指南 `tool-presentation-mode`）。

# 附录 A 术语表

按首字母排序（中文词条按拼音就近归入）。术语口径以源码 HEAD（0.1.7-rc.2）与官方 `docs/glossary.md` 为准；`docs/glossary.md` 只收录少数核心领域词（seam、scope、goal、turn/step/round、Ralph 等），这里在它的基础上补齐全书用到的其它术语。

## A

- **ACP（Agent Client Protocol）**：标准的 Agent 客户端协议。DSH 的 `acp` profile（`dsh-base` + `dsh-acp-app`，服务器包 `@deepseek-ai/dsh-acp`）在 stdio 上提供一个**仅面向自动化**的 ACP v1 服务器，只实现标准方法子集，不做第二套产品 UI（第 13 章）。
- **Agent**：一个活跃的智能体实体，绑定一个会话，由 `ctx.agents` 管理；投递输入用 `followup` / `steer` / `inject` / `send`（第 7 章）。
- **agent context（`agent.ctx`）**：Agent 自己的作用域上下文。通过它注册的工具、提示段、监听器只对该 Agent 可见，并随 Agent 一起释放（见 scope）。
- **Agent preset（声明式）**：用普通 Cordis YAML 声明的 Agent 配方，由 `dsh-agent-preset` 声明标识、显示元数据和子插件列表，`dsh-agent-preset-registry`（`ctx.agentPresets`）负责选择与**代际**：保存会产生新代际，仍在运行的 Agent 保留旧代际直到释放；子 Agent 继承父方的确切代际。Web 随附 `standard`、`ptc`、`minimal`、`cordis` 四个 preset（第 13 章）。
- **agent-loop**：默认主循环实现 `@deepseek-ai/dsh-agent-loop`，驱动 turn/step；工具并行上限由 `maxParallelToolCalls` 配置，默认 `DEFAULT_MAX_PARALLEL_TOOL_CALLS = 10`（第 7 章）。
- **API Gateway**：`@deepseek-ai/dsh-api-gateway`，把 Typert 生成的 Remote 方法暴露给浏览器：一元调用走 `POST /api/<namespace>/<method>`，所有流复用一条 `/api/remote.mux` WebSocket（第 11 章）。
- **approval（审批）**：`ctx.approval`（`dsh-user-approval`），在工具 body 执行前请求用户同意；策略 `ask` / `never`，结果为 allowed-once / rejected / cancelled / unavailable，拿不到答复按拒绝处理（第 10 章）。
- **Auto review**：实验包 `@deepseek-ai/dsh-experimental-auto-review`，属于可选 bundle。启用后提供会话级 `auto` 权限（`permission/preset:auto`），在每次工具调用执行前让当前模型审查；策略拒绝回退给用户审批，审查器自身失败则直接拒绝（第 10、13 章）。

## B

- **bail**：Cordis 的同步分发模式，是 serial 的同步版本（第 5 章）。
- **BOOTSTRAP_NAMES**：`dsh-app-boot` 中一组"只能由启动环境设置"的变量名（如 `PATH`、`NODE_OPTIONS`、`LD_PRELOAD`、`DEEPSEEK_BASE_URL`、代理与 CA 变量等）。任何被发现的 `.env` 文件设置它们都会让启动失败；代理变量可以放在 `$DSH_HOME/.env`（第 4、10 章）。
- **browser-use**：`packages/browser-use/browser-use`（`ctx.browserUse`）。服务只有一个 `register(name)` 方法，独占唯一的 Provider 槽位；具体浏览器工具由实验 Provider（Playwright MCP、Chrome DevTools MCP、Stagehand 原生）提供，不在默认安装中（第 13 章）。
- **Bundle（组合包）**：“配置行 + 代码”的发行单元：一个 npm 包，在 `package.json` 的 `dsh.bundle.patch` 指向一个或一组补丁文件。内置 bundle 有 `dsh-base`、`dsh-web-app`、`dsh-headless`、`dsh-sdk-app`、`dsh-sdk-minimal`、`dsh-acp-app`（第 4 章）。
- **bwrap（bubblewrap）**：Linux 上优先使用的沙箱 runner；不可用时回退到 Landlock（第 10 章）。

## C

- **canonical envelope（规范信封）**：会话格式 v3 起的约束：每种事件只有一种合法写法（例如表面消息必须带 `surfaceOp`，log-only 事件不得带表面元数据），读侧遇到不规范记录**拒绝而不修复**（第 6 章）。
- **Capability Seam（能力接缝）**：可替换能力的完整三角：**Service Definition**（拥有 `ctx.<key>` 与词汇类型的 Cordis `Service`）、一个或多个 **Service Provider**、一个或多个 **Consumer**。例如 `dsh-shell` / `dsh-bash-local`、`dsh-bash-sandbox` / `dsh-tool-bash`。按官方口径，"seam"只指完整能力，单个角色要按角色称呼（第 8 章）。
- **compaction（压缩）**：把会话的旧区间在"表面"上替换为摘要（`surfaceOp: replace`），原始事件仍留在日志里。默认实现 `dsh-compaction-basic`（`thresholdRatio` 默认 0.8、`retainRatio` 默认 0.16），另有工具结果裁剪 `dsh-compaction-tool-result-pruner`、图片卸载 `dsh-compaction-image-offload`（第 6、13 章，附录 F）。
- **compatibility.json**：profile 目录中的兼容豁免表：为"精确插件版本 × 精确 dsh 版本"登记豁免，使 peer 范围不匹配的 bundle 仍被加载（第 4 章、附录 D）。
- **computer-use**：`packages/computer-use/computer-use`（`ctx.computerUse`），与 browser-use 同样只做 Provider 名称登记；实验 Provider 为 Cua Driver 的 MCP 与原生两种形态。Provider 不为会话预留桌面（第 13 章）。
- **Consumer**：注入并使用某个服务的一方，通常是模型工具（如 `dsh-tool-fs`）。
- **Context**：Cordis 的上下文对象，按 `ctx.<key>` 访问服务。
- **Cordis**：DSH 底层插件框架（vendor 自 cordiverse/cordis，位于 `vendor/cordis`），提供 Context、插件、类型化事件、可逆副作用与 Fiber（第 3 章）。
- **cordis.yml / cordis.patch.yml**：插件条目列表与补丁文件。bundle、profile、home 各有一层 `cordis.patch.yml`，补丁按 `id` 替换条目或 `insert` 新条目（第 4 章）。
- **credentialRef（凭据引用）**：配置里只存引用、不存明文的凭据指针（`CredentialRef`，键形如 `<owner>/<id>`）。按请求解析，改了立即生效；API Key 路由默认引用 `DEEPSEEK_API_KEY`（第 9 章）。

## D

- **defineTool**：`@deepseek-ai/dsh-tools` 的工具定义助手，负责参数 schema、输出规范化与呈现声明（第 8 章、附录 D）。
- **deliverables（交付物）**：`packages/deliverables` 分组。`tool-present` 提供 `present` 工具让模型声明交付文件；`workspace-changes` 基于轮首/轮末 git 快照和文件工具编辑前后的捕获汇总本轮改动。两者都写只供客户端读取的 log-only 事件，Web 端由 `ui-deliverables` 渲染（第 13 章）。
- **deriveMessages()**：从会话表面推导模型消息历史的投影函数，带增量缓存（第 6 章）。
- **Desktop**：`apps/desktop`（Electron 外壳）+ `apps/desktop-host`（私有 Node 宿主），包装完整 Web 应用，独占 `$DSH_HOME/profiles/desktop`，默认端口 19387（第 2、11 章）。
- **DSH**：DeepSeek Harness 的缩写。
- **DSH_HOME**：Harness home 目录环境变量，默认 `~/.dsh`。
- **`--dump-config` / `--dump-default-config` / `--dump-config-schema`**：三个互斥的 CLI 诊断开关：打印合成后的配置树、只打印组合包各层、打印每个条目可配置项的 JSON Schema。schema 投影不完整时 `x-cordis.complete` 为 false，CLI 以退出码 1 结束（第 2、4、14 章，附录 G）。
- **dynamic tool updates（动态工具更新）**：会话中途工具集合变化时，日志记录"逻辑事实"（`developer/message`，来源 `tool-registry`），再按模型能力投影为 `in-history` 或 `addition-only` 形式（第 8 章）。

## E

- **Effect（副作用）**：插件通过 Cordis 做的注册都是 effect，卸载时自动撤销；Cordis 不管理的资源用 `ctx.effect()` 包装并返回销毁函数（第 3 章）。
- **emit**：观察语义的分发模式，不等待、无返回值（第 5 章）。
- **enforcement**：`ctx.sandbox.confine()` 如实上报的约束强度，`full` 或 `partial`（第 10 章）。
- **Entry（条目）**：配置树里的一行插件声明（`id` + `name` + `config`，可带 `disabled`、`inject`、`group`、`isolate`）。

## F

- **fail-closed**：安全相关失败时拒绝执行，而不是退回不受限状态。典型是沙箱不可用时报 `SANDBOX_UNAVAILABLE`、会话检查点写失败时不调用模型（第 10 章）。
- **fail-loud**：启动与运行期失败要响亮暴露：必需条目未激活即启动失败；未捕获异常和未处理的 rejection 一律写诊断并以 1 退出（`installFailLoud`，第 14 章）。
- **fatal diagnostics / crash report（致命诊断 / 崩溃报告）**：CLI 以 `fatal uncaught exception` / `fatal load failure` 为标签写 `util.inspect` 诊断；Desktop 在弹致命对话框之前把崩溃报告写进应用日志目录（第 14 章、附录 G）。
- **Fiber**：一个插件实例的运行时句柄，有 PENDING / LOADING / ACTIVE / FAILED / DISPOSED 等状态；`inject` 的服务缺失时停在 PENDING（第 3 章）。
- **fork**：从已有会话的某个边界派生子会话，新会话继承前缀并以 `session/end-seed` 标记继承边界（第 6 章）。

## G

- **goal / goal round**：一个会话上持久的完成目标（阶段 `active` / `paused` / `blocked` / `complete`）；goal round 是为该目标放行的一次续行，由 `goal-round-driver` 物化为一个 turn。目标是状态，不是调度器（第 13 章）。

## H

- **Harness Home**：用户级状态目录（默认 `~/.dsh`），含 `profiles/`、`cordis.patch.yml`、`.credentials.yaml`、`.env`、`sessions/`、`storages/`、`logs/` 等。旧版 `settings.yaml` 只会被一次性导入并改名为 `settings.yaml.imported`（第 2 章）。
- **HMR**：热替换。宿主侧 `dsh-hmr`（`dsh-base` 的 `hmr` 行）监视 profile 清单与用户补丁；客户端侧 `dsh-client-hmr` 热替换浏览器插件。headless、sdk、acp 在自己的层里关掉 `hmr`（第 4、11 章）。

## I

- **inject**：插件的依赖声明，服务就绪后才加载，服务消失则插件随之卸载（第 3 章）。
- **insert**：补丁语法，插入新条目（第 4 章）。
- **isolate**：条目选项，让一个 group 拥有某个服务名的独立实例（第 3 章）。

## J

- **jobs seam（后台任务接缝）**：`ctx.jobs`（`dsh-jobs` / `dsh-jobs-local`，模型工具在 `dsh-tool-jobs`）。0.1.7 起合并为"一个输出环、一个投影、一条事件流"：`JobSpec` + `JobHandle.append`、模型游标 `read` 与观察者 `readAt`、统一投影 `JobView`、`events.subscribe`；原 `packages/activity` 的活动记录并入 jobs（第 8、13 章）。

## L

- **Landlock**：Linux 内核 LSM 沙箱，DSH 通过原生启动器 `@deepseek-ai/node-addon-system/landlock-run`（自我限制后 exec）使用，是 bwrap 之后的回退 runner（第 10 章）。
- **lineage（谱系）**：父子关系作为数据携带（`parentSession`、`delegationDepth`、`subagentDepth`），不影响可见性（`docs/glossary.md`）。
- **Loader**：Cordis 的配置加载器，按条目挂载插件。0.1.7 中 vendored Loader 回退为**非事务式**：失败不回滚，由应用层启动审计报告未激活的条目（第 3 章）。

## M

- **MCP（Model Context Protocol）**：外部工具协议。`dsh-mcp-client` 每个实例连接一个服务器（工具名 `mcp__<server>__<tool>`，协议协商交给官方 SDK）；`dsh-mcp-resources` 提供 `list_mcp_resources`、`list_mcp_resource_templates`、`read_mcp_resource` 三个资源工具（第 8、13 章）。
- **MISSING_CREDENTIAL**：官方 API Key 路由在没有可用 Key 时的错误码；格式错误的 Key 报 `INVALID_CREDENTIAL`（第 9 章、附录 G）。

## O

- **observation policy（写前先读）**：`dsh-fs-observation-policy`，要求文件写入前先读取过该文件，文件在读后被改动则拒绝写入（第 10 章）。
- **optional bundle（可选 bundle）**：随 CLI 安装附带、默认关闭的 bundle，清单是 `profile.ts` 的 `OPTIONAL_BUNDLES`：Agent Teams（`dsh-experimental-agent-team-profile`）、语音输入（`dsh-experimental-voice-input-bundle`）、Auto review。只接纳依赖图已在安装闭包里的包，在 Web 插件页一键启用（第 4、13 章）。

## P

- **parallel**：分发模式，所有监听器并发执行（第 5 章）。
- **Patch（补丁）**：按 `id` 整行替换条目，或 `insert` 新条目。应用顺序固定：bundle（按 `dsh.profile.bundles` 顺序）→ profile 补丁 → home 补丁 → `--patch`（第 4 章）。
- **permission presets（权限预设）**：`ctx.permissionPresets`，把沙箱模式与审批策略捆成三档：`read-only`、`workspace-write`（默认）、`danger-full-access`（第 10 章）。
- **Profile（配置组合）**：命名的启动配方（`$DSH_HOME/profiles/<名字>/`），声明有序 bundle 列表与自己的补丁层。内置五个模板：`web`、`headless`、`sdk`、`sdk-minimal`、`acp`；`desktop` 为保留名（第 4 章）。
- **profile resolution generation（profile 解析代）**：profile 启动时计算一份不可变的 `RuntimeResolution` 并装入 Node 的 ESM/CommonJS 解析器，替代旧的磁盘链接；变更时整体发布一个新代，已有包的版本不在运行中替换（第 4 章）。
- **profile-owned live configuration（profile 自有实时配置）**：设置页与配置编辑器把改动写进当前 profile 的 `cordis.patch.yml`，被更高层遮蔽的写入会被拒绝；这取代了旧的 `settings.yaml`（第 4、9 章）。
- **Provider（Service Provider）**：接缝的实现方，如 `dsh-fs-local`、`dsh-bash-sandbox`、`dsh-llm-deepseek-api-key`。
- **PTC / ptc-runtime**：程序化工具调用。`ptc-runtime` 分组（旧名 code-runtime）定义 `ctx.ptcRuntime`，模型用 `run_code` 写一段程序、以异步函数调用工具；后端有 `dsh-ptc-runtime-node` 与实验性的 `ptc-runtime-python`（fd-3 协议）。工作流引擎 `workflow-ptc` 复用同一个 Node PTC 运行时（第 8、13 章）。

## R

- **Ralph loop**：一次前台"全新 Agent"迭代工作流（`tool-ralph`），每轮是一个没有对话种子的新子会话；随附默认组合中已关闭（`docs/glossary.md`，第 13 章）。
- **Remote / RemoteScope**：Typert 装饰器，把宿主方法暴露为远程 RPC；RemoteScope 按作用域解析目标后调用（第 12 章）。
- **remote.mux**：`/api/remote.mux`（`REMOTE_STREAM_MUX_PATH`），浏览器与宿主之间唯一的流复用 WebSocket，承载 `$events` 逻辑流与双向 `RemoteStream`，每条流有入站缓冲上限 `streamInboxBytes`（第 5、11 章）。
- **round**：包含一个 turn 的外层策略迭代，如 goal round 或一次 Ralph 尝试（`docs/glossary.md`）。

## S

- **SANDBOX_UNAVAILABLE**：`SandboxUnavailableError` 的错误码：请求了受限模式，但本机没有可用的沙箱 runner，命令被拒绝而不是裸跑（第 10 章、附录 G）。
- **Sandbox**：`ctx.sandbox`，模式 `read-only` / `workspace-write` / `danger-full-access`；本地实现 `dsh-sandbox-local` 按平台选 runner：Linux bwrap → Landlock，macOS Seatbelt，Windows ACL 受限令牌（第 10 章）。
- **Schemastery**：DSH 的配置校验库（`@deepseek-ai/schemastery`，常以 `z` 导入），`--dump-config-schema` 把它投影为 JSON Schema。
- **scope / scope key**：按 Agent 注册的单位。贡献要么是全局的，要么属于唯一一个 scope；约定是活跃 Agent 本身作为自己 scope 的 key。scope 只有两层，不向子 Agent 继承（`docs/glossary.md`，第 5 章）。
- **Seatbelt**：macOS 的 `sandbox-exec` 沙箱（第 10 章）。
- **serial**：分发模式，按顺序逐个询问，第一个给出答案的监听器说了算（第 5 章）。
- **Session（会话）**：一次交互过程，由追加式 `SessionEvent` 日志构成；持久化后端 `dsh-session-persistence-jsonl`（默认 zstd 压缩，按格式代际分文件）（第 6 章）。
- **session format v4（会话格式 v4）**：当前写入版本（`SESSION_FORMAT_VERSION = 4`）。工具结果成为一等的 `role: 'tool'` 消息，读侧对原生 v4 做强制的跨事件关系校验；旧代际文件永不覆盖，通过相邻版本迁移包读取（第 6 章）。
- **SessionEvent**：不可变会话事件，如 `turn/start`、`step/start`、`assistant/message`（内嵌紧凑的 `stream`）、`tool/call`、`tool/result`、`turn/end`。旧的逐块 `assistant/chunk` 自 v2 起已不存在（第 6 章）。
- **shadowing（遮蔽）**：同名解析取最具体者：scope 内的工具/提示段替换同名全局项（`docs/glossary.md`）。
- **spill**：工具大结果落外部存储，上下文只保留首尾与恢复路径。管线级策略 `dsh-spill-policy`（base 默认 `maxInlineTokens: 12500`）配合 `dsh-spill-local`（第 8 章）。
- **SRC fallback（SRC 回退）**：源码启动时 Typert 的开发期回退；客户端仍拒绝挂载缺少严格 codec 的 SRC 描述符（第 12 章）。
- **SSH runtime**：`packages/ssh` 分组（`dsh-ssh`、`fs-ssh`、`subprocess-ssh`、`sandbox-ssh`），把文件、进程、终端与沙箱执行放到一台 POSIX SSH 主机上，Harness、模型传输和会话存储留在本地；不引入新模型工具，断线不自动重连、不重放。它是同一组执行接口的另一种远程实现；已移除的 E2B provider 是云沙箱，笔记并未把 SSH runtime 定位为其替代品（第 8、13 章）。
- **startup audit（启动审计）**：Loader 结算后由 `dsh-app-boot` 检查每个未激活条目：必需条目（`agent-loop`、`webserver`、`connection` 等）未激活时报 `startup failed: N required plugin(s) did not activate`，其它条目只打印 `warning: N entries did not activate`（附录 G）。
- **Step（步）**：一次模型请求加上它引起的工具执行（`docs/glossary.md`）。
- **StreamChunk**：LLM 流式协议的统一块类型（`block-start`、`text-delta`、`reasoning-delta`、`tool-call-delta`、`block-end`、`usage`、`finish`）（第 9 章）。
- **surface / surfaceOp（表面）**：会话日志中产生模型历史的那部分事件；`surfaceOp` 为 `'append'` 或 `{ op: 'replace', startSeq, endSeq }`（第 6 章）。

## T

- **Tool（工具）**：模型可调用的函数，经 `ctx.tools` 管线执行（`tools/pre-execute` → 审批 → guard → body → 输出投影 → `tools/post-execute` → `tools/result`）（第 8 章）。
- **tool call three phases（工具调用三阶段）**：客户端按 callId 把一次工具调用呈现为 `preparing`（参数仍在生成）→ `start`（已派发）→ `result`，只影响 UI 呈现（第 8 章）。
- **trustedHosts**：connection 信任围栏的额外 authority 列表（CLI `--trusted-host`）。Host/Origin 检查失败返回 403，它只防 DNS 重绑定与跨站请求，不确立身份（第 11 章）。
- **Turn（轮）**：一次对已认领输入的完整排空，包含零到多个 step（`docs/glossary.md`，第 7 章）。
- **Typert**：从编译期类型图生成 RPC 契约的系统（第 12 章）。

## W

- **waterfall**：分发模式，链式中间件，`next()` 委托或短路（第 5 章）。
- **WebBootGraph**：宿主生成、注入到页面 `window.__DSH_BOOT__` 的启动图（`{ rev, entries, batches }`，批次分 bootstrap 与 application），客户端插件据此经 combo 请求加载（第 11 章）。
- **workflow（工作流）**：`ctx.workflowEngine`，模型写编排脚本、脚本中的 `agent()` 经子 Agent 扇出；执行后端 `workflow-ptc`（第 13 章）。

## 其他

- **`!!js`**：配置中的 JS 表达式标记，只在条目的 `config` 与 `disabled` 上求值（第 3 章）。
- **浏览器令牌认证**：每个进程生成一次随机启动令牌，`dsh web` 打印并打开 `…/?token=…`；首页用令牌换一个绑定 authority 的签名 Cookie（默认 30 天，HttpOnly、SameSite=Strict）后重定向到干净的 `./`。缺少或无效 Cookie 的请求返回 401（第 11 章、附录 G）。
- **`~/.dsh`**：默认 Harness home。

## 已不再使用的旧术语

下列词在旧版（0.1.5）书稿或文档中出现过，HEAD 中已删除或改名，读旧资料时注意换算：

| 旧术语 | 现状 |
| --- | --- |
| E2B provider（`packages/e2b`） | 已移除，远程执行改由 SSH runtime 承担 |
| code-runtime / `code-runtime-python` | 改名为 ptc-runtime / `ptc-runtime-python` |
| `assistant/chunk` | 不再是持久化事件，流内容内嵌在 `assistant/message.stream` |
| `packages/host/apiproxy`、`HOST_EVENTS_PATH` / `MUX_EVENTS_PATH` | 已删除，统一走 API Gateway 与 `/api/remote.mux` |
| `packages/activity` | 并入 `ctx.jobs` |
| `settings.yaml` | 只做一次性导入，设置由 profile 补丁承载 |
| 事务式 Loader | 回退为非事务式，失败由启动审计报告 |
| `telemetry/*` 事件 | 已删除；会话遥测走 `dsh-session-telemetry`，产品遥测走 `product-telemetry-otel` |

## 主题索引（按需求查找）

按"想解决什么问题"查术语（→ 指向术语表词条；括号内是全书章节）：

**插件开发**
- 想写一个插件 → Context / inject / Effect / Fiber / Entry（第 3 章）
- 想给模型加能力 → Tool / defineTool / Capability Seam / Consumer（第 8 章 + 附录 D）
- 想换实现 → Capability Seam / Provider / Bundle（第 8 章）
- 想加配置层 → Profile / Patch / insert / profile-owned live configuration / optional bundle（第 4 章）

**架构理解**
- 想理解加载顺序 → Bundle / Profile / Patch / `!!js` / Loader / profile resolution generation（第 3、4 章）
- 想理解通信 → emit / waterfall / serial / bail / parallel / scope（第 5 章）
- 想理解会话 → Session / SessionEvent / surface / canonical envelope / session format v4 / deriveMessages / compaction / fork（第 6 章）
- 想理解主循环 → Turn / Step / agent-loop / Agent（第 7 章）
- 想理解安全 → Sandbox / bwrap / Landlock / Seatbelt / enforcement / fail-closed / permission presets / approval / Auto review / BOOTSTRAP_NAMES（第 10 章）
- 想理解前端 → WebBootGraph / API Gateway / remote.mux / 浏览器令牌认证 / trustedHosts / HMR / Desktop（第 11 章）
- 想理解 RPC → Typert / Remote / RemoteScope / SRC fallback（第 12 章）

**运维与调试**
- 报错排查 → `--dump-config` / `--dump-config-schema` / startup audit / fail-loud / fatal diagnostics / SANDBOX_UNAVAILABLE / MISSING_CREDENTIAL / credentialRef（附录 G）
- 测试 → keyless 快照回放、质量门 `scripts/run-gates.ts`（第 14 章，未单列词条）
- 性能 → compaction / spill / session format v4 / jobs seam（附录 F）

**进阶能力**
- 委派 → Agent / lineage / fork（第 13 章）
- 程序化执行 → PTC / ptc-runtime / workflow / Ralph loop（第 13 章）
- 目标与后台 → goal / goal round / jobs seam（第 13 章）
- 交付与外部世界 → deliverables / MCP / browser-use / computer-use / SSH runtime（第 13 章）
- 产品扩展 → Agent preset / optional bundle / Auto review（第 13 章）
- 多入口 → ACP / Desktop（第 13 章）

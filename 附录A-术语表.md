# 附录 A 术语表

按首字母排序（中文词条按拼音就近归入）。术语口径以源码 HEAD（0.2.1-alpha.2）与官方 `docs/glossary.md` 为准；`docs/glossary.md` 只收录少数核心领域词（seam、scope、goal、turn/step/round、Ralph 等），这里在它的基础上补齐全书用到的其它术语。相对上一版基准 0.1.7-rc.2 新增或含义变化的词条，在括号里注明了版本。

## A

- **ACP（Agent Client Protocol）**：标准的 Agent 客户端协议。DSH 的 `acp` profile（`dsh-base` + `dsh-acp-app`，服务器包 `@deepseek-ai/dsh-acp`）在 stdio 上提供一个**仅面向自动化**的 ACP v1 服务器，只实现标准方法子集，不做第二套产品 UI（第 13 章）。
- **activation（子 Agent 激活）**：0.2.1-alpha.2 起子 Agent 的唯一运行模型。模型面的委派工具在接纳子 Agent 后立即返回 `{ kind: 'activation', subagentId }`，最终答案通过父级完成通知送达；宿主代码用 `ctx.subagents.startActivation()`，选 `delivery: 'caller'` 时由调用方直接拿 `result`、不再发父级通知。它取代了前台结果、`run_in_background` 后台模式和已删除的 `subagent-in-process-driver`；子 Agent 也不再经过 `ctx.jobs`（第 7、13 章）。
- **Agent**：一个活跃的智能体实体，绑定一个会话，由 `ctx.agents` 管理；投递输入用 `followup` / `steer` / `inject` / `send`（第 7 章）。
- **agent context（`agent.ctx`）**：Agent 自己的作用域上下文。通过它注册的工具、提示段、监听器只对该 Agent 可见，并随 Agent 一起释放（见 scope）。
- **Agent preset（声明式）**：用普通 Cordis YAML 声明的 Agent 配方，由 `dsh-agent-preset` 声明标识、显示元数据和子插件列表，`dsh-agent-preset-registry`（`ctx.agentPresets`）负责选择与**代际**：保存会产生新代际，仍在运行的 Agent 保留旧代际直到释放；子 Agent 继承父方的确切代际。Web 随附 `standard`、`ptc`、`minimal`、`cordis` 四个 preset。0.2.1-alpha.2 起 Web 与 Desktop 的"新会话"总是按当前预设定义创建新的 Session 和 Agent，不再复用空会话（第 4、6、13 章）。
- **Agent Teams（团队）**：可选 bundle `dsh-experimental-agent-team-profile` 提供的多成员协作。0.2.1-alpha.2 起成员消息**直接进入目标 Agent 的 inbox**（来源 `agent-message`），`send_message` 只回 `{ "sent": true }`，旧的 `maxPendingMessagesPerMember` 已删除（第 7、13 章）。
- **agent-loop**：默认主循环实现 `@deepseek-ai/dsh-agent-loop`，驱动 turn/step；工具并行上限由 `maxParallelToolCalls` 配置，默认 `DEFAULT_MAX_PARALLEL_TOOL_CALLS = 10`（第 7 章）。
- **API Gateway**：`@deepseek-ai/dsh-api-gateway`，把 Typert 生成的 Remote 方法暴露给浏览器：一元调用走 `POST /api/<namespace>/<method>`，所有流复用一条 `/api/remote.mux` WebSocket（第 11 章）。
- **approval（审批）**：`ctx.approval`（`dsh-user-approval`），在工具 body 执行前请求用户同意；策略 `ask` / `never`，结果为 allowed-once / rejected / cancelled / unavailable，拿不到答复按拒绝处理（第 10 章）。
- **Auto review**：实验包 `@deepseek-ai/dsh-experimental-auto-review`（`packages/experimental/auto-review`），是随附的可选 bundle 之一。启用后提供会话级 `auto` 权限预设（`permission/preset` 事件里记为 `auto`），在每次工具调用执行前让当前模型审查；策略拒绝回退给用户审批，审查器自身失败则直接让调用失败；委派的进程内子 Agent 固定 `never`，拒绝即最终结果（第 10、13 章）。

## B

- **bail**：Cordis 的同步分发模式，是 serial 的同步版本（第 5 章）。
- **BOOTSTRAP_NAMES**：`dsh-app-boot` 中一组"只能由启动环境设置"的变量名（如 `PATH`、`NODE_OPTIONS`、`LD_PRELOAD`、`DEEPSEEK_BASE_URL`、代理与 CA 变量等）。任何被发现的 `.env` 文件设置它们都会让启动失败；代理变量可以放在 `$DSH_HOME/.env`（第 4、10 章）。
- **browser-use**：`packages/browser-use/browser-use`（`ctx.browserUse`）。服务只有一个 `register(name)` 方法，独占唯一的 Provider 槽位；具体浏览器工具由实验 Provider（Playwright MCP、Chrome DevTools MCP、Stagehand 原生）提供，不在默认安装中（第 13 章）。
- **Bundle（组合包）**：“配置行 + 代码”的发行单元：一个 npm 包，在 `package.json` 的 `dsh.bundle.patch` 指向一个或一组补丁文件。内置 bundle 有 `dsh-base`、`dsh-web-app`、`dsh-headless`、`dsh-sdk-app`、`dsh-sdk-minimal`、`dsh-acp-app`；官方还另有随附的可选 bundle 与按需安装的 bundle（见 optional bundle、on-demand bundle，第 4 章）。
- **bwrap（bubblewrap）**：Linux 上优先使用的沙箱 runner；不可用时回退到 Landlock（第 10 章）。

## C

- **canonical envelope（规范信封）**：会话格式 v3 起的约束：每种事件只有一种合法写法（例如表面消息必须带 `surfaceOp`，log-only 事件不得带表面元数据），读侧遇到不规范记录**拒绝而不修复**（第 6 章）。
- **Capability Seam（能力接缝）**：可替换能力的完整三角：**Service Definition**（拥有 `ctx.<key>` 与词汇类型的 Cordis `Service`）、一个或多个 **Service Provider**、一个或多个 **Consumer**。例如 `dsh-shell` / `dsh-bash-local`、`dsh-bash-sandbox` / `dsh-tool-bash`。按官方口径，"seam"只指完整能力，单个角色要按角色称呼（第 8 章）。
- **Claude Code mods**：实验包 `@deepseek-ai/dsh-experimental-claude-code-mods`（0.2.1-alpha.2 新增），让为 Claude Code 编写的 mod 以 DSH 插件形式经 cordis.yml 挂载；与 Claude Code 行为不同之处逐条记录在 `docs/subsystems/claude-code-mods.md`。它不在可选 bundle 清单里，需要显式组合（第 13 章）。
- **cli-help（`docs/cli-help.md`）**：由 `scripts/gen-cli-help.ts` 生成的完整 CLI 帮助参考（启动器、`dsh plugin`、各随附 profile），`verify-cli-help` 检查它是否过期（第 2、14 章，附录 B）。
- **compaction（压缩）**：把会话的旧区间在"表面"上替换为摘要（`surfaceOp: replace`），原始事件仍留在日志里。默认实现 `dsh-compaction-basic`（`thresholdRatio` 默认 0.8、`retainRatio` 默认 0.16），另有工具结果裁剪 `dsh-compaction-tool-result-pruner`、图片卸载 `dsh-compaction-image-offload`（第 6、13 章，附录 F）。
- **compatibility.json**：profile 目录中的兼容豁免表：为"精确插件版本 × 精确 dsh 版本"登记豁免，使 peer 范围不匹配的 bundle 仍被加载（第 4 章、附录 D、附录 G）。
- **computer-use**：`packages/computer-use/computer-use`（`ctx.computerUse`），与 browser-use 同样只做 Provider 名称登记；实验 Provider 为 Cua Driver 的 MCP 与原生两种形态。Provider 不为会话预留桌面（第 13 章）。
- **Consumer**：注入并使用某个服务的一方，通常是模型工具（如 `dsh-tool-fs`）。
- **Context**：Cordis 的上下文对象，按 `ctx.<key>` 访问服务。
- **Cordis**：DSH 底层插件框架（vendor 自 cordiverse/cordis，位于 `vendor/cordis`），提供 Context、插件、类型化事件、可逆副作用与 Fiber（第 3 章）。
- **cordis.yml / cordis.patch.yml**：插件条目列表与补丁文件。bundle、profile、home 各有一层 `cordis.patch.yml`，补丁按 `id` 替换条目或 `insert` 新条目（第 4 章）。
- **CoT 翻译（思维链翻译）**：可选 bundle `dsh-experimental-cot-translation-bundle`（0.2.1-alpha.2 新增），把模型的推理内容翻译后展示。底层翻译服务是实验包 `@deepseek-ai/dsh-experimental-translator`（`ctx.translator`），provider 为 `bing`、`google`、`deepseek-account`、`deepseek-official`，付费路由只接受精确的 `deepseek-flash` 且关闭思考，否则报 `TRANSLATION_UNAVAILABLE`；会话内结果以 `plugin:translator/*` 记录复用（第 6、9、13 章）。
- **credentialRef（凭据引用）**：配置里只存引用、不存明文的凭据指针（`CredentialRef`，键形如 `<owner>/<id>`）。按请求解析，改了立即生效；API Key 路由默认引用 `DEEPSEEK_API_KEY`（第 9 章）。

## D

- **defineTool**：`@deepseek-ai/dsh-tools` 的工具定义助手，负责参数 schema、输出规范化与呈现声明（第 8 章、附录 D）。
- **deliverables（交付物）**：`packages/deliverables` 分组。`tool-present` 提供 `present` 工具让模型声明交付文件；`workspace-changes` 基于轮首/轮末 git 快照和文件工具编辑前后的捕获汇总本轮改动。两者都写只供客户端读取的 log-only 事件，Web 端由 `ui-deliverables` 渲染（第 13 章）。
- **deriveMessages()**：从会话表面推导模型消息历史的投影函数，带增量缓存（第 6 章）。
- **Desktop**：`apps/desktop`（Electron 外壳）+ `apps/desktop-host`（私有 Node 宿主），包装完整 Web 应用，独占保留名 profile `desktop`。0.2.1-alpha.1 起默认监听**系统分配的端口**（不再固定 19387），可用 `webserver.config.port` 补丁覆盖；桌面端自带的 `dsh` 命令可以管理 `desktop` profile 的插件（第 2、11 章）。
- **DSH**：DeepSeek Harness 的缩写。
- **DSH_HOME**：Harness home 目录环境变量，默认 `~/.dsh`。0.2.1-alpha.2 起指令加载（`agent-instructions`）也只跟随它，旧的 `dshHome` 配置字段已删除（第 4 章）。
- **`dsh plugin --profile` 位置规则**：0.2.1-alpha.2 起 `dsh plugin` 只在被转发的 pnpm 参数**之前**读取 `--profile`，写在后面会报 `required option '--profile <name>' not specified`；`dsh plugin --help` 打印它自己的帮助（第 2、4、14 章，附录 G）。
- **`--dump-config` / `--dump-default-config` / `--dump-config-schema`**：三个互斥的 CLI 诊断开关：打印合成后的配置树、只打印组合包各层、打印每个条目可配置项的 JSON Schema。schema 投影不完整时 `x-cordis.complete` 为 false，CLI 以退出码 1 结束（第 2、4、14 章，附录 G）。
- **dynamic tool updates（动态工具更新）**：会话中途工具集合变化时，日志记录"逻辑事实"（`developer/message`，来源 `tool-registry`），再按模型能力投影为 `in-history` 或 `addition-only` 形式（第 8 章）。

## E

- **Effect（副作用）**：插件通过 Cordis 做的注册都是 effect，卸载时自动撤销；Cordis 不管理的资源用 `ctx.effect()` 包装并返回销毁函数（第 3 章）。
- **emit**：观察语义的分发模式，不等待、无返回值（第 5 章）。
- **enforcement**：`ctx.sandbox.confine()` 如实上报的约束强度，`full` 或 `partial`（第 10 章）。
- **Entry（条目）**：配置树里的一行插件声明（`id` + `name` + `config`，可带 `disabled`、`inject`、`group`、`isolate`）。
- **experimental package（实验包）**：位于 `packages/experimental/` 的包。0.2.1-alpha.2 把 hooks（`hook-protocol`、`hooks-claude-code`、`hooks-codex`）、`webhook` / `webhook-github`、`tool-terminal`、`tool-ralph`、`tool-session-query` 等移入这里，**包名不变**，目录与包名的对应以 `scripts/experimental-package-policy.ts` 为准。**安装与组合相互独立**：CLI 不再默认依赖 hooks/webhook，profile 禁用自动 peer 安装，装了包也要选中 bundle 或显式 `insert` 才会挂载（第 4、13 章）。

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
- **hooks（钩子桥接）**：把 Claude Code / Codex 风格的 hook 接到 DSH 事件上的实验包（`@deepseek-ai/dsh-hook-protocol`、`@deepseek-ai/dsh-hooks-claude-code`、`@deepseek-ai/dsh-hooks-codex`）。0.2.1-alpha.2 起位于 `packages/experimental/`，不随 CLI 安装，需与 peer 一起 `dsh plugin --profile <名字> add` 后再组合（第 13 章）。

## I

- **inject**：插件的依赖声明，服务就绪后才加载，服务消失则插件随之卸载（第 3 章）。
- **insert**：补丁语法，插入新条目（第 4 章）。
- **Inspector / Session Inspector**：可选 bundle `dsh-experimental-inspector-profile`（Web profile 的检查层）插入 `dsh-experimental-inspector` 与 `dsh-experimental-session-inspector` 两行；后者以虚拟化表格查看原始会话日志和 Chat 节点、带流式增量行与更新高亮，用于调试而非日常使用（第 13、14 章）。
- **isolate**：条目选项，让一个 group 拥有某个服务名的独立实例（第 3 章）。

## J

- **jobs seam（后台任务接缝）**：`ctx.jobs`（`dsh-jobs` / `dsh-jobs-local`，模型工具在 `dsh-tool-jobs`）。0.1.7 起合并为"一个输出环、一个投影、一条事件流"：`JobSpec` + `JobHandle.append`、模型游标 `read` 与观察者 `readAt`、统一投影 `JobView`、`events.subscribe`；原 `packages/activity` 的活动记录并入 jobs。0.2.1-alpha.2 起子 Agent 改走 activation，不再是 jobs 的生产者（第 8、13 章）。

## L

- **Landlock**：Linux 内核 LSM 沙箱，DSH 通过原生启动器 `@deepseek-ai/node-addon-system/landlock-run`（自我限制后 exec）使用，是 bwrap 之后的回退 runner（第 10 章）。
- **lineage（谱系）**：父子关系作为数据携带（`parentSession`、`delegationDepth`、`subagentDepth`），不影响可见性（`docs/glossary.md`）。
- **listener trust（监听、公告与信任分离）**：`dsh web` 把三件事拆成互不蕴含的参数：`--host` 决定**监听**在哪个具体地址、`--public-url` 决定**公告**什么地址、`--trusted-host` 决定**信任**哪些 authority。公告一个 URL 不会让它被信任；所绑定的具体 IP 会被信任围栏直接接受；通配地址（`0.0.0.0`、`::`）在加载时就被拒绝（第 2、11 章，附录 G）。
- **Loader**：Cordis 的配置加载器，按条目挂载插件。0.1.7 中 vendored Loader 回退为**非事务式**：失败不回滚，由应用层启动审计报告未激活的条目（第 3 章）。

## M

- **MCP（Model Context Protocol）**：外部工具协议。`dsh-mcp-client` 每个实例连接一个服务器（工具名 `mcp__<server>__<tool>`，协议协商交给官方 SDK）；`dsh-mcp-resources` 提供 `list_mcp_resources`、`list_mcp_resource_templates`、`read_mcp_resource` 三个资源工具（第 8、13 章）。
- **MISSING_CREDENTIAL**：官方 API Key 路由在没有可用 Key 时的错误码；格式错误的 Key 报 `INVALID_CREDENTIAL`。0.2.1-alpha.2 起列模型时缺 Key 不再报错，而是返回**空模型目录**（模型选择器里没有 DeepSeek 分组），真正发请求时仍报此码（第 9 章、附录 G）。

## N

- **no-response**：DeepSeek 账号登录错误码 `SignInErrorCode` 的新成员（0.2.1-alpha.1）：fetch 在拿到任何 HTTP 响应前就失败（含单次请求超时）。此前这类失败报 `network`；现在 `network` 只表示 HTTP 响应错误等通用失败，`expired` 仍表示授权尝试到期。登录对话框只对 `no-response` 给出网络排查提示（第 2、9 章，附录 G）。

## O

- **observation policy（写前先读）**：`dsh-fs-observation-policy`，要求文件写入前先读取过该文件，文件在读后被改动则拒绝写入（第 10 章）。
- **on-demand bundle（按需安装的官方 bundle）**：`official-bundle-packages.ts` 的 `ON_DEMAND_BUNDLES`（0.2.1-alpha.2 新增）：`@deepseek-ai/dsh-subagent-claude-code` 与 `@deepseek-ai/dsh-subagent-codex`。它们不进安装依赖，插件页"官方"分组凭离线目录展示，用户打开时才按当前版本经普通 bundle 安装器下载（第 4、13 章）。
- **optional bundle（可选 bundle）**：随 CLI 安装附带、默认关闭的 bundle，清单是 `profile.ts` 的 `OPTIONAL_BUNDLES`，HEAD 共 11 项：会话搜索（`session-search`）、Ralph（`ralph-bundle`）、持久终端（`terminal-bundle`）、技能徽章（`badge-skill-bundle`）、会话标题（`session-titles-bundle`）、Agent Teams（`agent-team-profile`）、语音输入（`voice-input-bundle`）、CoT 翻译（`cot-translation-bundle`）、Auto review、Inspector（`inspector-profile`）、Git Worktrees（`tool-worktree`），包名都带 `@deepseek-ai/dsh-experimental-` 前缀。只接纳依赖图已在安装闭包里的包，在 Web 插件页一键启用（第 4、13 章）。
- **OTel（`ctx.otel`）**：0.2.1-alpha.2 新增分组 `telemetry` 中的 `@deepseek-ai/dsh-otel`（`packages/telemetry/otel`），为普通事件和会话日志提供彼此独立的上报通道工厂；产品适配器 `product-telemetry-otel` 与会话适配器 `session-telemetry-otel` 在其上保留各自的部署配置。只挂载 OTel 服务不会分配任何 provider 或传输（第 13 章）。

## P

- **parallel**：分发模式，所有监听器并发执行（第 5 章）。
- **Patch（补丁）**：按 `id` 整行替换条目，或 `insert` 新条目。应用顺序固定：bundle（按 `dsh.profile.bundles` 顺序）→ profile 补丁 → home 补丁 → `--patch`（第 4 章）。
- **permission presets（权限预设）**：`ctx.permissionPresets`，把沙箱模式与审批策略捆成三档：`read-only`、`workspace-write`（默认）、`danger-full-access`；启用 Auto review 后多一档 `auto`（第 10 章）。
- **plugin record（实验性插件记录）**：实验包写进会话日志、类型以 `plugin:` 为前缀的记录（`PluginRecordMap`、`appendPluginRecord()`），目录见 `docs/experimental-persistence-catalog.md`，例如 CoT 翻译的 `plugin:translator/request` / `plugin:translator/result`（第 6 章）。
- **Profile（配置组合）**：命名的启动配方（`$DSH_HOME/profiles/<名字>/`），声明有序 bundle 列表与自己的补丁层。内置五个模板：`web`、`headless`、`sdk`、`sdk-minimal`、`acp`；`desktop` 为保留名（第 4 章）。
- **profile resolution generation（profile 解析代）**：profile 启动时计算一份不可变的 `RuntimeResolution` 并装入 Node 的 ESM/CommonJS 解析器，替代旧的磁盘链接；变更时整体发布一个新代，已有包的版本不在运行中替换（第 4 章）。
- **profile-owned live configuration（profile 自有实时配置）**：设置页与配置编辑器把改动写进当前 profile 的 `cordis.patch.yml`，被更高层遮蔽的写入会被拒绝；这取代了旧的 `settings.yaml`（第 4、9 章）。
- **Provider（Service Provider）**：接缝的实现方，如 `dsh-fs-local`、`dsh-bash-sandbox`、`dsh-llm-deepseek-api-key`。
- **PTC / ptc-runtime**：程序化工具调用。`ptc-runtime` 分组（旧名 code-runtime）定义 `ctx.ptcRuntime`，模型用 `run_code` 写一段程序、以异步函数调用工具；后端有 `dsh-ptc-runtime-node` 与实验性的 `ptc-runtime-python`（fd-3 协议，0.2.1-alpha.2 起强制注入共享沙箱）。工作流引擎 `workflow-ptc` 复用同一个 Node PTC 运行时（第 8、13 章）。
- **public URL（`--public-url`）**：`dsh web` 对外**公告**的 HTTP(S) 根地址，用于打印、自动打开、`DSH_WEB_URL` 等，**不授予任何信任**——经反向代理访问时仍要用 `--trusted-host` 放行代理的 authority。公开部署见 `docs/user/guide/public-deployments.md`（第 2、11 章）。

## R

- **Ralph loop**：一次前台"全新 Agent"迭代工作流（`tool-ralph`），每轮是一个没有对话种子的新子会话（`docs/glossary.md`）。0.2.1-alpha.2 起 `tool-ralph` 位于 `packages/experimental/`，base 与 Web 预设不再带休眠的 Ralph 行，改由可选 bundle `ralph-bundle` 提供（第 13 章）。
- **Remote / RemoteScope**：Typert 装饰器，把宿主方法暴露为远程 RPC；RemoteScope 按作用域解析目标后调用（第 12 章）。
- **remote.mux**：`/api/remote.mux`（`REMOTE_STREAM_MUX_PATH`），浏览器与宿主之间唯一的流复用 WebSocket，承载 `$events` 逻辑流与双向 `RemoteStream`，每条流有入站缓冲上限 `streamInboxBytes`（第 5、11 章）。
- **RETIRED_BUNDLES（已退役 bundle）**：`profile.ts` 中一组"早先发布过、安装中已不再携带"的 bundle 名，加载 profile 时从 `dsh.profile.bundles` 中删除并重写 `package.json`。HEAD 只有 `@deepseek-ai/dsh-experimental-schedule-bundle` 一项（第 4 章）。
- **round**：包含一个 turn 的外层策略迭代，如 goal round 或一次 Ralph 尝试（`docs/glossary.md`）。

## S

- **SANDBOX_UNAVAILABLE**：`SandboxUnavailableError` 的错误码：请求了受限模式，但本机没有可用的沙箱 runner，命令被拒绝而不是裸跑（第 10 章、附录 G）。
- **Sandbox**：`ctx.sandbox`，模式 `read-only` / `workspace-write` / `danger-full-access`；本地实现 `dsh-sandbox-local` 按平台选 runner：Linux bwrap → Landlock，macOS Seatbelt，Windows ACL 受限令牌（第 10 章）。
- **Schedule（定时提醒）**：`packages/schedule`。0.2.1-alpha.1 起"自动化任务"可选 bundle 退役：`dsh-web-app` 在每个 Web profile 中直接挂载 `schedule` 与 `ui-schedule`，模型工具拆为 `@deepseek-ai/dsh-tool-schedule`（四个 `schedule_*` 工具），由 `standard`、`cordis`、`ptc` 三个 preset 声明，`minimal` 不声明（第 13 章）。
- **Schemastery**：DSH 的配置校验库（`@deepseek-ai/schemastery`，常以 `z` 导入），`--dump-config-schema` 把它投影为 JSON Schema。
- **scope / scope key**：按 Agent 注册的单位。贡献要么是全局的，要么属于唯一一个 scope；约定是活跃 Agent 本身作为自己 scope 的 key。scope 只有两层，不向子 Agent 继承（`docs/glossary.md`，第 5 章）。
- **Seatbelt**：macOS 的 `sandbox-exec` 沙箱（第 10 章）。
- **serial**：分发模式，按顺序逐个询问，第一个给出答案的监听器说了算（第 5 章）。
- **Session（会话）**：一次交互过程，由追加式 `SessionEvent` 日志构成；持久化后端 `dsh-session-persistence-jsonl`（默认 zstd 压缩，按格式代际分文件，当前为 `session.v4.jsonl.zstd`）（第 6 章）。
- **session format v4（会话格式 v4）**：当前写入版本（`SESSION_FORMAT_VERSION = 4`，0.2.x 未变）。工具结果成为一等的 `role: 'tool'` 消息，读侧对原生 v4 做强制的跨事件关系校验；旧代际文件永不覆盖，通过相邻版本迁移包读取。v4 之内的增补（如 `working-directory/change`）以 same-version 方式登记在 `docs/persistence-changes/`（第 6 章）。
- **session search（会话搜索）**：可选 bundle `dsh-experimental-session-search`，给 Agent 提供搜索、读取当前工作区早先会话的工具（工具实现 `tool-session-query` 已移入 `packages/experimental/`）。它在一个 `isolate: { sessionQuery: true }` 的分组里挂载**自己的** `session-query-sqlite`（`path: ':memory:'`、`openAt: first-search`），不改动 `dsh-base` 中 `openAt: never` 的那一行（第 6 章、附录 F）。
- **SessionEvent**：不可变会话事件，如 `turn/start`、`step/start`、`assistant/message`（内嵌紧凑的 `stream`）、`tool/call`、`tool/result`、`turn/end`。旧的逐块 `assistant/chunk` 自 v2 起已不存在（第 6 章）。
- **shadowing（遮蔽）**：同名解析取最具体者：scope 内的工具/提示段替换同名全局项（`docs/glossary.md`）。
- **spill**：工具大结果落外部存储，上下文只保留首尾与恢复路径。管线级策略 `dsh-spill-policy`（base 默认 `maxInlineTokens: 12500`）配合 `dsh-spill-local`（第 8 章）。
- **SRC fallback（SRC 回退）**：源码启动时 Typert 的开发期回退；客户端仍拒绝挂载缺少严格 codec 的 SRC 描述符（第 12 章）。
- **SSH runtime**：`packages/ssh` 分组（`dsh-ssh`、`fs-ssh`、`subprocess-ssh`、`sandbox-ssh`，以及 0.2.1-alpha.2 新增的内嵌 Node 的 `ssh-helper-runtime`），把文件、进程、终端与沙箱执行放到一台 POSIX SSH 主机上，Harness、模型传输和会话存储留在本地；不引入新模型工具，断线不自动重连、不重放。0.2.1-alpha.2 起 `dsh-ssh` 用 `launch: { kind: node-script | executable }` 描述远端辅助程序并要求 SSH 协议 2。它是同一组执行接口的另一种远程实现；已移除的 E2B provider 是云沙箱，笔记并未把 SSH runtime 定位为其替代品（第 8、10、13 章）。
- **startup audit（启动审计）**：Loader 结算后由 `dsh-app-boot` 检查每个未激活条目：必需条目（`agent-loop`、`webserver`、`web-runtime`、`modules`、`connection`、`headless-runner`、`acp`、`sdk-jsonrpc-server`，只算出现在配置树里且未禁用的）未激活时报 `startup failed: N required plugin(s) did not activate`，其它条目只打印 `warning: N entries did not activate`（附录 G）。
- **Step（步）**：一次模型请求加上它引起的工具执行（`docs/glossary.md`）。
- **StreamChunk**：LLM 流式协议的统一块类型（`block-start`、`text-delta`、`reasoning-delta`、`tool-call-delta`、`block-end`、`usage`、`finish`）（第 9 章）。
- **surface / surfaceOp（表面）**：会话日志中产生模型历史的那部分事件；`surfaceOp` 为 `'append'` 或 `{ op: 'replace', startSeq, endSeq }`（第 6 章）。

## T

- **TLS（`--tls-cert` / `--tls-key`）**：0.2.1-alpha.2 起 `webserver` 可以用 `node:https` 直接提供 HTTPS（`tls: { certFile, keyFile }`），两个参数必须成对给出；证书读不到、为空或与私钥不匹配都会让启动失败，不会退回 HTTP。只有监听器自己是 TLS 时，认证 Cookie 才带 `Secure`（第 11 章，附录 G）。
- **Tool（工具）**：模型可调用的函数，经 `ctx.tools` 管线执行（`tools/pre-execute` → 审批 → guard → body → 输出投影 → `tools/post-execute` → `tools/result`）（第 8 章）。
- **tool call three phases（工具调用三阶段）**：客户端按 callId 把一次工具调用呈现为 `preparing`（参数仍在生成）→ `start`（已派发）→ `result`，只影响 UI 呈现（第 8 章）。
- **tool presentation mode（工具呈现方式）**：每个 Agent 只用一种调用形式：`native`（可见工具直接作为函数调用）或 `ptc`（只暴露 `run_code`，程序经生成的 SDK 调工具）。由 `@deepseek-ai/dsh-agent-tool-presentation` 按 preset 选择，环境变量 `DSH_TOOLS_MODE=native|ptc` 覆盖随附配置；0.2.1-alpha.2 起 `both` 被拒绝（第 8、11 章）。
- **trustedHosts**：connection 信任围栏的额外 authority 列表（CLI `--trusted-host`），0.2.1-alpha.2 起经 `webStartup` 服务传给 `connection`。Host/Origin 检查失败返回 403，它只防 DNS 重绑定与跨站请求，不确立身份（第 11 章）。
- **Turn（轮）**：一次对已认领输入的完整排空，包含零到多个 step（`docs/glossary.md`，第 7 章）。
- **Typert**：从编译期类型图生成 RPC 契约的系统（第 12 章）。

## U

- **upgrade guide（升级指南）**：`docs/upgrade-guide/<版本>/<主题>/guide.md`（成对的 `guide.zh.md`），破坏性变更的官方迁移说明。目录按"**从哪个版本升级**"归档：在引入破坏的同一个 PR 里写、放在当时根版本的目录下，版本一升旧目录即冻结——所以 0.2.1-alpha.1 才删除的运行时不变式，指南位于 `v0.2.0-rc.2/remove-runtime-invariants/`。`verify-upgrade-guides` 校验布局、元数据、章节与字数上限，写作规则见 `.agents/skills/dsh-create-upgrade-guide/SKILL.md`（第 14 章）。

## W

- **waterfall**：分发模式，链式中间件，`next()` 委托或短路（第 5 章）。
- **WebBootGraph**：宿主生成、注入到页面 `window.__DSH_BOOT__` 的启动图（`{ rev, entries, batches }`，批次分 bootstrap 与 application），客户端插件据此经 combo 请求加载（第 11 章）。
- **webStartup**：`dsh-web-app` 的 `web-startup` 行（`@deepseek-ai/dsh-web-app/startup`）解析 `dsh web` 参数后提供的服务，携带 `openBrowser`、`host`、`port`、`publicUrl`、`tls`、`trustedHosts`；`webserver`、`web-runtime`、`connection` 都从它读取部署值。0.2.1-alpha.2 起它取代了 `webRuntime` 服务上的 `trustedHosts` / `lanAddresses`（第 11 章，附录 G）。
- **workflow（工作流）**：`ctx.workflowEngine`，模型写编排脚本、脚本中的 `agent()` 经子 Agent 扇出；执行后端 `workflow-ptc`（第 13 章）。
- **working directory（会话工作目录）**：0.2.1-alpha.2 新增的 `ctx.workingDirectory`（`@deepseek-ai/dsh-working-directory`，`get(session)` / `ensure(agent)` / `set(agent, path)`）与模型工具 `working_directory({ cd? })`（`dsh-tool-working-directory`），`dsh-base` 全局挂载。会话头 `cwd` 仍标识**原始项目**，`working-directory/change` 事件记录**当前目录**；相对路径、新启动的进程、指令与技能发现跟随当前目录，而沙箱可写根与项目归属仍锚定原始项目。旧的 `{{cwd}}` 提示变量和子 Agent `cwd` 配置键已删除（第 6、8、13 章）。
- **worktree（Git worktree）**：实验服务 `ctx.worktrees`（`@deepseek-ai/dsh-experimental-worktree`）与工具 `create_worktree`（`@deepseek-ai/dsh-experimental-tool-worktree`）：新建分支与 checkout（默认 `<当前 checkout 根>/.agents/worktrees/<name>`），再经工作目录服务切过去；自己不维护目录状态。通过 Git Worktrees 可选 bundle 启用（第 8、13 章）。

## 其他

- **`!!js`**：配置中的 JS 表达式标记，只在条目的 `config` 与 `disabled` 上求值（第 3 章）。
- **浏览器令牌认证**：每个进程生成一次随机启动令牌，`dsh web` 打印并打开 `…/?token=…`；首页用令牌换一个绑定 authority 的签名 Cookie（默认 30 天，HttpOnly、SameSite=Strict，监听器为 TLS 时再加 `Secure`）后重定向到干净的 `./`。缺少或无效 Cookie 的请求返回 401（第 11 章、附录 G）。
- **`~/.dsh`**：默认 Harness home。

## 已不再使用的旧术语

下列词在旧版（0.1.5、0.1.7-rc.2）书稿或文档中出现过，HEAD（0.2.1-alpha.2）中已删除、改名或搬家，读旧资料时注意换算：

| 旧术语 | 现状 |
| --- | --- |
| E2B provider（`packages/e2b`） | 已移除，远程执行改由 SSH runtime 承担 |
| code-runtime / `code-runtime-python` | 改名为 ptc-runtime / `ptc-runtime-python` |
| `assistant/chunk` | 不再是持久化事件，流内容内嵌在 `assistant/message.stream` |
| `packages/host/apiproxy`、`HOST_EVENTS_PATH` / `MUX_EVENTS_PATH` | 已删除，统一走 API Gateway 与 `/api/remote.mux` |
| `packages/activity` | 并入 `ctx.jobs` |
| `settings.yaml` | 只做一次性导入，设置由 profile 补丁承载 |
| 事务式 Loader | 回退为非事务式，失败由启动审计报告 |
| `telemetry/*` 事件 | 已删除；会话遥测走 `dsh-session-telemetry`，产品遥测走 `product-telemetry-otel`（注意：0.2.1-alpha.2 新增的 `telemetry` **分组**放的是 OTel 服务，与旧事件无关） |
| 运行时不变式：`@deepseek-ai/dsh-invariants`、`ctx.invariants`、`InvariantRegistry`、各包的 `<package>/invariant` 伴生插件、`runtime-diagnostics` 分组 | 0.1.7-rc.2、0.2.0-rc.2 中仍在，**0.2.1-alpha.1 删除**（升级指南 `v0.2.0-rc.2/remove-runtime-invariants`）；`sdk-minimal` 不再含 `invariants`、`session-invariant` 等五行，指向它们的补丁会记录 `patch: entry <id> not found`；对应的 `verify-package-invariants` 等脚本也已删除 |
| "自动化任务"可选 bundle `@deepseek-ai/dsh-experimental-schedule-bundle` | 0.2.1-alpha.1 退役（升级指南 `v0.2.0-rc.2/schedule-bundle-retired`）；加载 profile 时由 `RETIRED_BUNDLES` 自动移除，Web App 直接挂载 `schedule`，三个 preset 声明 `tool-schedule` |
| `@deepseek-ai/dsh-subagent-in-process-driver`、`startInProcessRun`、`tool-subagent` 的 `run_in_background` / `backgroundMode` / `enableRunInBackground`、`{ kind: 'background', jobId }` 结果 | 0.2.1-alpha.2 删除，子 Agent 统一为 activation（`startActivation()`，本地 provider 实现 `prepareContinuable()`） |
| `webRuntime` 服务上的 `trustedHosts`、`ctx.webRuntime.lanAddresses` | 0.2.1-alpha.2 由 `webStartup` 取代（升级指南 `web-listener-trust-config`）；仍注入 `webRuntime` 的补丁会让必需的 `connection` 一直等待 |
| `dsh web --host 0.0.0.0` / 局域网通配监听 | 加载时即被拒绝；改为绑定一个具体地址，或经反向代理 + `--public-url` / `--trusted-host` |
| Desktop 固定端口 19387 | 0.1.7-rc.2、0.2.0-rc.2 中使用；0.2.1-alpha.1 起改为系统分配端口 |
| `packages/hooks/*`、`packages/webhook/*` 分组，以及 `tool-terminal` / `tool-ralph` / `tool-session-query` 的旧路径 | 0.2.1-alpha.2 移入 `packages/experimental/`，**包名不变**；hooks/webhook 不再随 CLI 安装，需显式安装并组合 |
| `apps/cli/config/examples/github-review/` | 已删除，示例改由适配器随附：`packages/experimental/webhook-github/examples/github-review/` |
| `mode: both` / `DSH_TOOLS_MODE=both` / `ctx.tools.presentAs('both')` | 0.2.1-alpha.2 删除，只接受 `native` 或 `ptc` |
| `{{cwd}}` 提示变量、`subagent-acp` / `subagent-dsh-sdk` 的 `cwd` 配置键 | 0.2.1-alpha.2 删除，当前目录由 working directory 服务提供 |
| `agent-instructions` 行的 `dshHome` 字段 | 0.2.1-alpha.2 删除，指令加载只跟随 `DSH_HOME` / `~/.dsh` |
| Agent Teams 的 `maxPendingMessagesPerMember` | 0.2.1-alpha.2 删除，成员消息直接进目标 inbox |
| `dsh-ssh` 顶层 `node` / `bootstrapPath` / `bootstrapHash`、`dsh-ptc-runtime-node` 的 `nodeExecutable` / `bootstrapPath` | 0.2.1-alpha.2 改为 `launch` 配置与 `ctx.ssh.ptcLaunch` |
| `dsh plugin add <包> --profile <名字>`（`--profile` 写在后面） | 0.2.1-alpha.2 起报错，必须写成 `dsh plugin --profile <名字> add <包>` |

## 主题索引（按需求查找）

按"想解决什么问题"查术语（→ 指向术语表词条；括号内是全书章节）：

**插件开发**
- 想写一个插件 → Context / inject / Effect / Fiber / Entry（第 3 章）
- 想给模型加能力 → Tool / defineTool / Capability Seam / Consumer / tool presentation mode（第 8 章 + 附录 D）
- 想换实现 → Capability Seam / Provider / Bundle（第 8 章）
- 想加配置层 → Profile / Patch / insert / profile-owned live configuration（第 4 章）
- 想分发或安装插件 → Bundle / optional bundle / on-demand bundle / experimental package / compatibility.json / `dsh plugin --profile` 位置规则（第 4、14 章 + 附录 D）

**架构理解**
- 想理解加载顺序 → Bundle / Profile / Patch / `!!js` / Loader / profile resolution generation / RETIRED_BUNDLES（第 3、4 章）
- 想理解通信 → emit / waterfall / serial / bail / parallel / scope（第 5 章）
- 想理解会话 → Session / SessionEvent / surface / canonical envelope / session format v4 / plugin record / working directory / deriveMessages / compaction / fork（第 6 章）
- 想理解主循环 → Turn / Step / agent-loop / Agent / activation / Agent Teams（第 7 章）
- 想理解工具与接缝 → Tool / tool call three phases / dynamic tool updates / spill / PTC / working directory / worktree（第 8 章）
- 想理解模型接入 → StreamChunk / credentialRef / MISSING_CREDENTIAL / no-response / CoT 翻译（第 9 章）
- 想理解安全 → Sandbox / bwrap / Landlock / Seatbelt / enforcement / fail-closed / permission presets / approval / Auto review / BOOTSTRAP_NAMES（第 10 章）
- 想理解前端与部署 → WebBootGraph / API Gateway / remote.mux / 浏览器令牌认证 / listener trust / webStartup / public URL / TLS / trustedHosts / HMR / Desktop（第 11 章）
- 想理解 RPC → Typert / Remote / RemoteScope / SRC fallback（第 12 章）

**运维与调试**
- 报错排查 → `--dump-config` / `--dump-config-schema` / startup audit / fail-loud / fatal diagnostics / SANDBOX_UNAVAILABLE / MISSING_CREDENTIAL / no-response / credentialRef / cli-help（附录 G）
- 升级 → upgrade guide / 已不再使用的旧术语（第 14 章）
- 测试 → keyless 快照回放、质量门 `scripts/run-gates.ts`（第 14 章，未单列词条）
- 调试工具 → Inspector / Session Inspector / OTel（第 13、14 章）
- 性能 → compaction / spill / session format v4 / jobs seam / session search（附录 F）

**进阶能力**
- 委派 → Agent / activation / on-demand bundle / Agent Teams / lineage / fork（第 13 章）
- 程序化执行 → PTC / ptc-runtime / tool presentation mode / workflow / Ralph loop（第 13 章）
- 目标与后台 → goal / goal round / Schedule / jobs seam（第 13 章）
- 交付与外部世界 → deliverables / MCP / browser-use / computer-use / SSH runtime（第 13 章）
- 执行坐标与可观测 → working directory / worktree / OTel（第 13 章）
- 桥接 → hooks / Claude Code mods / experimental package（第 13 章）
- 产品扩展 → Agent preset / optional bundle / Auto review / CoT 翻译（第 13 章）
- 多入口 → ACP / Desktop / cli-help（第 13 章）

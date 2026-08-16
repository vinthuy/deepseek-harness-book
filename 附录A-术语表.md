# 附录 A 术语表

按首字母排序（中文按拼音就近）。

## A

- **ACP（Agent Client Protocol）**：自动化 Agent 接入协议。DSH 提供 `dsh-acp-demo` 作为 ACP 服务器，让外部产品把 DSH 当子 Agent 用。
- **Agent**：DSH 中一个活跃的智能体实体，拥有独立会话与上下文，注册在 `ctx.agents`。
- **agent-loop**：默认的主循环实现（`dsh-agent-loop`），驱动 turn/step 的插件。

## B

- **Bundle（插件包）**：“配置行 + 代码”的发行单元，声明在 package.json 的 `dsh.bundle` 字段。`dsh-base`、`dsh-web-app`、`dsh-headless` 是内置 bundle。
- **BFF**：Backend for Frontend，浏览器专用的后端聚合层（`packages/api`、`packages/host/apiproxy`）。

## C

- **Capability Seam（能力接缝）**：可替换能力的三角结构：服务定义 / Provider / Consumer。如 `ctx.fs`、`ctx.llm`、`ctx.sandbox`。
- **Cordis**：DSH 底层的插件框架（vendor 自 cordiverse/cordis），提供 Context、插件、类型化事件、可逆副作用。
- **Context**：Cordis 中的“服务仓库”，`ctx.<key>` 访问服务。
- **cordis.yml**：插件条目列表文件；patch 文件通过 `id` 覆盖条目。
- **Consumer**：使用接缝能力的一方，通常是模型工具（如 `tool-fs`）。

## D

- **DSH**：DeepSeek Harness 的缩写。
- **DSH_HOME**：Harness home 目录环境变量，默认 `~/.dsh`。
- **defineTool**：DSH 工具定义助手，负责参数校验、输出规范化、UI 呈现声明。

## E

- **Effect（副作用）**：`ctx.effect()` 注册的可逆行为，插件卸载时自动回滚。
- **emit**：事件分发模式之一，观察语义，不等待、无返回值。
- **Entry（条目）**：cordis.yml 里的一行插件声明（id + name + config）。

## H

- **Harness Home**：用户级状态目录（默认 `~/.dsh`），含 settings.yaml、profiles/、storages/。
- **HMR**：Hot Module Replacement，开发时热替换客户端插件。

## I

- **inject**：插件的依赖声明；框架保证依赖服务就绪后才加载插件。
- **insert**：patch 语法，插入新条目。

## L

- **Landlock**：Linux 内核 LSM 沙箱，DSH 通过 `landlock-run` 原生启动器使用。

## P

- **parallel**：事件分发模式，所有监听器并行执行。
- **Patch（补丁）**：按 id 整行替换条目 config，或 insert 新条目；应用顺序：bundle → profile patch → home patch → --patch。
- **Profile（配置组合）**：命名的启动配方，声明 bundles 与补丁层。`web`、`headless` 是内置 profile 模板（第 4 章）。
- **Provider（提供者）**：接缝的实现方，如 `dsh-fs-local`、`dsh-llm-deepseek`。

## R

- **Remote**：Typert 装饰器，把宿主方法暴露为远程 RPC。
- **RemoteScope**：Typert 装饰器，按作用域解析目标后调用。

## S

- **Seam**：见 Capability Seam。
- **serial**：事件分发模式，按注册顺序执行且有返回值。
- **Session（会话）**：一次交互过程，由追加式 `SessionEvent` 日志构成。
- **SessionEvent**：不可变会话事件（turn/start、assistant/chunk、tool/result 等）。
- **Step（步）**：一次模型请求 + 其工具调用。
- **StreamChunk**：LLM 流式协议的统一块类型。
- **SRC fallback**：源码启动时 Typert 的弱化描述符回退。
- **Schemastery**：DSH 使用的配置校验库（`z.object` 风格）。

## T

- **Tool（工具）**：模型可调用的函数，经 `ctx.tools` 管线执行。
- **Turn（轮）**：零到多个 step，从认领输入到没有欠账。
- **Typert**：编译期类型图 → RPC 契约的生成系统。

## W

- **waterfall**：事件分发模式，链式中间件，`next()` 委托/短路。

## 其他

- **`!!js`**：cordis.yml 中的 JS 表达式标记，加载时求值。
- **`__DSH_BOOT__`**：Web 页面里的启动清单（客户端插件入口图）。
- **`~/.dsh`**：默认 Harness home。

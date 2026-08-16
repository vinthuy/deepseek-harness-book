# 第 12 章 Typert：类型安全 RPC——让错误在构建时暴露

> 第 11 章末尾出现了一行调用：`ctx.remote.goals.create(agentId, ...)`——在浏览器里，它看起来像调用本地函数。这一章讲支撑它的系统：**Typert**。它把一个很老的工程难题（前后端类型不匹配）用很新的方式解决：从 TypeScript 类型图生成 RPC 契约。

## 12.1 先问"为什么"：前后端类型安全的痛点

浏览器要调宿主的业务方法（比如"给目标 goal 创建请求"）。朴素做法是手写 HTTP 接口 + 手写客户端类型——但这样会掉进三个坑：

- **类型漂移**：宿主改了方法签名，客户端还按老类型调用——编译期谁都不知道，运行时才炸；
- **复杂对象没法过线**：宿主里的 `Agent` 是一个活对象（有会话、有句柄），JSON 序列化不了；
- **校验写两遍**：宿主要校验参数，客户端也要校验——两份代码，两份 bug。

传统方案（tRPC、gRPC、OpenAPI）各有各的答案，但它们有个共同前提：**契约要单独声明**（手写 schema、手写 proto、手写 OpenAPI 文件）。Typert 的赌注是：**契约不需要单独声明——它就在 TypeScript 类型里**。

## 12.2 设计思考：为什么是"编译期类型图"而不是"运行时反射"？

既然类型已经在 TS 里了，为什么不直接在运行时读装饰器、推断类型，动态生成校验？原因有三：

1. **TS 类型在运行时不存在**：`interface Agent`、泛型、条件类型，编译后全没了。运行时反射只能拿到"装饰器上写了什么"，拿不到类型本身；
2. **可审计性**：运行时推断是"黑盒魔法"，错了你都不知道错在哪；编译期生成是"可检查的产物"——`lib/typert.remote-client.d.ts` 就摆在 build 产物里，你可以直接看客户端签名长什么样；
3. **构建期即校验**：生成器在构建时跑，签名不一致直接构建失败——**错误在 CI 里暴露，而不是在用户面前**。

代价也很明确：改签名必须重新构建（`pnpm run build:lib`），开发循环变重。DSH 的答案是一个折中：源码模式（SRC）有弱化 fallback（12.5 节）——开发时能跑，发布时严格。

## 12.3 声明一个 Remote 方法：代码在回答什么

```ts
export class GoalService extends TypertRemoteService {
  constructor(ctx: Context) {
    super(ctx, 'goals') // 绑定服务键 'goals'
  }

  @Remote('create')
  createForClient(agent: Agent, request: CreateGoalRequest, signal: AbortSignal): CreateGoalResult {
    signal.throwIfAborted()
    return this.create(agent, request)
  }
}
```

四个要点，每个都在回答一个设计问题：

- `@Remote('create')`：把 `createForClient` 暴露为远程方法 `goals.create`——**方法名和远程名解耦**，宿主侧可以起更描述性的名字；
- 参数里的 `Agent` 是复杂对象，不能直接过线：它被映射成线上的 `agentId`（通过 `TypertLookupMap` 声明关联），网关在宿主侧把 id 解析回真实对象——**线路上只有 id，对象永远留在宿主**；
- 最后一个 `signal: AbortSignal` 参数是约定的取消通道，不进参数列表，客户端可选传——**取消是协议的一部分，不是事后补丁**；
- `@RemoteScope('agent', 'current')`（另一个装饰器）：先在作用域上下文里解析出目标（如"当前 agent"），再调服务——适合依赖会话级组合的方法。

## 12.4 生成器：编译期类型图

`packages/typert/generator` 是 Typert 的大脑，构建时运行：

1. **分析**：用独立的 `ts.Program`（`tsconfig.host.json` / `tsconfig.client.json`）分析整仓类型图，产出与编译器无关的 `FaceModel` / `TypeGraph` 数据（保留泛型、继承、条件类型、JSDoc）；
2. **校验**：默认 check 模式，语法/语义错误、缺失公开注解、私有跨包引用都直接失败——**生成器是构建期的类型检查器**；
3. **生成**：从模型产出可执行 JS（含 Zod codec）和 `.d.ts`，客户端契约固定为 `lib/typert.remote-client.*` 产物；
4. **发布**：包级 opt-in，业务包需要在 `package.json` exports 里公开 `./typert`（宿主）和 `./client/typert`（客户端）才参与生成。

### 设计思考："客户端只信构建产物"

Typert 有一个有意为之的严格：**客户端不从运行中的宿主发现装饰器——它只信任构建产物**。这意味着改装饰器/签名必须重新构建，不能"热发现"。为什么这么严格？因为"运行时发现"意味着客户端类型依赖宿主进程的状态——那是非确定性的，今天能用明天不能。构建产物是确定性的：同样的代码，永远生成同样的契约。**用一点构建时的不便，换运行时的确定性**——这是 Typert 最核心的取舍。

## 12.5 运行时网关：校验、解析、序列化

宿主侧，`ctx.typertGateway` 负责：

- 接收远程调用描述符，先校验参数（Zod codec）；
- 按 lookup 把线上 id（`agentId`/`sessionId`）解析成宿主对象；
- 调用业务方法，把返回值序列化回客户端；
- 卸载贡献时：移除描述符、中止在途调用、让已持有的陈旧句柄后续调用直接拒绝。

lookup 还有"冷恢复"语义：`agent`/`session` 的 id 如果是冷会话，会先自动 resume 再调用——**id 是持久的，对象是临时的，网关负责两者之间的桥**。

## 12.6 SRC 开发回退：开发时能跑，发布时严格

从源码启动（`node --import tsx/esm`）时不跑编译器插件，Typert 提供弱化 fallback：

- 从装饰器运行期记录 + 函数参数名推断临时描述符；
- 只支持简单参数名（命中 lookup 的 `agent`/`session` 用对应 id 字段）；
- 不支持解构、默认值、rest 参数、重复参数名；
- 客户端侧永远只用生成产物，不用 SRC 描述符。

这个 fallback 的边界划得很清楚：**开发体验可以打折，生产契约不打折**。

## 12.7 与同类方案的对照：tRPC / gRPC / OpenAPI

| | Typert | tRPC | gRPC | OpenAPI/REST |
| --- | --- | --- | --- | --- |
| 契约来源 | TS 类型图（编译期生成） | TS 类型（运行时推导） | 手写 .proto | 手写 OpenAPI |
| 类型安全 | 构建期强校验 | 强（但运行时推导） | 强（代码生成） | 弱（靠工具链） |
| 复杂对象 | lookup 映射 id | 需自行序列化 | message 定义 | JSON 手动映射 |
| 跨语言 | 否（TS 专属） | 否（TS 专属） | 是 | 是 |

Typert 的定位很明确：**为 TS 全栈的复杂对象映射而生**。它放弃了跨语言，换来了"类型即契约"的零声明成本和 lookup 的对象桥。选型口诀：TS 全栈且对象复杂 → Typert/tRPC；需要跨语言 → gRPC；需要公共 API 给第三方 → OpenAPI。

## 12.8 动手实验

1. 在仓库里搜索 `@Remote(`，找 3 个真实 Remote 方法，读它们的参数和 lookup 用法（`rg "@Remote" packages -g "*.ts"`）；
2. 打开 `packages/api/remotes` 的包，理解它如何提供 `agentFor()` 冷恢复语义；
3. 改一个 Remote 方法的名字（比如加个 `2`），跑 `corepack pnpm run build:lib`，观察生成器报错并指明客户端契约不一致——**感受"编译期类型安全"**；
4. 构建后查看任意业务包的 `lib/typert.remote-client.d.ts`，看生成的客户端签名。

## 12.9 常见坑

- **改签名不重新构建**：客户端用的是构建产物，不 build 就"改了没生效"（或类型不匹配报错）；
- **把不该过线的对象放参数里**：只有声明了 lookup 的类型才能过线，其他必须是 JSON-safe 数据；
- **在 Remote 方法里做长任务**：Remote 是 unary 调用，长任务应该返回 job 句柄，让客户端轮询（第 13 章）；
- **绕过类型硬拼字符串调用**：等于放弃 Typert 的全部价值。

## 12.10 思考题

1. "客户端只信构建产物"换来了确定性。如果你要在运行时动态添加一个 Remote 方法（比如插件在运行时注册服务），Typert 支持吗？如果不支持，动态场景该怎么走？（提示：想想"契约"和"运行时注册"的矛盾）
2. lookup 把 `Agent` 映射成 `agentId`。如果方法需要传"一组 agent"呢？TypertLookupMap 能表达数组吗？这种"复杂对象过线"的问题，本质上是序列化的什么问题？
3. 对比表里 tRPC 是"运行时推导"、Typert 是"编译期生成"。你认为"推导"和"生成"哪个更可靠？各自的适用场景？（提示：想想第三方插件的类型谁维护）

## 小结

- Typert = 编译期类型图 → RPC 契约（Zod codec + 客户端桩），契约不需要单独声明；
- `@Remote`/`@RemoteScope` 声明，lookup 把宿主对象映射成线上 id；
- 生成器兼做构建期类型检查；客户端只信构建产物——用构建时的不便换运行时的确定性；
- 源码模式有 SRC fallback：开发时能跑，发布时严格。

下一章：进阶能力与生态——子 Agent、技能、工作流、外部协议，以及"让模型改自己运行时"的危险玩具。
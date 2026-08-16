# 第 11 章 Web 前端与宿主通信：前端也是插件

> 到这里，我们一直在看宿主这一侧。这一章看另一半：浏览器里的 Web UI 怎么和宿主通信。DSH 在这里有一个反直觉的设计——**前端本身也是插件**。理解它，你就理解了 DSH"一切皆插件"贯彻到底的决心。

## 11.1 先问"为什么"：前端为什么要做成插件？

大多数产品里，前端是"产品的一部分"：改一个按钮、加一个面板，就是改前端代码。DSH 的思路不同：**每个带 `dsh.client` 声明的包都向浏览器贡献一份客户端代码**，宿主启动时把它们组装成一个启动清单。

这意味着：加一个"目标管理"面板、加一个"技能库"界面，都像加工具一样——挂一个插件，而不是改前端仓库。**前端的功能边界，和宿主的功能边界一样，由插件集合决定。**这是"一切皆插件"在表现层的贯彻：连 UI 都是可组合的。

## 11.2 架构全景：两层、两条通道

DSH 的 Web 形态是典型的"浏览器前端 + Node 宿主"两层：

```text
浏览器（Web UI）
  │  HTTP /api（RPC）         WebSocket（事件下行）
  ▼
Node 宿主（dsh 进程）
  ├─ webServer       node:http 载体
  ├─ connection      /api 桥 + WS downlink + 信任围栏
  ├─ modules         客户端插件清单与 bundle 服务
  ├─ api-gateway     Typert RPC 网关
  └─ 业务插件树       会话/工具/模型/沙箱……
```

注意两条通道的分工：**HTTP /api 做"请求-响应"（RPC），WebSocket 做"事件下行"（推）**。为什么是两条而不是一条？因为这两类交互的语义不同：RPC 是"你问我答"（创建目标、获取列表），事件下行是"宿主主动通知"（新的 assistant/chunk 到了、工具结果好了）。把"问答"和"推送"分开，是通信架构的基本功。

## 11.3 webServer：极简 HTTP 载体——"我不懂业务，我只负责转发"

`packages/host/webserver` 是一个不关心业务概念的 `node:http` 服务：

- **命名路由注册表**：`register(route)`，支持精确匹配或前缀匹配（`route.kind` 区分）；
- **升级路由**：`registerUpgrade(route)`，支持 WebSocket/SSE 升级（`WebUpgradeRoute`）；
- **index transform tap**：`tapIndex(transform)`，渲染首页前允许注入内容——**启动清单就靠这个塞进去**；
- **fallback**：`registerFallback(handler)`，没人认领的路径落到静态资源兜底（Web 前端 dist）。

### 设计思考：为什么 webServer 要"不懂业务"？

webServer 只做三件事：路由、升级、兜底。它不知道"会话""工具""模型"是什么——业务模块（connection、modules、apiproxy）只是在它上面注册路由。这个"极简载体"的设计是有意的：**HTTP 基础设施（端口、路由、静态资源、WebSocket 升级）是稳定的，业务是易变的**。把稳定的放在核心、易变的放在外围，是经典的稳定-不稳定分层。你甚至可以写自己的 web-transport 插件，在同一个 webServer 上注册完全不同的路由。

## 11.4 connection：RPC 与事件下行 + 信任围栏

`packages/client/connection` 是前后端通信的核心：

- **HTTP /api**：浏览器发起 JSON RPC（unary 调用），有请求体大小上限、信任校验；
- **WebSocket downlink**：宿主把会话事件流、增量数据推给浏览器（`HOST_EVENTS_PATH`、`MUX_EVENTS_PATH`）；
- **信任围栏**：默认只信 loopback；`0.0.0.0` 部署必须显式声明 `trustedHosts`，否则 `/api` 拒绝请求——**防止 LAN 上的任意网页驱动你的 Agent**。

### 设计思考：信任围栏在防什么？

想象你在一台局域网机器上部署了 DSH，地址是 `192.168.1.5:3080`。如果没有信任围栏，局域网里任何人——或者任何被访问的恶意网页——都可以向 `/api` 发请求，命令你的 Agent 干活（包括读文件、跑命令）。信任围栏的答案是：**默认只信本机，要暴露出去必须显式声明谁可信**。这是"默认拒绝，按需放行"在网络安全层的又一次出现（第 10 章的哲学在这里复现）。

## 11.5 modules：客户端插件清单（__DSH_BOOT__）

浏览器一打开页面，`<head>` 里就有一段 `window.__DSH_BOOT__`，这是宿主生成的**启动清单**。你访问 `http://127.0.0.1:3080` 时看到的那个大 JSON 就是它。

它的工作方式（`packages/client/modules`）：

1. **扫描**：宿主启动时扫描 Loader 条目里带 `dsh.client` 声明的包（增量扫描，不是全量重扫）；
2. **构图**：按声明组装入口图：`inject`（依赖其他客户端包）、`immediately`（启动即预取）或懒加载；
3. **服务**：每个客户端包暴露为 `/plugins/<id>/client.js`（构建产物），浏览器按清单加载；
4. **HMR**：开发时客户端包重建，HMR 通知浏览器热替换对应插件。

包声明示例（package.json 的 `dsh` 字段）：

```json
{
  "dsh": {
    "client": {
      "platform": "web",
      "inject": ["@deepseek-ai/dsh-client-runtime"],
      "immediately": true
    }
  }
}
```

### 设计思考：为什么需要"启动清单"而不是"前端自己 import"？

如果前端是一个整体，它 import 什么由前端代码决定。但前端是插件集合时，**浏览器在运行时才知道有哪些客户端插件**——所以必须由宿主在启动时扫描并生成一份清单，告诉浏览器"去加载这些"。`__DSH_BOOT__` 的本质是：**把"哪些前端插件存在"这个事实，从编译期搬到了启动期**。这是"前端插件化"的必然产物，也是它最巧妙的地方。

## 11.6 API 层：BFF 与 Typert

业务能力对浏览器暴露的方式分两类：

- **RPC 方法**（unary）：走 Typert 网关，方法签名由编译期生成（第 12 章）；
- **流式协议**：会话事件、增量数据走 WebSocket 事件流，不属于 RPC 方法范畴。

浏览器端调用看起来是普通的类型安全函数：

```ts
await ctx.remote.goals.create(agentId, { objective: '发布 v1' })
```

宿主端一个 `@Remote` 装饰器 + 生成器，就同时产出了宿主实现、客户端类型和校验 codec。这就是第 12 章的主角。

## 11.7 动手实验：看启动清单

1. 启动 `dsh web` 后，用 curl 抓首页：

```powershell
curl.exe -s http://127.0.0.1:3080/ | Select-String __DSH_BOOT__
```

2. 数一数启动清单里有多少个客户端插件；哪些是 `immediately: true`（启动预取），哪些是懒加载；
3. 抓一个客户端 bundle 看看内容：

```powershell
curl.exe -s http://127.0.0.1:3080/plugins/@deepseek-ai/dsh-client-connection/client.js -o boot.js
(Get-Item boot.js).Length
```

4. 打开浏览器 DevTools → Network，刷新页面，观察 `client.js` 的加载顺序是否和清单的依赖关系一致。

## 11.8 常见坑

- **改动客户端包后没构建**：`/plugins/<id>/client.js` 是构建产物，改源码要重新 `pnpm run build`（开发模式用 HMR watcher）；
- **把敏感接口暴露成 unary RPC**：RPC 是给浏览器调的，权限校验要在宿主端做（approval/trustedHosts）；
- **在 webServer 里直接塞业务逻辑**：webServer 是通用载体，业务走 connection/modules/apiproxy 或你自己的 web-transport 插件。

## 11.9 思考题

1. "前端也是插件"让 UI 可组合，代价是什么？（提示：加载顺序、类型共享、构建复杂度——想想 `__DSH_BOOT__` 的启动期扫描）
2. 信任围栏默认只信 loopback。如果要在公网部署 DSH（比如给团队共享），你会怎么设计认证？trustedHosts 够吗？还缺什么？
3. WebSocket 事件下行让 UI 实时更新。如果不用 WebSocket 而用"轮询"，会失去什么？DSH 选 WebSocket 的深层原因是什么？（提示：事件流是持续的，不是偶发的）

## 小结

- 前端也是插件：`dsh.client` 声明 + 启动清单（`__DSH_BOOT__`）+ 按需加载 + HMR；
- webServer 是极简 HTTP 载体：register/registerUpgrade/tapIndex/registerFallback，稳定与易变分层；
- 通信双通道：HTTP /api 做 RPC，WebSocket 推事件流；信任围栏保护非 loopback 部署；
- 业务 RPC 走 Typert 类型安全网关——下一章的主角。
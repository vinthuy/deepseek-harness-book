# 附录 G 故障排查手册：从症状到根因

> 第 14 章给了"三板斧"方法论（配置 → 日志 → 源码），这个附录是它的速查版：**症状 → 可能原因 → 排查命令 → 修复**。遇到问题先查这里，再按三板斧深入。

## G.1 排查方法论：三句话

1. **先问系统以为自己在跑什么**——`--dump-config` 永远第一；
2. **再看事件流**——会话 JSONL 是"已发生的事实"，从最后一个事件往前找断点；
3. **最后才看源码**——用事件名/服务名 `rg` 定位，别从头读。

## G.2 启动类故障

| 症状 | 可能原因（按概率排序） | 排查命令 | 修复 |
| --- | --- | --- | --- |
| 端口被占，`dsh web` 起不来 | 上一个实例没退 / 别的程序占了 3080 | `Get-NetTCPConnection -LocalPort 3080` → 找 PID → `Stop-Process -Id <pid>` | 停掉占用进程，或改端口（patch webserver.port） |
| 启动即 fail-loud 报配置校验错误 | cordis.yml 条目 config 不合法 | 看完整报错（哪个 id、哪个字段）；`--dump-config` 看合成值 | 修正 patch；记得 patch 是整行替换（第 4 章） |
| `module not found` / 插件加载不到 | patch 的 name 与包名不一致 / 包没安装 | `dsh plugin --profile web list`；检查 `package.json` 的 name | 修正 name；`dsh plugin --profile web add <包>` |
| `pnpm 不是内部或外部命令` | 无全局 pnpm，build 脚本内部调了裸 pnpm | `Get-Command pnpm` | 用 `corepack pnpm` 或单独 `--filter @deepseek-ai/dsh-web-frontend run build`（第 2.4 节） |

## G.3 凭据与认证类故障

| 症状 | 可能原因 | 排查命令 | 修复 |
| --- | --- | --- | --- |
| `MISSING_CREDENTIAL` | 没设 Key / 凭据文件没有对应条目 | `$env:DEEPSEEK_API_KEY`；检查 `~/.dsh/.credentials.yaml` | 设环境变量或 .env（gitignored）；按请求解析，改了即生效（第 9.3 节） |
| 401 Unauthorized（git 推送） | **GitCode 已移除密码认证**，要用 Personal Access Token | `git credential fill` 重新录入 | 在 GitCode 设置生成 PAT，作为密码存入凭据（附录 D.9） |
| `MISSING_CREDENTIAL` 但 Key 已设 | 凭据引用（`credentialRef`）配错 / 环境变量没进进程 | 检查 adapter 配置的 credentialRef | 对齐 credentialRef 与凭据存储的键名 |

## G.4 模型与主循环类故障

| 症状 | 可能原因 | 排查命令 | 修复 |
| --- | --- | --- | --- |
| 模型从不调用工具 | 工具 schema 没进 system prompt / guard 拦了 | 看请求日志的 prompt 组装；`--dump-config | Select-String tool` | 检查 `ctx.systemPrompt` 组装；看 `agent/pre-step` 是否被改写 |
| 一个 turn 疯狂循环不停 | guard 没生效 / `agent/turn-stopping` 被绕过 | 看会话 JSONL 的 step 数；检查 `repeat-tool-reminder` 配置 | 调 `maxDepth`/guard 阈值；检查取消信号是否被响应 |
| 模型回复"工具不存在" | 工具名拼写与 schema 不符 / 工具被卸载 | `--dump-config` 里找工具条目 | 统一名称；检查插件是否因 effect 回滚被卸 |
| 请求超时 | `exec.signal` 未响应 / 模型侧延迟 | 看超时配置（`tool-call-timeout-policy`） | 遵守取消契约（第 7.8 节）；调大超时 |

## G.5 会话与持久化类故障

| 症状 | 可能原因 | 排查命令 | 修复 |
| --- | --- | --- | --- |
| 会话找不到 / 重启后历史消失 | 持久化后端没配 / root 路径错 | `--dump-config | Select-String persistence`；检查 `.sessions/` 目录 | 配 `persistence` 条目（JSONL 或 SQLite，第 6.4 节） |
| 重放结果与当初不一致 | 事件流被改 / 投影逻辑变了 | 对比会话 JSONL 与快照 | 日志是追加的，别改历史；fork 新分支（第 6.8 节） |
| 日志爆炸 / 磁盘暴涨 | spill 没生效 / compaction 没触发 | 看大输出是否落 spill；查 `thresholdRatio` | 检查 spill 阈值；调 compaction 参数（附录 F.1） |

## G.6 Web 前端类故障

| 症状 | 可能原因 | 排查命令 | 修复 |
| --- | --- | --- | --- |
| 页面白屏 | `__DSH_BOOT__` 没注入 / client.js 404 | `curl.exe -s http://127.0.0.1:3080/ | Select-String __DSH_BOOT__`；DevTools Network 看 client.js | 改了客户端包要重新 `pnpm run build`（第 11.8 节） |
| `/api` 请求被拒 | 信任围栏（非 loopback 未声明 trustedHosts） | `Get-NetTCPConnection -LocalPort 3080` 看监听地址 | `0.0.0.0` 部署要显式配 `trustedHosts`（第 11.3 节） |
| WebSocket 断连 | HMR 重载 / 代理 / 心跳 | DevTools Network → WS 帧 | 检查 HMR 配置；前端包热替换需 watcher 在跑 |

## G.7 沙箱与进程类故障

| 症状 | 可能原因 | 排查命令 | 修复 |
| --- | --- | --- | --- |
| 工具执行报"沙箱不可用" | 沙箱探测失败（runner 缺失/平台不支持） | 看 sandbox 条目配置；读 `sandbox-local` 顶部注释 | fail-closed 是设计：宁可拒绝不可裸奔（第 10 章）；装对应平台 runner |
| 僵尸进程 / 命令杀不掉 | `exec.signal` 没响应 / 进程树泄漏 | `Get-Process` 找残留；`Get-NetTCPConnection` | 遵守取消契约；长任务走 `ctx.jobs`（第 13.5 节） |
| 子进程能读到 Key | env 清洗没生效 | 检查 subprocess 环境（`scrubbedParentEnv`） | 凭据不进子进程环境是硬底线（第 10.5 节） |

## G.8 性能类故障（速查）

| 症状 | 可能原因 | 排查方向 |
| --- | --- | --- |
| 任务越来越慢 | 日志膨胀 / 无 compaction | 附录 F.1：检查 spill 与 compaction |
| 模型回合数过多 | 工具粒度太碎 | 合并工具 / 引导模型少走弯路（附录 F.6） |
| 启动慢 | 大量包全量加载 | 懒加载检查（附录 F.5） |
| 内存高 | 日志全在内存 / 大输出未 spill | 检查投影缓存与大输出路径（附录 F.1） |

## G.9 实战案例：推送 514 之谜（排查思路示范）

一次真实的排查过程，展示"三板斧 + 排除法"怎么用：

**症状**：`git push` 到 GitCode 报 `514 PostReceivePack: exit status 128`。

**排查链**：

1. **看配置/环境**：`git remote -v` 确认 URL 正确；`git credential fill` 确认凭据存在；
2. **排除仓库**：GET `info/refs` 返回 200（仓库可读）；换一个确定正常的仓库（reqmanpy）同样 514 → **不是仓库问题**；
3. **排除认证**：无认证/错误认证返回 401（提示"密码认证已移除，请用 PAT"）→ 认证通过了，凭据有效；
4. **排除传输**：试 Content-Type 变体——错误的 CT 返回 403、正确的 CT 进入 git 层返回 514 → **路由正常，失败在 git 处理层**；
5. **缩小范围**：`git-upload-pack`（读操作）POST 也 514 → 不是写权限问题，是所有 git POST 处理失败；
6. **结论**：服务端 git 命令 exit 128，最可能是**协议请求与服务端期望不符**（非标准客户端请求），或服务端对空仓库首次推送的特殊处理。

**启示**：514 这类"网关包装的错误"信息量极少，正确姿势是**用排除法逐步缩小范围**，而不是反复试同一个方向。遇到 GitCode 推送问题，优先确认：PAT 而非密码（G.3）、仓库已存在（G.2）、URL 无拼写错误。

## 小结

- 排查顺序：环境 → 仓库 → 认证 → 传输 → 协议（排除法）；
- 工具：`--dump-config`（配置真相）、会话 JSONL（事实流）、`rg`（源码定位）；
- 大部分 Agent 特有故障，根因在"契约没遵守"（取消信号、协议格式、凭据路径）或"配置没对齐"（patch 整行替换、credentialRef）。
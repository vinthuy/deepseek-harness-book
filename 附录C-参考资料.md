# 附录 C 参考资料

本附录列出的路径都相对于 DSH 仓库根目录，已按 HEAD（0.1.7-rc.2）逐条用 `git ls-files` 核实存在。官方文档大多有中文版：把 `xxx.md` 换成 `xxx.zh.md` 即可（`docs/` 下除 `AGENTS.md`、`docs/i18n/` 的几份翻译工作文件和 `cordis-api/inherited.md` 外都成对存在；设计笔记也有 `.zh.md`）。

## 仓库入口

- 仓库：`https://github.com/deepseek-ai/deepseek-harness`
- 项目说明：`README.md`（中文 `README.zh.md`）
- 贡献者/Agent 工作守则：`AGENTS.md`；贡献流程：`CONTRIBUTING.md`
- 安全声明（沙箱实验性、未审计）：`SAFETY.md`
- CLI 参考（profile、层顺序、dump、插件管理、共享部署行为）：`apps/cli/reference/README.md`
- 文档站源码（VitePress）：`website/`

## 架构与核心文档（docs/）

- 架构总览：`docs/architecture.md`
- Cordis 入门：`docs/cordis-primer.md`；分步教程：`docs/cordis-tutorial/index.md`（01 第一个插件 … 07 进入 Harness）；API 参考：`docs/cordis-api/`（`context.md`、`events.md`、`fiber.md`、`service.md` 等）
- 能力接缝全表：`docs/capability-seams.md`
- 工具执行管线：`docs/tool-execution-pipeline.md`
- Agent 生命周期时序图：`docs/agent-lifecycle.md`
- 事件生产者/消费者矩阵（脚本生成）：`docs/event-producer-consumer.md`
- API Gateway（一元调用、`/api/remote.mux`、双向流）：`docs/api-gateway.md`
- 会话格式状态（finalized / released 版本）：`docs/session-format-status.md`；持久化事件目录：`docs/persistence-catalog.md`
- 配置目录（每个插件可配字段，脚本生成）：`docs/config-catalog.md`
- 工具目录：`docs/tool-catalog.md`
- 术语表：`docs/glossary.md`
- 模型请求扩展线路格式：`docs/deepseek-llm-api-wire-extensions.md`
- 开发与测试：`docs/development.md`、`docs/testing.md`、`docs/defensive-patterns.md`
- 模块图与图谱：`docs/module-graph.md`、`docs/graph-atlas.md`
- 事故复盘：`docs/postmortem/README.md`（如 `0004-landlock-partial-notice-misclassified-child-failures.md`）

## 用户文档（docs/user/）

- 入口：`docs/user/index.md`
- 使用指南：`docs/user/guide/index.md`，专题有 `providers.md`（模型提供商）、`network-proxy.md`（出站代理）、`python-sdk.md`、`schedule.md`（定时提醒）、`mcp-memory.md`、`github-review.md`
- 开发者学习路径：
  - 基础：`docs/user/develop/basic/index.md`（`config.md` → `tool.md` → `publish.md`）
  - 框架：`docs/user/develop/framework/index.md`（`service.md`、`events.md`）
  - 实践：`docs/user/develop/practice/index.md`（`llm-adapter.md`、`dynamic-cordis.md`）

## Cookbook 专题（docs/cookbook/）

- 扩展总览：`extension-cookbook.md`
- 新增包 / vendored 包：`adding-a-package.md`、`adding-a-vendored-package.md`
- 新增工具：`adding-a-tool.md`
- 新增 LLM 适配器：`adding-an-llm-adapter.md`
- 新增 Remote API：`adding-a-remote-api.md`
- 新增设置卡片：`adding-a-settings-card.md`
- 新增会话格式版本：`adding-a-session-format-version.md`；评审持久化类型变更：`reviewing-persistence-type-changes.md`
- 维护者流程：`maintaining-dsh-code-review.md`、`responding-to-pr-review-on-a-stack.md`

> 旧版书稿列出的 `adding-a-conversation-node.md` 已不存在。

## 子系统文档（docs/subsystems/）

总索引是 `docs/subsystems/README.md`。按本书章节归类：

- 启动与配置：`boot.md`、`settings.md`、`extensions.md`、`invariants.md`
- 会话（第 6 章）：`session.md`、`session-projection.md`、`session-query.md`、`session-reference.md`、`session-title.md`、`session-telemetry.md`、`persistence.md`、`compaction.md`、`spill.md`、`storage.md`
- 主循环与模型（第 7、9 章）：`core.md`、`llm-streaming.md`、`token-meter.md`、`system-prompt.md`、`credentials.md`
- 工具（第 8 章）：`tools.md`、`filesystem.md`、`shell.md`、`terminal.md`、`jobs.md`、`ptc-runtime.md`、`mcp.md`、`lsp.md`、`commands.md`、`todo.md`、`user-questions.md`
- 安全（第 10 章）：`sandbox.md`、`subprocess.md`、`approval.md`、`permission-presets.md`、`ssh.md`
- 前端（第 11、12 章）：`web-server.md`、`web-client.md`、`web.md`、`client-modules.md`、`client-resources.md`、`conversation.md`、`slots.md`、`sidebar-right.md`、`typert.md`
- 进阶能力（第 13 章）：`subagent.md`、`skills.md`、`workflow.md`、`plan.md`、`goal.md`、`schedule.md`、`deliverables.md`、`office-to-pdf.md`、`browser-use.md`、`computer-use.md`、`agent-team.md`、`voice-input.md`、`webhook.md`、`workspace.md`、`scope.md`、`attachment.md`、`feedback.md`、`product-telemetry.md`

> 旧版书稿"更多"清单里的 `telemetry` 已拆成 `session-telemetry.md` 与 `product-telemetry.md`。

## 示例与可运行素材

顶层 `examples/` 目录已在提交 `4125514a08`（`refactor(repo): retire top-level examples`）中整体退役，旧版书稿提到的 `headless-agent/`、`web-cordis/`、`acp-agent/`、`jsonrpc-agent/`、`mcp-memory/` 都不再位于那里。现在可以参考：

- `apps/cli/config/examples/github-review/`：GitHub 评审 webhook 组合（配合 `docs/user/guide/github-review.md`，用 `--patch` 叠加）
- `apps/cli/config/examples/mcp-memory/`：三种 MCP 记忆服务器的组合示例（配合 `docs/user/guide/mcp-memory.md`）
- `python/sdk/examples/minimal.py`（说明见 `python/sdk/examples/README.md`）：Python SDK 最小程序
- `packages/bundle/*/cordis.patch.yml`、`packages/bundle/web-app/presets/*.patch.yml`：内置组合包与 Web preset 的真实装配
- `snapshots/`：keyless 快照场景（`snapshots/session`、`sdk`、`acp`、`web`，说明见 `snapshots/AGENTS.md`）
- `benchmarks/`：仓库级性能门（说明见 `benchmarks/AGENTS.md` 与各场景 `README.md`，附录 F）

## 设计笔记（.agents/notes/）

设计笔记是理解"为什么这样做"的一手资料，按状态分为 `implemented/`、`proposed/`、`archived/`、`rejected/`，每个目录下再按 `architecture/`、`feature/`、`bug-fix/`、`simplification/`、`testing/`、`process/` 分类。下面按章节列出本书重写时引用最多的笔记（均在 `.agents/notes/implemented/` 下）：

- 配置与 profile（第 4 章）：`architecture/2026-09-09-profile-resolution-generations.md`、`architecture/2026-09-19-profile-resolution-lookup-order.md`、`architecture/2026-09-19-profile-owned-live-configuration.md`、`architecture/2026-09-18-declarative-agent-presets.md`、`architecture/2026-09-21-experimental-capabilities-as-optional-bundles.md`、`feature/2026-09-20-config-schema-dump-validation-policy.md`
- 会话（第 6 章）：`architecture/2026-09-06-v3-canonical-session-envelopes.md`、`architecture/2026-09-15-first-class-tool-role-messages.md`、`architecture/2026-09-17-native-v4-read-validation.md`
- 工具（第 8 章）：`architecture/2026-09-03-jobs-seam-consolidation.md`、`architecture/2026-09-12-ptc-runtime-vocabulary.md`、`architecture/2026-09-20-dynamic-tool-updates.md`、`architecture/2026-09-22-tool-call-three-phases.md`、`feature/2026-09-12-mcp-resources-and-instructions.md`
- 远程执行（第 8、10、13 章）：`simplification/2026-09-11-remove-e2b-providers.md`、`architecture/2026-09-11-posix-ssh-runtime.md`
- 安全（第 10 章）：`feature/2026-09-19-windows-acl-mandatory-integrity-confinement.md`、`feature/2026-09-16-sandbox-same-mode.md`、`feature/2026-09-24-auto-review-user-approval-fallback.md`
- 前端与 Desktop（第 11 章）：`architecture/2026-08-24-browser-token-authentication.md`、`architecture/2026-09-19-remote-duplex-stream.md`、`architecture/2026-09-14-web-document-relative-app-routes.md`、`feature/2026-09-14-desktop-primary-runtime.md`
- 进阶能力（第 13 章）：`architecture/2026-09-12-browser-use-provider-registration.md`、`architecture/2026-09-12-computer-use-provider-registration.md`、`architecture/2026-09-13-workflow-ptc-sandbox-reuse.md`、`architecture/2026-09-16-host-schedule-storage.md`、`architecture/2026-09-18-agent-teams-single-bundle.md`
- 测试、调试与性能（第 14 章、附录 F/G）：`architecture/2026-09-22-fatal-diagnostics-and-crash-reports.md`、`testing/2026-09-04-session-open-performance-gate.md`、`testing/2026-09-06-backend-continuation-performance.md`、`testing/2026-09-06-frontend-performance-budgets.md`、`testing/2026-09-06-standard-hosted-benchmark-runner.md`

## 相关外部资源

- Cordis：`https://github.com/cordiverse/cordis`
- Cordis 论文（时空可组合性编程范式）：`https://github.com/cordiverse/paper`
- Agent Client Protocol：`https://agentclientprotocol.com/`
- Model Context Protocol：`https://modelcontextprotocol.io/`
- Landlock：`https://landlock.io/`
- DeepSeek 开放平台：`https://platform.deepseek.com`

## 本书

- 章节文件：书稿仓库 `deepseek-harness-book/` 根目录（即本目录）
- 建议阅读顺序：见 `README.md` 的阅读路线。

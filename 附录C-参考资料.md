# 附录 C 参考资料

本附录列出的路径都相对于 DSH 仓库根目录，已按 HEAD（0.2.1-alpha.2）逐条用 `git ls-files` 核实存在。官方文档大多有中文版：把 `xxx.md` 换成 `xxx.zh.md` 即可；每对译文旁还有一个 `xxx.i18n.yaml`，记录两种语言按章节对齐的配对指纹，由 `verify-translation-pairing` 检查（`docs/` 下除 `docs/AGENTS.md`、`docs/i18n/` 的几份翻译工作文件和 `docs/cordis-api/inherited.md` 外都成对存在；设计笔记和升级指南也有 `.zh.md`）。

> 相对上一版（0.1.7-rc.2）的路径变化：`docs/subsystems/invariants.md` 已删除（运行时不变式在 0.2.1-alpha.1 移除）；`apps/cli/config/examples/github-review/` 已删除，示例随 `webhook-github` 适配器发布；不少设计笔记从 `.agents/notes/implemented/` 归档到了 `.agents/notes/archived/`，下文都已改成当前位置。

## 仓库入口

- 仓库：`https://github.com/deepseek-ai/deepseek-harness`
- 项目说明：`README.md`（中文 `README.zh.md`）
- 贡献者/Agent 工作守则：`AGENTS.md`；贡献流程：`CONTRIBUTING.md`
- 安全声明（沙箱实验性、未审计）：`SAFETY.md`
- CLI 参考（profile、层顺序、dump、插件管理、启动诊断、共享部署行为）：`apps/cli/reference/README.md`
- CLI 完整帮助（脚本生成，启动器、`dsh plugin` 与各随附 profile 的 `--help` 原文）：`docs/cli-help.md`，由 `pnpm run gen-cli-help` 重新生成、`verify-cli-help` 检查是否过期
- 文档站源码（VitePress）：`website/`

## 升级指南（docs/upgrade-guide/）

破坏性变更的官方迁移说明，是从旧版本升级时最该先读的一类文档。路径形如 `docs/upgrade-guide/<版本>/<主题>/guide.md`，**按"从哪个版本升级"归档**：指南在引入破坏的同一个 PR 里写，放在当时根版本的目录下，版本一升旧目录即冻结。所以 `v0.2.0-rc.2/` 下的指南描述的是 0.2.1-alpha.1 才落地的变更，`v0.2.1-alpha.1/` 下的描述 0.2.1-alpha.2 的变更。写作规则见 `.agents/skills/dsh-create-upgrade-guide/SKILL.md`，校验脚本是 `verify-upgrade-guides`（第 14 章）。

- `v0.1.7-rc.2/`：`schedule-optional-bundle`、`transcript-view-legacy-normal`
- `v0.2.0-rc.2/`：`account-sign-in-errors`（登录错误码 `no-response`）、`bundled-python-tests`、`remove-runtime-invariants`、`schedule-bundle-retired`、`subpath-plugin-display-manifest`
- `v0.2.1-alpha.1/`：`deepseek-model-discovery`（无 Key 时模型目录为空）、`desktop-test-auth-popup`、`experimental-package-composition`（实验包的显式安装与组合）、`instruction-home-override`、`mock-messages-events`、`native-subagent-bundle-tools`、`new-session-generations`、`plugin-option-placement`（`dsh plugin --profile` 位置）、`python-optional-resources`、`python-ptc-sandbox`、`session-title-adapters`、`session-title-provider-strategy`、`ssh-helper-launch`、`subagent-activations`、`team-direct-inbox`、`terminal-command-labels`、`tool-presentation-mode`、`web-listener-trust-config`（`webStartup` 与具体监听地址）、`working-directory`

## 架构与核心文档（docs/）

- 架构总览：`docs/architecture.md`
- Cordis 入门：`docs/cordis-primer.md`；分步教程：`docs/cordis-tutorial/index.md`（01 第一个插件 … 07 进入 Harness）；API 参考：`docs/cordis-api/`（`context.md`、`events.md`、`fiber.md`、`registry.md`、`service.md` 等）
- 能力接缝全表：`docs/capability-seams.md`
- 工具执行管线：`docs/tool-execution-pipeline.md`
- Agent 生命周期时序图：`docs/agent-lifecycle.md`
- 事件生产者/消费者矩阵（脚本生成）：`docs/event-producer-consumer.md`
- API Gateway（一元调用、`/api/remote.mux`、双向流）：`docs/api-gateway.md`
- 会话格式状态（finalized / released 版本）：`docs/session-format-status.md`
- 持久化事件目录：`docs/persistence-catalog.md`；实验包插件记录（`plugin:` 前缀）目录：`docs/experimental-persistence-catalog.md`；v4 之内的同版本增补记录：`docs/persistence-changes/README.md`（如 `2026-09-13-working-directory.md`、`2026-10-07-title-reasoning-effort.md`）
- 配置目录（每个插件可配字段，脚本生成）：`docs/config-catalog.md`
- 工具目录：`docs/tool-catalog.md`
- 术语表：`docs/glossary.md`
- 模型请求扩展线路格式：`docs/deepseek-llm-api-wire-extensions.md`
- 开发与测试：`docs/development.md`、`docs/testing.md`、`docs/defensive-patterns.md`
- 模块图与图谱：`docs/module-graph.md`、`docs/graph-atlas.md`
- vendored 包改名映射（`@deepseek-ai` 作用域）：`docs/rescope.md`
- 事故复盘：`docs/postmortem/README.md`（如 `docs/postmortem/0004-landlock-partial-notice-misclassified-child-failures.md`）

## 用户文档（docs/user/）

- 入口：`docs/user/index.md`
- 使用指南：`docs/user/guide/index.md`，专题有 `providers.md`（模型提供商）、`network-proxy.md`（出站代理）、`public-deployments.md`（经反向代理公开 Web UI：`--public-url` 与 `--trusted-host`）、`python-sdk.md`、`schedule.md`（定时提醒）、`mcp-memory.md`、`github-review.md`（均在 `docs/user/guide/` 下）
- 开发者学习路径：
  - 基础：`docs/user/develop/basic/index.md`（`config.md` → `tool.md` → `publish.md`）
  - 框架：`docs/user/develop/framework/index.md`（`service.md`、`events.md`）
  - 实践：`docs/user/develop/practice/index.md`（`llm-adapter.md`、`dynamic-cordis.md`）

## Cookbook 专题（docs/cookbook/）

- 扩展总览：`docs/cookbook/extension-cookbook.md`
- 新增包 / vendored 包：`adding-a-package.md`（含插件显示元数据格式）、`adding-a-vendored-package.md`
- 新增工具：`adding-a-tool.md`
- 新增 LLM 适配器：`adding-an-llm-adapter.md`
- 新增 Remote API：`adding-a-remote-api.md`
- 新增设置卡片：`adding-a-settings-card.md`
- 新增会话格式版本：`adding-a-session-format-version.md`；评审持久化类型变更：`reviewing-persistence-type-changes.md`
- 维护者流程：`maintaining-dsh-code-review.md`、`responding-to-pr-review-on-a-stack.md`

> 旧版书稿列出的 `adding-a-conversation-node.md` 已不存在。

## 子系统文档（docs/subsystems/）

总索引是 `docs/subsystems/README.md`。按本书章节归类（文件都在 `docs/subsystems/` 下）：

- 启动与配置（第 3、4 章）：`boot.md`、`settings.md`、`extensions.md`
- 会话（第 6 章）：`session.md`、`session-projection.md`、`session-query.md`、`session-reference.md`、`session-title.md`、`session-telemetry.md`、`persistence.md`、`compaction.md`、`spill.md`、`storage.md`、`working-directory.md`
- 主循环与模型（第 7、9 章）：`core.md`、`llm-streaming.md`、`token-meter.md`、`system-prompt.md`、`credentials.md`
- 工具（第 8 章）：`tools.md`、`filesystem.md`、`shell.md`、`terminal.md`、`jobs.md`、`ptc-runtime.md`、`mcp.md`、`lsp.md`、`commands.md`、`todo.md`、`user-questions.md`、`worktrees.md`
- 安全（第 10 章）：`sandbox.md`、`subprocess.md`、`approval.md`、`permission-presets.md`、`ssh.md`
- 前端（第 11、12 章）：`web-server.md`、`web-client.md`、`web.md`、`client-modules.md`、`client-resources.md`、`conversation.md`、`slots.md`、`sidebar-right.md`、`typert.md`
- 进阶能力（第 13 章）：`subagent.md`、`skills.md`、`workflow.md`、`plan.md`、`goal.md`、`schedule.md`、`deliverables.md`、`office-to-pdf.md`、`browser-use.md`、`computer-use.md`、`agent-team.md`、`voice-input.md`、`webhook.md`、`claude-code-mods.md`、`translation.md`、`workspace.md`、`scope.md`、`attachment.md`、`feedback.md`
- 可观测（第 13、14 章）：`otel.md`（`ctx.otel` 通道工厂）、`product-telemetry.md`、`session-telemetry.md`

> 0.2.x 的增减：新增 `otel.md`、`translation.md`、`working-directory.md`、`worktrees.md`、`claude-code-mods.md`；删除 `invariants.md`。旧版书稿"更多"清单里的 `telemetry` 早已拆成 `session-telemetry.md` 与 `product-telemetry.md`。

## 示例与可运行素材

顶层 `examples/` 目录已在提交 `4125514a08`（`refactor(repo): retire top-level examples`）中整体退役，旧版书稿提到的 `headless-agent/`、`web-cordis/`、`acp-agent/`、`jsonrpc-agent/`、`mcp-memory/` 都不再位于那里。现在可以参考：

- `packages/experimental/webhook-github/examples/github-review/`：GitHub 评审 webhook 组合（`cordis.yml` + 规则模块）。0.2.1-alpha.2 起它随适配器包发布，要先把 `@deepseek-ai/dsh-webhook` 与 `@deepseek-ai/dsh-webhook-github` 装进 profile，再从 profile 的安装目录用 `--patch` 叠加，见 `docs/user/guide/github-review.md`；旧路径 `apps/cli/config/examples/github-review/` 已删除
- `apps/cli/config/examples/mcp-memory/`：三种 MCP 记忆服务器的组合示例（配合 `docs/user/guide/mcp-memory.md`）
- `python/sdk/examples/minimal.py`（说明见 `python/sdk/examples/README.md`）：Python SDK 最小程序
- `packages/bundle/*/cordis.patch.yml`、`packages/bundle/web-app/presets/*.patch.yml`：内置组合包与 Web preset 的真实装配
- `packages/experimental/*/cordis.patch.yml`：11 个随附可选 bundle 的装配（例如 `packages/experimental/session-search/cordis.patch.yml` 用隔离分组挂载自己的内存索引）
- `snapshots/`：keyless 快照场景（`snapshots/session`、`sdk`、`acp`、`web`，说明见 `snapshots/AGENTS.md`）
- `benchmarks/`：仓库级性能门（说明见 `benchmarks/AGENTS.md` 与各场景 `README.md`，附录 F）

## 设计笔记（.agents/notes/）

设计笔记是理解"为什么这样做"的一手资料，按状态分为 `implemented/`、`proposed/`、`archived/`、`rejected/`，每个目录下再按 `architecture/`、`feature/`、`bug-fix/`、`simplification/`、`testing/`、`process/` 分类。笔记开头的 `Status:` 行标明状态；`archived/` 里的笔记多数仍是 `Status: implemented`，只是被归档（带 `Archived:` 日期）——**归档不等于作废**，读的时候以正文为准。下面按章节列出本书引用最多的笔记，路径相对 `.agents/notes/`：

- 配置与 profile（第 4 章）：`implemented/architecture/2026-09-09-profile-resolution-generations.md`、`implemented/architecture/2026-09-19-profile-resolution-lookup-order.md`、`implemented/architecture/2026-09-19-profile-owned-live-configuration.md`、`implemented/architecture/2026-09-30-profile-package-refresh-and-manifest-invalidation.md`、`implemented/architecture/2026-09-18-declarative-agent-presets.md`、`implemented/architecture/2026-09-21-experimental-capabilities-as-optional-bundles.md`、`implemented/process/2026-09-15-shipped-optional-bundles.md`、`implemented/architecture/2026-10-05-official-on-demand-bundles.md`、`implemented/feature/2026-09-20-config-schema-dump-validation-policy.md`
- 会话（第 6 章）：`implemented/architecture/2026-09-06-v3-canonical-session-envelopes.md`、`implemented/architecture/2026-09-15-first-class-tool-role-messages.md`、`implemented/architecture/2026-09-17-native-v4-read-validation.md`、`implemented/architecture/2026-09-13-session-working-directory.md`、`implemented/process/2026-10-08-session-reader-compatibility-review.md`
- 主循环与委派（第 7、13 章）：`implemented/simplification/2026-09-17-unified-subagent-activations.md`、`implemented/simplification/2026-09-26-team-direct-inbox.md`
- 工具（第 8 章）：`implemented/architecture/2026-09-03-jobs-seam-consolidation.md`、`archived/architecture/2026-09-12-ptc-runtime-vocabulary.md`、`implemented/architecture/2026-09-20-dynamic-tool-updates.md`、`implemented/architecture/2026-09-22-tool-call-three-phases.md`、`implemented/architecture/2026-09-24-preparing-tool-arguments.md`、`implemented/simplification/2026-10-05-native-or-ptc-presentation.md`、`implemented/feature/2026-09-13-explicit-worktree-creation.md`、`archived/feature/2026-09-12-mcp-resources-and-instructions.md`
- 远程执行（第 8、10、13 章）：`implemented/simplification/2026-09-11-remove-e2b-providers.md`、`implemented/architecture/2026-09-11-posix-ssh-runtime.md`
- 安全（第 10 章）：`implemented/feature/2026-09-19-windows-acl-mandatory-integrity-confinement.md`、`archived/feature/2026-09-16-sandbox-same-mode.md`、`implemented/feature/2026-08-28-auto-review.md`、`implemented/feature/2026-09-24-auto-review-user-approval-fallback.md`
- 前端、部署与 Desktop（第 11 章）：`implemented/architecture/2026-07-28-api-browser-trust-boundary.md`、`implemented/architecture/2026-08-24-browser-token-authentication.md`、`implemented/architecture/2026-09-23-native-https-web-listener.md`、`archived/feature/2026-09-07-public-web-deployments.md`、`implemented/architecture/2026-09-19-remote-duplex-stream.md`、`implemented/architecture/2026-09-14-web-document-relative-app-routes.md`、`implemented/feature/2026-09-14-desktop-primary-runtime.md`
- 进阶能力（第 13 章）：`implemented/architecture/2026-09-12-browser-use-provider-registration.md`、`implemented/architecture/2026-09-12-computer-use-provider-registration.md`、`implemented/architecture/2026-09-13-workflow-ptc-sandbox-reuse.md`、`implemented/architecture/2026-09-16-host-schedule-storage.md`、`implemented/architecture/2026-09-24-preset-scoped-schedule-tools.md`、`archived/architecture/2026-09-18-agent-teams-single-bundle.md`、`implemented/architecture/2026-10-05-persistent-machine-translation.md`、`implemented/architecture/2026-10-05-paid-native-flash-reasoning-translation.md`、`implemented/feature/2026-09-24-session-inspector.md`、`implemented/architecture/2026-09-25-session-log-otel-byte-limits.md`
- 测试、调试与性能（第 14 章、附录 F/G）：`implemented/architecture/2026-09-22-fatal-diagnostics-and-crash-reports.md`、`implemented/process/2026-09-14-generated-cli-help-reference.md`、`implemented/testing/2026-09-04-session-open-performance-gate.md`、`implemented/testing/2026-09-06-backend-continuation-performance.md`、`archived/simplification/2026-09-06-agent-request-freeze-evidence.md`、`implemented/testing/2026-09-06-frontend-performance-budgets.md`、`archived/testing/2026-09-06-standard-hosted-benchmark-runner.md`、`implemented/testing/2026-09-28-session-corpus-performance.md`、`implemented/testing/2026-10-07-memory-limited-benchmarks.md`、`implemented/testing/2026-10-07-scaled-benchmark-report.md`

## 相关外部资源

- Cordis：`https://github.com/cordiverse/cordis`
- Cordis 论文（时空可组合性编程范式）：`https://github.com/cordiverse/paper`
- Agent Client Protocol：`https://agentclientprotocol.com/`
- Model Context Protocol：`https://modelcontextprotocol.io/`
- OpenTelemetry：`https://opentelemetry.io/`
- Landlock：`https://landlock.io/`
- DeepSeek 开放平台：`https://platform.deepseek.com`

## 本书

- 章节文件：书稿仓库 `deepseek-harness-book/` 根目录（即本目录）
- 建议阅读顺序：见 `README.md` 的阅读路线。

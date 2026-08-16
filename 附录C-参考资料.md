# 附录 C 参考资料

## 官方仓库与文档（随版本更新）

- 仓库：`https://github.com/deepseek-ai/deepseek-harness`
- 架构：`docs/architecture.md`
- 架构（中文）：`docs/architecture.zh.md`
- Cordis 入门：`docs/cordis-primer.md`
- 能力接缝图：`docs/capability-seams.md`
- Agent 生命周期时序图：`docs/agent-lifecycle.md`
- 事件生产者/消费者：`docs/event-producer-consumer.md`
- 配置目录：`docs/config-catalog.md`
- 工具目录：`docs/tool-catalog.md`
- 术语表：`docs/glossary.md`

## 开发者学习路径（官方）

- 基础：`docs/user/develop/basic/index.md`（配置 → 工具 → 发布）
- 框架：`docs/user/develop/framework/index.md`（服务、事件）
- 实践：`docs/user/develop/practice/index.md`（LLM 适配器）
- Web 指南：`docs/user/guide/index.md`

## Cookbook 专题

- 新增包：`docs/cookbook/adding-a-package.md`
- 新增工具：`docs/cookbook/adding-a-tool.md`
- 新增 LLM 适配器：`docs/cookbook/adding-an-llm-adapter.md`
- 新增对话节点：`docs/cookbook/adding-a-conversation-node.md`
- 扩展总览：`docs/cookbook/extension-cookbook.md`

## 子系统文档（docs/subsystems/）

- 会话：`session.md`、`session-projection.md`、`session-query.md`
- 主循环：`core.md`、`llm-streaming.md`、`tools.md`
- 沙箱：`sandbox.md`、`subprocess.md`、`terminal.md`
- 凭据与设置：`credentials.md`、`settings.md`
- 子 Agent：`subagent.md`
- Typert：`typert.md`
- 客户端模块：`client-modules.md`
- 更多：approval、attachment、compaction、feedback、filesystem、jobs、lsp、permission-presets、plan、schedule、scope、skills、spill、storage、telemetry、web、workflow、workspace……

## 示例（examples/）

- `headless-agent/`：一次性编码 Agent 的完整组合（含大量 `*.cordis.yml` 变体）
- `web-cordis/`：在 web profile 上挂 Cordis 工具的补丁示例
- `acp-agent/`：ACP 自动化 Agent 示例
- `jsonrpc-agent/`：JSON-RPC Agent 示例
- `mcp-memory/`：MCP 记忆插件示例

## 相关外部资源

- Cordis：`https://github.com/cordiverse/cordis`
- Cordis 论文（时空可组合性编程范式）：`https://github.com/cordiverse/paper`
- Landlock：`https://landlock.io/`
- DeepSeek 官方：`https://platform.deepseek.com`

## 本书

- 章节文件：`dsh-intro-book/`（本目录）
- 建议阅读顺序：见 `README.md` 的阅读路线。

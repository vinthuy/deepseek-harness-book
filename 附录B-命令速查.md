# 附录 B 命令速查

所有命令默认在 `deepseek-harness` 仓库根目录执行；本机没有全局 pnpm 时统一用 `corepack pnpm`。

## 环境与安装

```powershell
corepack pnpm --version              # 验证 corepack 可用（首次自动下载 pnpm）
git clone --depth 1 https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
corepack pnpm install                # 安装 900+ 依赖
corepack pnpm run build              # 完整构建（lib + web）
```

## 运行

```powershell
corepack pnpm dsh web                                   # 启动 Web UI（127.0.0.1:3080）
corepack pnpm dsh --profile headless 任务描述            # 一次性任务（需 API Key）
corepack pnpm dsh --profile web --patch .\my-patch.yml  # 带补丁启动
corepack pnpm dsh --profile web --dump-config           # 打印合成配置
npx @deepseek-ai/dsh web                                # 快速体验（不克隆源码）
```

## 验证与排查

```powershell
curl.exe -s -o NUL -w '%{http_code}' http://127.0.0.1:3080/   # 服务是否 200
Get-NetTCPConnection -LocalPort 3080                           # 谁在监听 3080
Stop-Process -Id <pid>                                         # 停止服务
Get-Content ~\.dsh\profiles\web\cordis.patch.yml               # 看 profile 补丁
```

## 测试与质量

```powershell
corepack pnpm run test             # vitest 单元测试
corepack pnpm run test:e2e         # 真实 API 测试（需 DEEPSEEK_API_KEY）
corepack pnpm run test:snapshot    # 无 Key 快照回放
corepack pnpm run test:snapshot:record  # 重新录制快照（需 Key）
corepack pnpm run typecheck        # tsc 全量类型检查
corepack pnpm run lint             # oxlint
corepack pnpm run hygiene          # knip + publint + 约束
```

## 开发

```powershell
corepack pnpm run build:lib        # 只构建库（改 Remote 签名后必跑）
corepack pnpm --filter @deepseek-ai/dsh-web-frontend run build  # 只构建 Web 前端
corepack pnpm run demo:cordis      # 演示“Agent 修改自身运行时”（需 Key，危险）
corepack pnpm run demo:acp         # ACP 自动化服务器（需 Key）
```

## 用户级目录（~/.dsh）

```text
~/.dsh/settings.yaml                       # 用户设置（可热加载）
~/.dsh/cordis.patch.yml                    # home 级补丁（跨 profile）
~/.dsh/profiles/web/cordis.patch.yml       # web profile 补丁
~/.dsh/storages/                           # 结构化数据
```

## 环境变量

| 变量 | 用途 |
| --- | --- |
| `DEEPSEEK_API_KEY` | DeepSeek API Key（headless/llm-deepseek 默认读取） |
| `DEEPSEEK_BASE_URL` | 覆盖 API 地址（默认官方公共 API） |
| `DSH_HOME` | 覆盖 Harness home（默认 `~/.dsh`） |
| `E2B_API_KEY` | E2B 远程沙箱（可选） |
| `DSH_SNAPSHOT` | 快照录制/回放模式 |

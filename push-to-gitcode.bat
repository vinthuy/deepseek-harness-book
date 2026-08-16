@echo off
REM ============================================================
REM  推送到 GitCode（deepseek-harness-book）
REM  凭据：本机 ~/.git-credentials 已存 gitcode.com 账号
REM  （GitCode 已移除密码认证，须使用 Personal Access Token，
REM   若推送报认证失败，请在 GitCode 设置中生成 token 后更新凭据：
REM   git credential-manager github login 或手动编辑 ~/.git-credentials）
REM ============================================================
cd /d %~dp0
echo.
echo === 推送到: https://gitcode.com/yongfeng9m-/deepseek-harness-book ===
echo.
git push -u origin master
if %errorlevel%==0 (
  echo.
  echo [OK] 推送成功！ 访问: https://gitcode.com/yongfeng9m-/deepseek-harness-book
) else (
  echo.
  echo [失败] 请检查：
  echo   1. 仓库是否已创建（https://gitcode.com/projects/new 空间 yongfeng9m-）
  echo   2. GitCode 已移除密码认证，须用 Personal Access Token：
  echo      GitCode 网页 → 设置 → 私人令牌 → 生成 token
  echo      然后更新凭据：
  echo      git credential fill  ^(protocol=https, host=gitcode.com, username=你的token用户名^)
)
pause

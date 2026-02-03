param([string]$ProjectName)

# 检查 uv 是否安装
if (-not (Get-Command "uv" -ErrorAction SilentlyContinue)) {
    Write-Host "⬇️ 未检测到 uv，正在安装..." -ForegroundColor Cyan
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    # 刷新环境变量以便当前会话可用
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","User") + ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine")
}

# 获取项目名称
if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Read-Host "请输入项目名称"
}

if ([string]::IsNullOrWhiteSpace($ProjectName)) { return }

Write-Host "🚀 创建项目: $ProjectName" -ForegroundColor Green
uv init $ProjectName
Set-Location $ProjectName
git init
uv python pin 3.12
uv sync

Write-Host "✅ 完成！请进入目录: cd $ProjectName" -ForegroundColor Green
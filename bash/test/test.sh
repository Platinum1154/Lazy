#!/bin/bash

# 获取项目名：如果命令行传入了参数就用参数，否则询问用户
PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    # 尝试从 tty 读取输入，以支持 curl | bash 模式下的交互
    read -p "请输入项目名称: " PROJECT_NAME < /dev/tty
fi

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ 错误: 未提供项目名称"
    exit 1
fi

echo "🚀 开始创建项目: $PROJECT_NAME"

# 检查 uv 是否安装，没安装则自动安装
if ! command -v uv &> /dev/null; then
    echo "⬇️ 未检测到 uv，正在安装..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.local/bin/env
fi

# 执行核心逻辑
uv init "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit
git init
uv python pin 3.12
uv sync

echo "✅ 完成！请执行: cd $PROJECT_NAME && uv run hello.py"
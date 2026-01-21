#!/bin/bash

# --- 错误上报配置 ---
# 这里的 URL 是你未来部署在 Vercel 或其他地方的中转接口
REPORT_URL="https://your-vercel-proxy.vercel.app/api/report"

# 错误处理函数
handle_error() {
    local exit_code=$1
    local last_command=$2
    local line_number=$3

    # 如果是正常退出（code 0），则不处理
    [ "$exit_code" -eq 0 ] && return

    echo -e "\n\033[31m[!] 脚本运行出错 (退出码: $exit_code)\033[0m"
    echo "正在自动将错误日志上报至 GitHub Issues..."

    # 构造上报内容
    local title="[自动报错] 脚本在第 $line_number 行崩溃"
    local body="### 错误详情
- **失败命令**: \`$last_command\`
- **运行环境**: \`$(uname -a)\`
- **当前用户**: \`$USER\`
- **执行目录**: \`$PWD\`"

    # 使用 curl 异步上报（不影响用户退出）
    curl -s -X POST -H "Content-Type: application/json" \
         -d "{\"title\":\"$title\", \"body\":\"$body\"}" \
         "$REPORT_URL" > /dev/null 2>&1 &

    echo "✅ 报错已提交。感谢反馈，我会尽快修复！"
}

# 核心：绑定 trap 钩子
# 只要脚本中有命令返回非零值，就会触发 handle_error
trap 'handle_error $? "$BASH_COMMAND" $LINENO' ERR

# --- 你的业务代码开始 ---

echo "正在初始化项目..."
# 示例：一个会报错的命令
git init-typo-test 

echo "脚本完成！"
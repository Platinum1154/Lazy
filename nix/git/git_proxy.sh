#!/bin/bash

# 默认代理地址
DEFAULT_PROXY="http://127.0.0.1:7897"

echo "--------------------------------"
echo "  Git 代理配置工具"
echo "--------------------------------"
echo "1) 设置代理"
echo "2) 取消代理"
echo "3) 查看当前配置"
read -p "请选择操作 [1/2/3]: " choice

case $choice in
    1)
        # 允许用户输入新的代理地址，回车则使用默认值
        read -p "请输入代理地址 (默认: $DEFAULT_PROXY): " input_proxy
        PROXY_ADDR=${input_proxy:-$DEFAULT_PROXY}
        
        git config --global http.proxy "$PROXY_ADDR"
        git config --global https.proxy "$PROXY_ADDR"
        echo "✅ 成功设置代理: $PROXY_ADDR"
        ;;
    2)
        git config --global --unset http.proxy
        git config --global --unset https.proxy
        echo "❌ 已取消全局代理"
        ;;
    3)
        HTTP_P=$(git config --global --get http.proxy)
        HTTPS_P=$(git config --global --get https.proxy)
        echo "当前 HTTP 代理: ${HTTP_P:-[未设置]}"
        echo "当前 HTTPS 代理: ${HTTPS_P:-[未设置]}"
        ;;
    *)
        echo "无效选项，退出。"
        ;;
esac
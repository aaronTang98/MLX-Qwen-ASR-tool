#!/bin/bash

# 颜色定义
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# 错误处理函数
error_exit() {
    echo -e "${RED}❌ 错误：$1${NC}"
    exit 1
}

# 信息输出函数
echo_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 卸载 MLX-Qwen3-ASR
uninstall_mlx_qwen3_asr() {
    echo ""
    echo "🗑️  MLX-Qwen3-ASR 卸载脚本"
    echo "====================================="
    
    # 确认卸载
    echo_warning "此操作将删除以下内容："
    echo "  1. 工作目录：~/mlx-qwen3-asr"
    echo "  2. .zshrc 中的快捷命令配置"
    echo "  3. 下载的模型文件（可选）"
    echo ""
    read -p "是否继续卸载？(y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo_info "已取消卸载"
        exit 0
    fi
    
    # 删除工作目录
    if [ -d ~/mlx-qwen3-asr ]; then
        echo_info "删除工作目录 ~/mlx-qwen3-asr..."
        rm -rf ~/mlx-qwen3-asr
        if [ $? -eq 0 ]; then
            echo_success "工作目录已删除"
        else
            error_exit "删除工作目录失败"
        fi
    else
        echo_warning "工作目录不存在，跳过"
    fi
    
    # 删除 .zshrc 中的配置
    if [ -f ~/.zshrc ]; then
        echo_info "清理 .zshrc 配置..."
        
        # 删除 alias
        sed -i '' '/alias asr=/d' ~/.zshrc
        
        # 删除函数定义（包括多行函数）
        sed -i '' '/^mlxasr()/,/^}/d' ~/.zshrc
        sed -i '' '/^asr()/,/^}/d' ~/.zshrc
        
        # 删除注释行
        sed -i '' '/# MLX-Qwen3-ASR 快捷命令/d' ~/.zshrc
        
        echo_success ".zshrc 配置已清理"
    fi
    
    # 询问是否删除模型文件
    echo ""
    read -p "是否删除下载的模型文件？(y/N): " delete_models
    
    if [[ "$delete_models" =~ ^[Yy]$ ]]; then
        if [ -d ~/.cache/huggingface/hub ]; then
            echo_info "删除 Hugging Face 缓存..."
            rm -rf ~/.cache/huggingface/hub
            echo_success "模型文件已删除"
        else
            echo_warning "模型缓存目录不存在，跳过"
        fi
    else
        echo_info "保留模型文件"
    fi
    
    # 显示完成信息
    echo ""
    echo "====================================="
    echo_success "卸载完成！"
    echo ""
    echo_info "已删除的内容："
    echo "  ✅ 工作目录 ~/mlx-qwen3-asr"
    echo "  ✅ .zshrc 中的快捷命令配置"
    
    if [[ "$delete_models" =~ ^[Yy]$ ]]; then
        echo "  ✅ 下载的模型文件"
    fi
    
    echo ""
    echo_info "请重新加载配置或重新打开终端："
    echo "  source ~/.zshrc"
    echo "====================================="
}

# 执行卸载
uninstall_mlx_qwen3_asr

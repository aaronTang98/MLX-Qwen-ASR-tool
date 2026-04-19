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

# 检查虚拟环境
check_venv() {
    if [ ! -d ~/mlx-qwen3-asr/venv ]; then
        error_exit "虚拟环境不存在，请先运行 ./install.sh 安装"
    fi
}

# 设置环境变量
setup_environment() {
    # 默认使用国内镜像
    if [[ -z "$HF_ENDPOINT" ]]; then
        export HF_ENDPOINT=https://hf-mirror.com
        echo_info "使用 Hugging Face 国内镜像：$HF_ENDPOINT"
    else
        echo_info "使用自定义 Hugging Face 镜像：$HF_ENDPOINT"
    fi
}

# 下载单个模型
download_model() {
    local model_name=$1
    local model_size=$2
    
    echo_info "开始下载 $model_name ($model_size)..."
    echo "下载过程中会显示进度，请耐心等待..."
    echo ""
    
    cd ~/mlx-qwen3-asr && source venv/bin/activate
    
    # 设置 Hugging Face 使用国内镜像
    export HF_ENDPOINT=https://hf-mirror.com
    
    # 创建一个空的临时文件用于触发下载
    # 只有提供音频文件才会触发模型下载，所以我们用空文件触发下载后立即删除
    echo "" > /tmp/mlx_qwen3_asr_empty_audio.wav
    
    # 触发模型下载 - 必须提供音频文件才会触发下载
    # 下载完成后程序会退出，我们删除临时文件
    python -m mlx_qwen3_asr --model "$model_name" /tmp/mlx_qwen3_asr_empty_audio.wav > /dev/null 2>&1
    rm -f /tmp/mlx_qwen3_asr_empty_audio.wav
    
    # 检查模型是否真的下载完成
    local model_slug=$(echo "$model_name" | sed 's/\//--/g')
    local model_dir=~/.cache/huggingface/hub/models--$model_slug
    
    if [ -d "$model_dir" ] && [ -d "$model_dir/blobs" ] && [ -n "$(ls -A $model_dir/blobs 2>/dev/null)" ]; then
        echo_success "$model_name 下载完成！"
        return 0
    else
        echo_warning "$model_name 下载可能不完整，请检查网络连接"
        return 1
    fi
}

# 清理不完整下载
cleanup_incomplete() {
    echo_info "检查并清理不完整的模型下载..."
    
    local cache_parent=~/.cache/huggingface
    local cache_dir=~/.cache/huggingface/hub
    
    if [ ! -d "$cache_parent" ]; then
        echo_info "创建缓存目录 $cache_parent"
        mkdir -p "$cache_parent"
    fi
    
    if [ ! -d "$cache_dir" ]; then
        echo_info "创建缓存目录 $cache_dir"
        mkdir -p "$cache_dir"
        echo_info "缓存目录不存在，无需清理"
        return
    fi
    
    # 删除不完整的模型目录
    for model in "models--Qwen--Qwen3-ASR-0.6B" "models--Qwen--Qwen3-ASR-1.7B"; do
        if [ -d "$cache_dir/$model" ]; then
            # 检查是否下载完整（简单检查：是否有 blobs 目录）
            if [ ! -d "$cache_dir/$model/blobs" ] || [ -z "$(ls -A $cache_dir/$model/blobs 2>/dev/null)" ]; then
                echo_warning "发现不完整的 $model，正在清理..."
                rm -rf "$cache_dir/$model"
                echo_success "清理完成"
            fi
        fi
    done
    
    echo_success "清理完成"
}

# 显示下载状态
show_download_status() {
    echo ""
    echo_info "当前下载状态："
    
    local cache_dir=~/.cache/huggingface/hub
    
    if [ ! -d "$cache_dir" ]; then
        echo "  ❌ 缓存目录不存在，尚未下载任何模型"
        echo ""
        return
    fi
    
    if [ -d "$cache_dir/models--Qwen--Qwen3-ASR-0.6B" ]; then
        local size=$(du -sh "$cache_dir/models--Qwen--Qwen3-ASR-0.6B" | cut -f1)
        echo "  ✅ Qwen/Qwen3-ASR-0.6B 已下载（$size）"
    else
        echo "  ❌ Qwen/Qwen3-ASR-0.6B 未下载"
    fi
    
    if [ -d "$cache_dir/models--Qwen--Qwen3-ASR-1.7B" ]; then
        local size=$(du -sh "$cache_dir/models--Qwen--Qwen3-ASR-1.7B" | cut -f1)
        echo "  ✅ Qwen/Qwen3-ASR-1.7B 已下载（$size）"
    else
        echo "  ❌ Qwen/Qwen3-ASR-1.7B 未下载"
    fi
    
    echo ""
}

# 主函数
main() {
    echo ""
    echo "🚀 MLX-Qwen3-ASR 模型下载脚本"
    echo "====================================="
    
    # 检查环境
    check_venv
    
    # 设置环境变量
    setup_environment
    
    # 清理不完整下载
    cleanup_incomplete
    
    # 显示当前状态
    show_download_status
    
    # 询问下载选项
    echo "请选择下载选项："
    echo "  1. 只下载默认模型（Qwen/Qwen3-ASR-0.6B，约 1.2GB）"
    echo "  2. 下载默认模型 + 1.7B 模型（约 1.2GB + 3.4GB = 4.6GB）"
    echo "  3. 只下载 1.7B 模型（约 3.4GB）"
    echo "  4. 只显示当前状态，不下载"
    echo ""
    read -p "请输入选项 (1/2/3/4): " choice
    
    case $choice in
        1)
            download_model "Qwen/Qwen3-ASR-0.6B" "1.2GB"
            ;;
        2)
            download_model "Qwen/Qwen3-ASR-0.6B" "1.2GB"
            download_model "Qwen/Qwen3-ASR-1.7B" "3.4GB"
            ;;
        3)
            download_model "Qwen/Qwen3-ASR-1.7B" "3.4GB"
            ;;
        4)
            echo_info "已退出，不进行下载"
            ;;
        *)
            error_exit "无效选项，请重新运行脚本"
            ;;
    esac
    
    # 显示最终状态
    show_download_status
    
    echo ""
    echo "====================================="
    echo_success "操作完成！"
    echo ""
    echo_info "现在可以使用 mlxasr 命令进行语音识别了："
    echo "  mlxasr 你的音频.mp3"
    echo "====================================="
}

# 执行主函数
main

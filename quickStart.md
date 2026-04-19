# MLX-Qwen3-ASR 安装与使用指南

## 📋 常用命令速查

| 场景 | 命令 |
|------|------|
| **基础转写** | `mlxasr 录音.mp3` |
| **保存到文件** | `mlxasr 录音.mp3 > 笔记.txt` |
| **带时间戳** | `mlxasr 录音.mp3 --timestamps > 笔记.txt` |
| **保存到目录** | `mlxasr 录音.mp3 --output-dir ./output` |
| **批量处理** | `mlxasr *.mp3 --output-dir 转写结果` |
| **使用 1.7B 模型** | `mlxasr 录音.mp3 --model Qwen/Qwen3-ASR-1.7B` |
| **指定语言** | `mlxasr 录音.mp3 --language zh` |
| **M4优化速度** | `mlxasr 录音.mp3 --num-threads 8` |
| **说话人分割** | `mlxasr 录音.mp3 --diarize` |
| **查看帮助** | `mlxasr --help` |
| **查看版本** | `mlxasr --version` |

## 一、环境要求

### 系统要求
- **操作系统**：macOS 14.0+ (Sonoma 或更高版本)
- **芯片**：Apple Silicon M系列芯片（M1/M2/M3/M4）
- **内存**：建议 8GB 以上（16GB 最佳）
- **存储空间**：至少 10GB 可用空间

### 硬件优化（M4芯片特定）
- M4芯片提供了更好的神经网络加速能力
- 支持更高的并行处理效率
- 推荐使用最新版本的 macOS 以获得最佳性能

## 二、安装方法

### 方法一：一键安装脚本（推荐）

1. **打开终端**
   - 在 Launchpad 中找到「终端」应用
   - 或使用 Spotlight 搜索：`Command + 空格`，输入「终端」

2. **执行安装脚本**
   ```bash
   # 进入安装目录
   cd /Users/tanglei/workspace/SREProject/MLX-Qwen3-ASR
   
   # 赋予脚本执行权限
   chmod +x install.sh
   
   # 运行安装脚本
   ./install.sh
   ```

3. **等待安装完成**
   - 脚本会自动安装 Homebrew、Python 3.12、ffmpeg
   - 创建虚拟环境并安装 MLX-Qwen3-ASR
   - 配置快捷命令

### 方法二：手动安装步骤

1. **安装 Homebrew**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **安装依赖**
   ```bash
   brew install python@3.12 ffmpeg
   ```

3. **创建工作目录**
   ```bash
   mkdir -p ~/mlx-qwen3-asr && cd ~/mlx-qwen3-asr
   ```

4. **创建虚拟环境**
   ```bash
   python3.12 -m venv venv
   source venv/bin/activate
   ```

5. **安装 MLX-Qwen3-ASR**
   ```bash
   # 使用国内镜像源（推荐，解决网络问题）
   pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
   pip install -U mlx mlx-qwen3-asr -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
   
   # 或使用默认源
   # pip install --upgrade pip
   # pip install -U mlx mlx-qwen3-asr
   ```

6. **配置快捷命令**
   ```bash
   # 添加函数到 .zshrc（使用 mlxasr 避免与系统 mlxasr 命令冲突）
   cat >> ~/.zshrc << 'EOF'
   
   # MLX-Qwen3-ASR 快捷命令
   mlxasr() {
       local CURRENT_DIR=$(pwd)
       cd ~/mlx-qwen3-asr && source venv/bin/activate
       cd "$CURRENT_DIR"
       python ~/mlx-qwen3-asr/venv/bin/mlx-qwen3-asr "$@"
   }
   EOF
   source ~/.zshrc
   ```

## 三、使用方法

### 基础功能

1. **基础语音转文字**
   ```bash
   mlxasr 你的录音文件.mp3
   ```

2. **转写并保存为文本**
   ```bash
   # 方法一：直接重定向输出到文件（推荐）
   mlxasr 录音.mp3 > 学习笔记.txt
   
   # 方法二：使用 --output-dir 指定输出目录
   mkdir -p 输出目录
   mlxasr 录音.mp3 --output-dir 输出目录
   ```

3. **带时间戳（适合网课 / 直播回看）**
   ```bash
   # 方法一：直接重定向输出到文件（推荐）
   mlxasr 录音.mp3 --timestamps > 笔记带时间戳.txt
   
   # 方法二：使用 --output-dir 指定输出目录
   mkdir -p 输出目录
   mlxasr 录音.mp3 --timestamps --output-dir 输出目录
   ```

4. **使用更精准的 1.7B 模型**
   ```bash
   mlxasr 录音.mp3 --model Qwen/Qwen3-ASR-1.7B
   ```

### 高级功能

1. **批量处理多个文件**
   ```bash
   mlxasr *.mp3 --output-dir 转写结果
   ```

2. **调整识别语言**
   ```bash
   mlxasr 录音.mp3 --language zh
   ```

3. **静音检测**
   ```bash
   mlxasr 录音.mp3 --detect-silence
   ```

## 四、支持格式

### 音频格式
- mp3
- wav
- m4a
- flac
- aac
- ogg
- wma

### 视频格式（自动提取音频）
- mp4
- mov
- avi
- mkv
- webm

## 五、性能优化（M4芯片）

### 内存优化
- 对于大文件，建议使用 `--chunk-size` 参数调整处理块大小
  ```bash
  mlxasr 长音频.mp3 --chunk-size 10
  ```

### 速度优化
- M4芯片支持更高的并行度，可使用 `--num-threads` 参数
  ```bash
  mlxasr 录音.mp3 --num-threads 8
  ```

### 质量优化
- 对于重要录音，使用更高质量的模型
  ```bash
  mlxasr 重要会议.mp3 --model Qwen/Qwen3-ASR-1.7B --beam-size 5
  ```

## 五.5 网络问题解决

### 模型下载失败（国内网络）

如果你在国内网络环境下遇到模型下载失败，可以设置 Hugging Face 镜像：

```bash
# 临时设置（当前终端生效）
export HF_ENDPOINT=https://hf-mirror.com

# 然后再运行命令
mlxasr 录音.mp3
```

如果需要永久设置，可以添加到 `.zshrc`：

```bash
echo 'export HF_ENDPOINT=https://hf-mirror.com' >> ~/.zshrc
source ~/.zshrc
```

**说明：**
- 一键安装脚本已经自动设置了国内镜像
- 手动安装时如果遇到下载问题，请手动设置上述环境变量

## 五.6 重新下载模型

如果模型下载失败或中断，可以使用独立的下载脚本重新下载：

### 使用方法

```bash
# 进入安装目录
cd /Users/tanglei/workspace/SREProject/MLX-Qwen3-ASR

# 赋予脚本执行权限
chmod +x download_models.sh

# 运行下载脚本
./download_models.sh
```

### 功能特性

- ✅ 自动使用 Hugging Face 国内镜像加速
- ✅ 自动清理不完整的下载文件
- ✅ 显示当前已下载模型的状态和大小
- ✅ 交互式选择下载选项

### 下载选项

运行脚本后会提示选择：

```
请选择下载选项：
  1. 只下载默认模型（Qwen/Qwen3-ASR-0.6B，约 1.2GB）
  2. 下载默认模型 + 1.7B 模型（约 1.2GB + 3.4GB = 4.6GB）
  3. 只下载 1.7B 模型（约 3.4GB）
  4. 只显示当前状态，不下载
```

### 使用场景

| 场景 | 操作 |
|------|------|
| 安装时模型下载失败 | 直接运行 `./download_models.sh` 重新下载 |
| 下载到一半中断 | 运行脚本自动清理不完整文件重新下载 |
| 想添加下载 1.7B 模型 | 运行脚本后选择选项 3 或 2 |
| 想查看已下载了哪些模型 | 运行脚本后选择选项 4 |
| 换了网络环境想重试 | 运行脚本选择对应选项 |

## 五.8 Web 界面使用

如果你更喜欢图形界面，可以使用 Web UI 在浏览器中操作：

### 启动 WebUI

```bash
# 进入项目目录
cd /Users/tanglei/workspace/SREProject/MLX-Qwen3-ASR

# 赋予执行权限
chmod +x run-webui.sh

# 启动 WebUI
./run-webui.sh
```

### 使用步骤

1. 启动后在浏览器打开 `http://localhost:8000`
2. 拖拽音频文件到上传区域
3. 选择模型，勾选是否需要时间戳
4. 等待识别完成
5. 复制结果或下载文本文件

### 功能特点

- 🎙️ 拖拽上传，支持点击选择
- 🎯 可选 0.6B/1.7B 模型
- ⏱️ 可选择输出时间戳
- 📊 实时显示进度
- 📋 一键复制结果
- ⬇️ 下载文本文件
- 🔒 完全本地处理，保护隐私

详细说明请查看 [webui/README.md](webui/README.md)。

## 六、常见问题与故障排除

### 安装问题

1. **Homebrew 安装失败**
   - 解决方案：检查网络连接，或使用国内镜像
   - 命令：`/bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"`

2. **Python 版本问题**
   - 解决方案：确保使用 Python 3.12+
   - 命令：`python3 --version`

3. **权限错误**
   - 解决方案：使用 sudo 或检查目录权限
   - 命令：`sudo chown -R $USER ~/mlx-qwen3-asr`

### 运行问题

1. **模型下载失败**
   - 解决方案：检查网络连接，或手动下载模型
   - 手动下载：访问 Hugging Face 下载模型到 `~/.cache/huggingface/hub`

2. **音频文件无法识别**
   - 解决方案：检查文件格式，或使用 ffmpeg 转换
   - 命令：`ffmpeg -i 原文件.mp3 -ac 1 -ar 16000 转换后文件.wav`

3. **内存不足错误**
   - 解决方案：使用更小的模型或调整 chunk 大小
   - 命令：`mlxasr 录音.mp3 --model Qwen/Qwen3-ASR-0.6B --chunk-size 5`

### 性能问题

1. **识别速度慢**
   - 解决方案：使用更小的模型，或调整线程数
   - 命令：`mlxasr 录音.mp3 --model Qwen/Qwen3-ASR-0.6B --num-threads 8`

2. **识别准确率低**
   - 解决方案：使用更大的模型，或调整 beam size
   - 命令：`mlxasr 录音.mp3 --model Qwen/Qwen3-ASR-1.7B --beam-size 5`

## 七、命令参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--model` | 模型名称 | `Qwen/Qwen3-ASR-0.6B` |
| `--output-dir` | 批量输出目录 | 当前目录 |
| `--output-format` | 输出格式 | `txt` |
| `--timestamps` | 添加时间戳 | `False` |
| `--diarize` | 说话人分割 | `False` |
| `--language` | 识别语言 | 自动检测 |
| `--num-speakers` | 说话人数量 | 自动检测 |
| `--chunk-size` | 处理块大小（秒） | `30` |
| `--num-threads` | 线程数 | 自动 |
| `--beam-size` | 波束搜索大小 | `3` |
| `--dtype` | 数据类型 | `float16` |
| `--max-new-tokens` | 每个块最大 token 数 | `4096` |

## 八、更新与维护

### 更新 MLX-Qwen3-ASR
```bash
# 进入虚拟环境
cd ~/mlx-qwen3-asr && source venv/bin/activate

# 更新包
pip install -U mlx-qwen3-asr
```

### 查看版本
```bash
mlxasr --version
```

## 九、卸载方法

如果需要卸载 MLX-Qwen3-ASR，请执行以下命令：

```bash
# 进入安装目录
cd /Users/tanglei/workspace/SREProject/MLX-Qwen3-ASR

# 赋予脚本执行权限
chmod +x uninstall.sh

# 运行卸载脚本
./uninstall.sh
```

卸载脚本会：
1. 删除工作目录 `~/mlx-qwen3-asr`
2. 清理 `.zshrc` 中的快捷命令配置
3. 可选删除下载的模型文件

## 十、注意事项

1. **隐私保护**：所有处理都在本地进行，不会上传到云端
2. **首次使用**：首次运行会下载模型，可能需要较长时间
3. **大文件处理**：大文件会分块处理，可能需要更多时间
4. **系统资源**：处理过程会占用较多 CPU 和内存资源

## 十、反馈与支持

- 项目地址：https://github.com/mlx-community/mlx-qwen3-asr
- 问题反馈：在 GitHub 上提交 Issue
- 讨论社区：加入相关技术社区交流

---

**提示**：M4芯片用户可以获得最佳性能体验，建议保持系统和软件的最新版本以获得更好的识别效果。
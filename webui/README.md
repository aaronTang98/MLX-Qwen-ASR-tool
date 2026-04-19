# MLX-Qwen3-ASR WebUI

基于 FastAPI 的轻量级 Web 界面，提供浏览器中上传音频并进行语音识别的功能。

## 功能特点

- 🎙️ **拖拽上传**：支持拖拽或点击选择音频文件
- 🎯 **模型选择**：可选 0.6B（更快）或 1.7B（更精准）模型
- ⏱️ **时间戳选项**：可选择输出包含时间戳
- 📊 **进度显示**：上传和识别进度实时显示
- 📋 **一键复制**：识别结果一键复制到剪贴板
- ⬇️ **下载结果**：支持下载文本文件
- 🔒 **隐私保护**：所有处理都在本地完成，不上传到云端
- 🎨 **现代界面**：简洁美观，响应式设计支持移动端

## 启动方法

```bash
# 进入项目目录
cd MLX-Qwen-ASR-tool

# 赋予执行权限
chmod +x run-webui.sh

# 启动 WebUI
./run-webui.sh
```

首次启动会自动安装依赖（fastapi, uvicorn, python-multipart），然后启动服务。

## 使用方法

1. 启动后，在浏览器中打开 `http://localhost:8000`
2. 拖拽音频文件到上传区域，或点击选择文件
3. 选择模型（0.6B/1.7B），勾选是否需要时间戳
4. 等待识别完成
5. 复制结果或下载文本文件

## 依赖要求

- 需要先完成 MLX-Qwen3-ASR 的安装
- 需要下载好模型文件（可以使用 `./download_models.sh` 下载）
- 额外依赖会在首次启动时自动安装

## 支持的文件格式

### 音频格式
- mp3, wav, m4a, flac, aac, ogg, wma

### 视频格式（自动提取音频）
- mp4, mov, avi, mkv, webm

## 端口自定义

如果需要修改默认端口 8000，可以修改 `webui/server.py` 最后一行：

```python
uvicorn.run(app, host="0.0.0.0", port=8000)
```

将 `8000` 改为你想要的端口。

## 故障排除

### 模型未下载

如果提示"模型未下载"，请先运行：

```bash
./download_models.sh
```

选择下载需要的模型。

### 依赖安装失败

如果自动安装失败，可以手动安装：

```bash
cd ~/mlx-qwen3-asr && source venv/bin/activate
pip install fastapi uvicorn python-multipart -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
```

### 无法连接

确保：
- 服务器已经启动
- 访问的地址是 `http://localhost:8000`
- 端口没有被防火墙阻挡

## 架构

- **后端**：Python + FastAPI，接收上传文件，调用 mlx-qwen3-asr 进行识别
- **前端**：原生 HTML + CSS + JavaScript，不需要框架
- **通信**：HTTP API，上传 -> 处理 -> 返回结果
- **所有处理都在本地完成**，保护隐私

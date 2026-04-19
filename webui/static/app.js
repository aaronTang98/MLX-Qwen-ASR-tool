const API_BASE = '';

const elements = {
    dropArea: document.getElementById('drop-area'),
    fileInput: document.getElementById('file-input'),
    selectBtn: document.getElementById('select-btn'),
    modelSelect: document.getElementById('model-select'),
    timestampsCheckbox: document.getElementById('timestamps-checkbox'),
    modelStatus: document.getElementById('model-status'),
    progressSection: document.getElementById('progress-section'),
    progressFill: document.getElementById('progress-fill'),
    progressText: document.getElementById('progress-text'),
    resultSection: document.getElementById('result-section'),
    resultContent: document.getElementById('result-content'),
    timeInfo: document.getElementById('time-info'),
    copyBtn: document.getElementById('copy-btn'),
    downloadBtn: document.getElementById('download-btn'),
    errorSection: document.getElementById('error-section'),
    errorContent: document.getElementById('error-content'),
};

let currentResult = '';

// 初始化
async function init() {
    await checkModelStatus();
    setupEventListeners();
}

// 检查模型状态
async function checkModelStatus() {
    try {
        const response = await fetch(API_BASE + '/api/status');
        const data = await response.json();
        
        if (data.success) {
            updateModelStatus(data.models);
        }
    } catch (error) {
        console.error('检查模型状态失败:', error);
    }
}

// 更新模型状态显示
function updateModelStatus(models) {
    const selectedModel = elements.modelSelect.value;
    const status = models[selectedModel];
    const statusEl = elements.modelStatus;
    
    if (status) {
        statusEl.innerHTML = '<span class="available">✅ 模型已下载</span>';
    } else {
        statusEl.innerHTML = '<span class="unavailable">❌ 模型未下载，请运行 ./download_models.sh 下载</span>';
    }
}

// 设置事件监听
function setupEventListeners() {
    // 拖拽上传
    elements.dropArea.addEventListener('dragover', handleDragOver);
    elements.dropArea.addEventListener('dragleave', handleDragLeave);
    elements.dropArea.addEventListener('drop', handleDrop);
    
    // 点击选择文件
    elements.selectBtn.addEventListener('click', () => {
        elements.fileInput.click();
    });
    
    // 文件选择变化
    elements.fileInput.addEventListener('change', handleFileSelect);
    
    // 模型选择变化
    elements.modelSelect.addEventListener('change', () => {
        checkModelStatus();
    });
    
    // 复制按钮
    elements.copyBtn.addEventListener('click', copyResult);
    
    // 下载按钮
    elements.downloadBtn.addEventListener('click', downloadResult);
}

function handleDragOver(e) {
    e.preventDefault();
    elements.dropArea.classList.add('drag-over');
}

function handleDragLeave(e) {
    e.preventDefault();
    elements.dropArea.classList.remove('drag-over');
}

function handleDrop(e) {
    e.preventDefault();
    elements.dropArea.classList.remove('drag-over');
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
        processFile(files[0]);
    }
}

function handleFileSelect(e) {
    const files = e.target.files;
    if (files.length > 0) {
        processFile(files[0]);
    }
}

async function processFile(file) {
    // 检查文件类型
    const allowedTypes = [
        'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav',
        'audio/m4a', 'audio/x-m4a', 'audio/flac', 'audio/x-flac',
        'audio/aac', 'audio/ogg', 'audio/x-ogg', 'audio/x-ms-wma',
        'video/mp4', 'video/quicktime'
    ];
    
    if (!allowedTypes.includes(file.type) && !file.name.match(/\.(mp3|wav|m4a|flac|aac|ogg|wma|mp4|mov)$/i)) {
        showError('不支持该文件格式，请上传音频文件');
        return;
    }
    
    // 显示进度
    showProgress();
    setProgress(0, '正在上传...');
    
    // 准备表单数据
    const formData = new FormData();
    formData.append('file', file);
    formData.append('model', elements.modelSelect.value);
    formData.append('with_timestamps', elements.timestampsCheckbox.checked);
    
    try {
        const xhr = new XMLHttpRequest();
        
        xhr.upload.onprogress = function(e) {
            if (e.lengthComputable) {
                const percent = (e.loaded / e.total) * 50;
                setProgress(percent, `上传中... ${Math.round(percent)}%`);
            }
        };
        
        xhr.onload = function() {
            setProgress(50, '识别中...');
            
            try {
                const result = JSON.parse(xhr.responseText);
                handleResult(result);
            } catch (e) {
                showError('解析响应失败: ' + e.message);
            }
        };
        
        xhr.onerror = function() {
            showError('网络错误，请检查服务器是否正在运行');
        };
        
        xhr.open('POST', API_BASE + '/api/transcribe', true);
        xhr.send(formData);
        
    } catch (error) {
        showError('上传失败: ' + error.message);
    }
}

function showProgress() {
    hideAllSections();
    elements.progressSection.style.display = 'block';
}

function setProgress(percent, text) {
    elements.progressFill.style.width = percent + '%';
    elements.progressText.textContent = text;
}

function handleResult(result) {
    hideAllSections();
    
    if (result.success) {
        currentResult = result.text;
        showResult(result.text, result.time_used);
    } else {
        showError(result.error || '未知错误');
    }
}

function showResult(text, timeUsed) {
    elements.resultSection.style.display = 'block';
    elements.resultContent.textContent = text;
    elements.timeInfo.textContent = `耗时: ${timeUsed.toFixed(2)} 秒`;
}

function showError(error) {
    hideAllSections();
    elements.errorSection.style.display = 'block';
    elements.errorContent.textContent = error;
}

function hideAllSections() {
    elements.progressSection.style.display = 'none';
    elements.resultSection.style.display = 'none';
    elements.errorSection.style.display = 'none';
}

async function copyResult() {
    if (!currentResult) {
        alert('没有可复制的内容');
        return;
    }
    
    try {
        await navigator.clipboard.writeText(currentResult);
        alert('已复制到剪贴板');
    } catch (error) {
        alert('复制失败: ' + error.message);
    }
}

function downloadResult() {
    if (!currentResult) {
        alert('没有可下载的内容');
        return;
    }
    
    const blob = new Blob([currentResult], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'transcription.txt';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', init);

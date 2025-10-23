// Espera a que el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    const fileInput = document.getElementById('fileInput');
    const uploadButton = document.getElementById('uploadButton');
    const statusText = document.getElementById('statusText');
    const previewImg = document.getElementById('preview');
    const labelList = document.getElementById('labelList');

    const API_ENDPOINT = "https://lrlrpg6klg.execute-api.us-east-1.amazonaws.com/prod";
    const IMAGE_BUCKET = window.IMAGE_BUCKET_NAME;

    uploadButton.addEventListener('click', async () => {
        const file = fileInput.files[0];
        if (!file) {
            updateStatus("Please select a file first.", "error");
            return;
        }

        labelList.innerHTML = '';
        previewImg.src = '';
        try {
            updateStatus("1/4 - Getting upload URL...");
            const uploadConfig = await getUploadURL();

            updateStatus("2/4 - Uploading image to S3...");
            await uploadFileToS3(uploadConfig.uploadURL, file);

            const imageURL = uploadConfig.uploadURL.split('?')[0];
            previewImg.src = imageURL;

            updateStatus("3/4 - Analyzing image with AI...");
            const analysisResult = await analyzeImage(uploadConfig.key);

            updateStatus("4/4 - Analysis complete!", "success");
            displayLabels(analysisResult.labels);

        } catch (error) {
            console.error("Process error:", error);
            updateStatus(`Error: ${error.message}`, "error");
        }
    });

    async function getUploadURL() {
        const response = await fetch(`${API_ENDPOINT}/upload-url`, {
            method: 'POST'
        });
        if (!response.ok) throw new Error("Could not get upload URL.");
        const data = await response.json();
        return { uploadURL: data.uploadURL, key: data.key };
    }

    async function uploadFileToS3(uploadURL, file) {
        const response = await fetch(uploadURL, {
            method: 'PUT',
            body: file,
            headers: { 'Content-Type': file.type }
        });
        if (!response.ok) throw new Error("Could not upload file to S3.");
    }

    async function analyzeImage(fileKey) {
        const response = await fetch(`${API_ENDPOINT}/analyze`, {
            method: 'POST',
            body: JSON.stringify({
                bucket: IMAGE_BUCKET,
                key: fileKey
            })
        });
        if (!response.ok) throw new Error("Could not analyze the image.");
        return await response.json();
    }

    function displayLabels(labels) {
        labelList.innerHTML = '';
        if (labels.length === 0) {
            labelList.innerHTML = '<li>No high-confidence labels found.</li>';
            return;
        }
        labels.forEach(labelText => {
            const li = document.createElement('li');
            li.textContent = labelText;
            labelList.appendChild(li);
        });
    }

    function updateStatus(message, type = "info") {
        statusText.textContent = message;
        statusText.className = type;
    }
});
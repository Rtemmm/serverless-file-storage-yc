<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Serverless Yandex File Storage</title>
  <style>
    body { font-family: sans-serif; margin: 2rem; }
    #file-list { margin-top: 2rem; }
    button { margin-left: 1rem; }
  </style>
</head>
<body>
  <h1>Upload File</h1>
  <input type="file" id="fileInput" />
  <button onclick="uploadFile()">Upload</button>

  <h2>Uploaded Files</h2>
  <ul id="file-list"></ul>

<script>
const uploadUrl = '${upload_url}';
const listUrl = '${list_url}';
const deleteUrl = '${delete_url}';
const downloadUrl = '${download_url}';

function uploadFile() {
  const file = document.getElementById('fileInput').files[0];
  if (!file) return alert('Choose a file first');

  const reader = new FileReader();
  reader.onloadend = () => {
    const base64data = reader.result.split(',')[1];

    fetch(`$${uploadUrl}?filename=$${encodeURIComponent(file.name)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/octet-stream' },
      body: base64data
    }).then(() => {
      alert('Uploaded!');
      loadFiles();
    });
  };
  reader.readAsDataURL(file);
}

function loadFiles() {
  fetch(listUrl)
    .then(res => res.json())
    .then(files => {
      const list = document.getElementById('file-list');
      list.innerHTML = '';
      files.forEach(name => {
        const li = document.createElement('li');
        li.textContent = name;

        const dlBtn = document.createElement('a');
        dlBtn.textContent = 'Download';
        dlBtn.href = `$${downloadUrl}?filename=$${encodeURIComponent(name)}`;
        dlBtn.style.marginLeft = '1rem';
        dlBtn.target = '_blank'; // откроется в новой вкладке

        const delBtn = document.createElement('button');
        delBtn.textContent = 'Delete';
        delBtn.onclick = () => {
          fetch(`$${deleteUrl}?filename=$${encodeURIComponent(name)}`, {
            method: 'DELETE'
          }).then(() => loadFiles());
        };

        li.appendChild(dlBtn);
        li.appendChild(delBtn);
        list.appendChild(li);
      });
    });
}

loadFiles();
</script>
</body>
</html>

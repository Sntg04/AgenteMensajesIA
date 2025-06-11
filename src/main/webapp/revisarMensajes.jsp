<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Revisar Mensajes</title>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/dashboard-styles.css">
    <style>
        .upload-form { margin-top: 20px; padding: 20px; border: 1px dashed #555; border-radius: 5px; background-color: #333; }
        .upload-form input[type="file"] { display: block; margin-bottom: 15px; color: #ccc; }
        .upload-form button { background-color: #ddd; color: #111; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; width: 100%; font-size: 16px; }
        .upload-form button:disabled { background-color: #555; cursor: not-allowed; }
        #uploadStatus { margin-top: 20px; padding: 15px; border-radius: 5px; display: none; text-align: center; }
        #uploadStatus.success { background-color: #28a745; color: white; }
        #uploadStatus.error { background-color: #d9534f; color: white; }
        #uploadStatus a { color: white; font-weight: bold; text-decoration: underline; margin: 0 10px; }
        .results-container { margin-top: 30px; }
        .stats-bar { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 20px; }
        .stat-card { background-color: #333; padding: 15px; border-radius: 5px; text-align: center; flex-grow: 1; min-width: 150px;}
        .stat-card h4 { margin: 0 0 10px 0; color: #ccc; font-weight: normal; }
        .stat-card p { margin: 0; font-size: 1.8em; font-weight: bold; color: #fff; }
        .filter-buttons { margin-bottom: 20px; }
        #exportFullReportBtn { float: right; }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <jsp:include page="sidebar-calidad.jsp" />
        <div class="main-panel">
            <jsp:include page="header.jsp" />
            <main class="content">
                <div class="content-section">
                    <h3>Analizar Archivo de Mensajes</h3>
                    <p>Selecciona un archivo Excel (.xlsx). Formato esperado: Columna A (Aplicación), H (Mensajes), J (Asesor), K (Fecha/Hora).</p>
                    <div class="upload-form">
                        <form id="uploadForm">
                            <input type="file" id="excelFile" name="file" accept=".xlsx, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" required>
                            <button type="submit" id="uploadButton">Subir y Analizar</button>
                        </form>
                    </div>
                    <div id="uploadStatus"></div>
                </div>

                <div id="resultsContainer" class="content-section hidden" style="margin-top: 30px;">
                    <h3>Resultados del Análisis</h3>
                    <button id="exportFullReportBtn" class="btn" style="display:none; padding: 10px 20px; float: right;">Exportar Reporte Completo</button>
                    <div id="statsBar" class="stats-bar" style="clear:both; padding-top:20px;"></div>
                    <div class="filter-buttons">
                        <button class="btn" id="filterTodos">Mostrar Todos</button>
                        <button class="btn" id="filterAlertas">Mostrar Solo Alertas</button>
                        <button class="btn" id="filterBuenos">Mostrar Solo Buenos</button>
                    </div>
                    <div id="resultsTableContainer"></div>
                </div>
            </main>
        </div>
    </div>

    <script>
        window.addEventListener('pageshow', function(event) { if (event.persisted) { window.location.reload(); } });
        const token = localStorage.getItem('jwtToken');
        const username = localStorage.getItem('username');
        const userRole = localStorage.getItem('userRole');
        const contextPath = "/AgenteMensajesIA";
        let currentMessages = [];
        let currentLoteId = null;

        if (!token || (userRole !== 'calidad' && userRole !== 'admin')) { 
            alert('Acceso no autorizado.'); window.location.href = contextPath + '/login.jsp'; 
        }

        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('usernameDisplay').textContent = username;
            document.getElementById('logoutButton').addEventListener('click', () => { localStorage.clear(); alert('Sesión cerrada.'); window.location.href = contextPath + '/login.jsp'; });
            document.getElementById('uploadForm').addEventListener('submit', handleUpload);
            document.getElementById('filterTodos').addEventListener('click', () => renderMessagesTable(currentMessages));
            document.getElementById('filterAlertas').addEventListener('click', () => renderMessagesTable(currentMessages.filter(m => m.clasificacion === 'Alerta')));
            document.getElementById('filterBuenos').addEventListener('click', () => renderMessagesTable(currentMessages.filter(m => m.clasificacion === 'Bueno')));
            document.getElementById('exportFullReportBtn').addEventListener('click', () => {
                if(currentLoteId) { exportFullReport(currentLoteId); }
            });
        });

        function handleUpload(event) {
            event.preventDefault();
            const fileInput = document.getElementById('excelFile');
            if (fileInput.files.length === 0) { alert('Por favor, selecciona un archivo.'); return; }
            const uploadButton = document.getElementById('uploadButton');
            const uploadStatusDiv = document.getElementById('uploadStatus');
            uploadButton.disabled = true;
            uploadButton.textContent = 'Procesando...';
            uploadStatusDiv.style.display = 'none';
            document.getElementById('exportFullReportBtn').style.display = 'none';
            
            const formData = new FormData();
            formData.append('file', fileInput.files[0]);
            
            fetch(contextPath + '/api/mensajes/upload', {
                method: 'POST',
                headers: { 'Authorization': 'Bearer ' + token },
                body: formData
            })
            .then(res => res.ok ? res.json() : res.json().then(err => Promise.reject(err)))
            .then(data => {
                const processedMessages = data.mensajes || [];
                currentLoteId = data.loteId;

                uploadStatusDiv.className = 'success';
                let successHtml = `¡Éxito! Se procesaron ${processedMessages.length} mensajes.`;
                if (currentLoteId) {
                    const tieneAlertas = processedMessages.some(m => m.clasificacion === 'Alerta');
                    successHtml += ` <br><a href="${contextPath}/reportes.jsp?lote=${currentLoteId}" target="_blank">Ver Reporte de Frecuencia</a>`;
                    if (tieneAlertas) {
                        successHtml += ` | <a href="${contextPath}/verAlertas.jsp?lote=${currentLoteId}" target="_blank">Ver Alertas de esta Carga</a>`;
                    }
                    document.getElementById('exportFullReportBtn').style.display = 'inline-block';
                }
                uploadStatusDiv.innerHTML = successHtml;
                uploadStatusDiv.style.display = 'block';

                currentMessages = processedMessages;
                updateStatistics(currentMessages);
                renderMessagesTable(currentMessages);
                document.getElementById('resultsContainer').classList.remove('hidden');
            })
            .catch(error => {
                uploadStatusDiv.className = 'error';
                uploadStatusDiv.textContent = 'Error: ' + (error.error || 'Verifique el formato del archivo.');
                uploadStatusDiv.style.display = 'block';
            })
            .finally(() => {
                uploadButton.disabled = false;
                uploadButton.textContent = 'Subir y Analizar';
                document.getElementById('uploadForm').reset();
            });
        }

        function exportFullReport(loteId) {
            const url = contextPath + '/api/mensajes/lote/exportar?lote=' + loteId;
            const exportButton = document.getElementById('exportFullReportBtn');
            const originalText = exportButton.textContent;
            exportButton.textContent = 'Generando...';
            exportButton.disabled = true;

            fetch(url, { method: 'GET', headers: { 'Authorization': 'Bearer ' + token } })
            .then(response => {
                if (!response.ok) { throw new Error('Error al generar el reporte.'); }
                return response.blob();
            })
            .then(blob => {
                const downloadUrl = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.style.display = 'none';
                a.href = downloadUrl;
                a.download = `reporte_completo_${loteId.substring(0,8)}.xlsx`;
                document.body.appendChild(a);
                a.click();
                a.remove();
                window.URL.revokeObjectURL(downloadUrl);
            })
            .catch(error => { alert('No se pudo descargar el reporte.'); console.error(error); })
            .finally(() => {
                exportButton.textContent = originalText;
                exportButton.disabled = false;
            });
        }

        function updateStatistics(messages) {
            const total = messages.length;
            const alertas = messages.filter(m => m.clasificacion === 'Alerta').length;
            const buenos = total - alertas;
            const porcentajeAlertas = total > 0 ? ((alertas / total) * 100).toFixed(1) : 0;
            const statsBar = document.getElementById('statsBar');
            statsBar.innerHTML = '<div class="stat-card"><h4>Total</h4><p>' + total + '</p></div>' +
                                 '<div class="stat-card"><h4>Buenos</h4><p>' + buenos + '</p></div>' +
                                 '<div class="stat-card"><h4>Alertas</h4><p>' + alertas + '</p></div>' +
                                 '<div class="stat-card"><h4>% Alertas</h4><p>' + porcentajeAlertas + '%</p></div>';
        }

        function renderMessagesTable(messages) {
            const container = document.getElementById('resultsTableContainer');
            let tableHtml = '<table><thead><tr><th>Asesor</th><th>Aplicación</th><th>Mensaje</th><th>Clasificación</th><th>Sugerencia</th><th>Fecha</th><th>Hora</th></tr></thead><tbody>';
            if (messages && messages.length > 0) {
                messages.forEach(msg => {
                    let fechaStr = msg.fechaMensaje || 'N/A';
                    let horaStr = msg.horaMensaje || 'N/A';
                    tableHtml += '<tr><td>' + escapeHtml(msg.nombreAsesor) + '</td><td>' + escapeHtml(msg.aplicacion) + '</td><td>' + escapeHtml(msg.textoOriginal) + '</td><td>' + escapeHtml(msg.clasificacion) + '</td><td>' + escapeHtml(msg.textoReescrito || '') + '</td><td>' + fechaStr + '</td><td>' + horaStr + '</td></tr>';
                });
            } else { tableHtml += '<tr><td colspan="7">No hay mensajes para mostrar.</td></tr>'; }
            tableHtml += '</tbody></table>';
            container.innerHTML = tableHtml;
        }
        function escapeHtml(unsafe) { return unsafe ? unsafe.toString().replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;") : ''; }
    </script>
</body>
</html>
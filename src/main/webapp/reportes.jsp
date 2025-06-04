<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Reportes y Estadísticas</title>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/dashboard-styles.css">
</head>
<body>
    <div class="dashboard-container">
        <%-- Incluimos una de las sidebars, la de calidad tiene más sentido en este contexto --%>
        <jsp:include page="sidebar-calidad.jsp" />

        <div class="main-panel">
            <jsp:include page="header.jsp" />

            <main class="content">
                <div id="reportContent" class="content-section">
                    <h3>Reporte de Frecuencia de Mensajes</h3>
                    <p>Este reporte muestra cuántas veces cada asesor ha enviado un mensaje idéntico para el lote de carga seleccionado.</p>
                    <a href="#" id="exportBtn" class="btn btn-create" style="display:none; text-decoration: none; padding: 10px 20px; float: right;">Exportar a Excel</a>
                    <div id="reporteContainer" style="clear:both; padding-top:20px;"><p>Cargando reporte...</p></div>
                    <div id="errorMessage" class="error"></div>
                </div>
            </main>
        </div>
    </div>

    <script>
        window.addEventListener('pageshow', function(event) { if (event.persisted) { window.location.reload(); } });
        const token = localStorage.getItem('jwtToken');
        const username = localStorage.getItem('username');
        const contextPath = '<%= request.getContextPath() %>'; 

        if (!token) { window.location.href = contextPath + '/login.jsp'; }

        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('usernameDisplay').textContent = username;
            document.getElementById('logoutButton').addEventListener('click', () => { localStorage.clear(); window.location.href = contextPath + '/login.jsp'; });
            
            const urlParams = new URLSearchParams(window.location.search);
            const loteId = urlParams.get('lote');
            const exportBtn = document.getElementById('exportBtn');

            if (loteId) {
                exportBtn.href = `${contextPath}/api/estadisticas/frecuencia-mensajes/exportar?lote=${loteId}`;
                exportBtn.style.display = 'inline-block';
                fetchReportData(loteId);
            } else {
                document.getElementById('reporteContainer').innerHTML = "<p>No se ha especificado un lote de carga. Por favor, suba un archivo desde la página 'Revisar Mensajes' y haga clic en el enlace del reporte.</p>";
            }
        });

        function fetchReportData(loteId) {
            const url = `${contextPath}/api/estadisticas/frecuencia-mensajes?lote=${loteId}`;
            const container = document.getElementById('reporteContainer');
            const errorDiv = document.getElementById('errorMessage');

            fetch(url, { headers: { 'Authorization': 'Bearer ' + token, 'Accept': 'application/json' } })
            .then(res => {
                if (!res.ok) { return Promise.reject(new Error(`Error ${res.status}`)); }
                return res.json();
            })
            .then(data => {
                let tableHtml = '<table><thead><tr><th>Asesor</th><th>Mensaje</th><th>Cantidad</th></tr></thead><tbody>';
                if (data && data.length > 0) {
                    data.forEach(stat => {
                        tableHtml += '<tr>' +
                                        '<td>' + escapeHtml(stat.nombreAsesor) + '</td>' +
                                        '<td>' + escapeHtml(stat.textoOriginal) + '</td>' +
                                        '<td>' + stat.cantidad + '</td>' +
                                     '</tr>';
                    });
                } else {
                    tableHtml += '<tr><td colspan="3">No hay datos de frecuencia para este lote.</td></tr>';
                }
                tableHtml += '</tbody></table>';
                container.innerHTML = tableHtml;
            })
            .catch(error => { 
                errorDiv.textContent = "Error al cargar el reporte."; 
                console.error("Error en fetchReportData:", error);
            });
        }
        function escapeHtml(unsafe) { return unsafe ? unsafe.toString().replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;") : ''; }
    </script>
</body>
</html>
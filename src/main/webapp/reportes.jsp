<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Reportes y Estadísticas</title>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/dashboard-styles.css">
</head>
<body>
    <div class="dashboard-container">
        <jsp:include page="sidebar-calidad.jsp" />
        <div class="main-panel">
            <jsp:include page="header.jsp" />
            <main class="content">
                <div id="reportContent" class="content-section">
                    <h3>Reporte de Frecuencia de Mensajes</h3>
                    <a href="#" id="exportBtn" class="btn btn-create" style="display:none; text-decoration: none; padding: 10px 20px; float: right;">Exportar a Excel</a>
                    <div id="reporteContainer" style="clear:both; padding-top:20px;"><p>Cargando reporte...</p></div>
                </div>
            </main>
        </div>
    </div>
    <script>
        const token = localStorage.getItem('jwtToken');
        const username = localStorage.getItem('username');
        const contextPath = "/AgenteMensajesIA"; // Usamos valor fijo

        if (!token) { window.location.href = contextPath + '/login.jsp'; }

        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('usernameDisplay').textContent = username;
            document.getElementById('logoutButton').addEventListener('click', () => { localStorage.clear(); window.location.href = contextPath + '/login.jsp'; });
            
            const urlParams = new URLSearchParams(window.location.search);
            const loteId = urlParams.get('lote');
            const exportBtn = document.getElementById('exportBtn');

            if (loteId) {
                // CORRECCIÓN: URL completa para el botón de exportar
                exportBtn.href = `${contextPath}/api/estadisticas/frecuencia-mensajes/exportar?lote=${loteId}`;
                exportBtn.style.display = 'inline-block';
                fetchReportData(loteId);
            } else {
                document.getElementById('reporteContainer').innerHTML = "<p>No se ha especificado un lote de carga.</p>";
            }
        });

        function fetchReportData(loteId) {
            // CORRECCIÓN: URL completa para la llamada a la API
            const url = `${contextPath}/api/estadisticas/frecuencia-mensajes?lote=${loteId}`;
            const container = document.getElementById('reporteContainer');
            fetch(url, { headers: { 'Authorization': 'Bearer ' + token } })
            .then(res => res.ok ? res.json() : Promise.reject(new Error(`Error ${res.status}`)))
            .then(data => {
                let tableHtml = '<table><thead><tr><th>Asesor</th><th>Mensaje</th><th>Cantidad</th></tr></thead><tbody>';
                if (data && data.length > 0) {
                    data.forEach(stat => {
                        tableHtml += '<tr><td>' + stat.nombreAsesor + '</td><td>' + stat.textoOriginal + '</td><td>' + stat.cantidad + '</td></tr>';
                    });
                } else {
                    tableHtml += '<tr><td colspan="3">No hay datos de frecuencia para este lote.</td></tr>';
                }
                tableHtml += '</tbody></table>';
                container.innerHTML = tableHtml;
            }).catch(error => { container.innerHTML = '<p class="error">Error al cargar el reporte.</p>'; console.error(error); });
        }
    </script>
</body>
</html>
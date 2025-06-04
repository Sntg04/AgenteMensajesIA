<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Dashboard Admin</title>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/dashboard-styles.css">
</head>
<body>
    <div class="dashboard-container">
        <jsp:include page="sidebar.jsp" />
        <div class="main-panel">
            <jsp:include page="header.jsp" />
            <main class="content">
                <div class="content-section">
                    <h3>¡Bienvenido al Panel de Administración!</h3>
                    <p>Selecciona una opción del menú de la izquierda para comenzar a trabajar.</p>
                </div>
            </main>
        </div>
    </div>
    <script>
        // Script solo para la cabecera y la seguridad de esta página
        window.addEventListener('pageshow', function(event) { if (event.persisted) { window.location.reload(); } });
        const token = localStorage.getItem('jwtToken');
        const username = localStorage.getItem('username');
        const userRole = localStorage.getItem('userRole');
        const contextPath = '<%= request.getContextPath() %>'; 
        if (!token || userRole !== 'admin') { alert('Acceso no autorizado.'); window.location.href = contextPath + '/login.jsp'; }
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('usernameDisplay').textContent = username;
            document.getElementById('logoutButton').addEventListener('click', () => { 
                localStorage.clear(); alert('Sesión cerrada.'); window.location.href = contextPath + '/login.jsp'; 
            });
        });
    </script>
</body>
</html>
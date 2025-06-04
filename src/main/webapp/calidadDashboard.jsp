<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Dashboard Calidad</title>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/dashboard-styles.css">
</head>
<body>
    <div class="dashboard-container">
        <%-- Incluir la nueva barra lateral de Calidad --%>
        <jsp:include page="sidebar-calidad.jsp" />

        <div class="main-panel">
            <jsp:include page="header.jsp" />

            <main class="content">
                <div class="content-section">
                    <h3>¡Bienvenido al Panel de Calidad!</h3>
                    <p>Desde aquí podrás analizar los mensajes y gestionar las alertas.</p>
                    <p>Selecciona una opción del menú de la izquierda para comenzar.</p>
                </div>
            </main>
        </div>
    </div>

    <script>
        // Script para la lógica de esta página (seguridad y cabecera)
        window.addEventListener('pageshow', function(event) { if (event.persisted) { window.location.reload(); } });

        const token = localStorage.getItem('jwtToken');
        const username = localStorage.getItem('username');
        const userRole = localStorage.getItem('userRole');
        const contextPath = '<%= request.getContextPath() %>'; 

        // Permitir acceso si el rol es 'calidad' O 'admin'
        if (!token || (userRole !== 'calidad' && userRole !== 'admin')) { 
            alert('Acceso no autorizado. Redirigiendo a login.');
            window.location.href = contextPath + '/login.jsp'; 
        }

        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('usernameDisplay').textContent = username;
            document.getElementById('logoutButton').addEventListener('click', () => { 
                localStorage.clear(); 
                alert('Sesión cerrada.'); 
                window.location.href = contextPath + '/login.jsp'; 
            });
        });
    </script>
</body>
</html>
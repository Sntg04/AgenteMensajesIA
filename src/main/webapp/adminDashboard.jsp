<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Dashboard del Administrador</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f0f2f5; }
        .container { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h2 { color: #333; border-bottom: 1px solid #eee; padding-bottom: 10px; }
        #userInfo { margin-bottom: 20px; padding: 10px; background-color: #e9ecef; border-radius: 4px; }
        #userList { margin-top: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        button { background-color: #d9534f; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; margin-top:20px;}
        button:hover { background-color: #c9302c; }
        .error { color: red; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Dashboard del Administrador</h2>
        <div id="userInfo">
            <p>Bienvenido, <span id="usernameDisplay">Cargando...</span> (<span id="userRoleDisplay"></span>)</p>
        </div>

        <button id="logoutButton">Cerrar Sesión</button>
        
        <h3>Lista de Usuarios del Sistema</h3>
        <div id="userList">
            <p>Cargando usuarios...</p>
        </div>
        <div id="errorMessage" class="error"></div>

    </div>

    <script>
        const token = localStorage.getItem('jwtToken');
        const username = localStorage.getItem('username');
        const userRole = localStorage.getItem('userRole');
        const contextPath = '<%= request.getContextPath() %>'; 

        if (username && userRole) {
            document.getElementById('usernameDisplay').textContent = username;
            document.getElementById('userRoleDisplay').textContent = userRole;
        } else {
             document.getElementById('usernameDisplay').textContent = "Usuario no identificado";
        }

        if (!token || userRole !== 'admin') {
            alert('Acceso no autorizado o sesión no válida. Redirigiendo a login.');
            window.location.href = contextPath + '/login.jsp';
        } else {
            fetchUsers();
        }

        function fetchUsers() {
            const usersUrl = contextPath + '/api/usuarios';
            const userListDiv = document.getElementById('userList');
            const errorMessageDiv = document.getElementById('errorMessage');
            errorMessageDiv.textContent = ''; 

            fetch(usersUrl, {
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + token,
                    'Accept': 'application/json'
                }
            })
            .then(response => {
                if (response.status === 401 || response.status === 403) { 
                    localStorage.removeItem('jwtToken'); 
                    localStorage.removeItem('username');
                    localStorage.removeItem('userRole');
                    alert('Su sesión ha expirado o no tiene permisos. Redirigiendo a login.');
                    window.location.href = contextPath + '/login.jsp';
                    return Promise.reject(new Error('Token inválido/expirado o sin permisos.')); 
                }
                if (!response.ok) {
                    return response.json().then(errorData => {
                       throw new Error(errorData.error || `Error HTTP ${response.status}`);
                    }).catch(() => {
                        throw new Error(`Error HTTP ${response.status} - ${response.statusText}`);
                    });
                }
                return response.json();
            })
            .then(users => {
                let tableHtml = '<table><thead><tr><th>ID</th><th>Username</th><th>Nombre Completo</th><th>Rol</th><th>Activo</th><th>Fecha Creación</th></tr></thead><tbody>';
                if (users && users.length > 0) {
                    users.forEach(user => {
                        // AJUSTE AQUÍ para la fecha, usando concatenación de strings
                        tableHtml += '<tr>' +
                                        '<td>' + user.id + '</td>' +
                                        '<td>' + escapeHtml(user.username) + '</td>' +
                                        '<td>' + escapeHtml(user.nombreCompleto || '') + '</td>' +
                                        '<td>' + escapeHtml(user.rol) + '</td>' +
                                        '<td>' + (user.activo ? 'Sí' : 'No') + '</td>' +
                                        '<td>' + new Date(user.fechaCreacion).toLocaleString() + '</td>' + // Esto es JavaScript, se evaluará bien aquí
                                     '</tr>';
                    });
                } else {
                    tableHtml += '<tr><td colspan="6">No se encontraron usuarios.</td></tr>';
                }
                tableHtml += '</tbody></table>';
                userListDiv.innerHTML = tableHtml;
            })
            .catch(error => {
                console.error('Error al obtener usuarios:', error);
                if (!window.location.pathname.endsWith('/login.jsp')) {
                     errorMessageDiv.textContent = 'Error al cargar usuarios: ' + error.message;
                     userListDiv.innerHTML = '<p class="error">No se pudo cargar la lista de usuarios.</p>';
                }
            });
        }

        document.getElementById('logoutButton').addEventListener('click', function() {
            localStorage.removeItem('jwtToken');
            localStorage.removeItem('username');
            localStorage.removeItem('userRole');
            alert('Sesión cerrada.');
            window.location.href = contextPath + '/login.jsp';
        });

        function escapeHtml(unsafe) {
            if (unsafe === null || typeof unsafe === 'undefined') {
                return '';
            }
            return unsafe
                 .toString()
                 .replace(/&/g, "&amp;")
                 .replace(/</g, "&lt;")
                 .replace(/>/g, "&gt;")
                 .replace(/"/g, "&quot;")
                 .replace(/'/g, "&#039;");
        }
    </script>
</body>
</html>
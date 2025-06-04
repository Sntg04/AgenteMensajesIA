<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Usuarios</title>
    <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/dashboard-styles.css">
</head>
<body data-context-path="<%= request.getContextPath() %>">

    <div class="dashboard-container">
        <jsp:include page="sidebar.jsp" />
        <div class="main-panel">
            <jsp:include page="header.jsp" />
            <main class="content">
                <div id="usuarios-content" class="content-section">
                    <h3>Gestión de Usuarios</h3>
                    <button id="showCreateUserFormBtn" class="btn btn-create">Crear Nuevo Usuario</button>
                    <div id="userListTableContainer"><p>Cargando usuarios...</p></div>
                    <div id="errorMessage" class="error"></div>
                </div>
            </main>
        </div>
    </div>

    <div id="userModal" class="modal"><div class="modal-content"><span id="closeModalBtn" class="close-btn">&times;</span><h3 id="formTitle">Crear/Editar Usuario</h3><form id="userForm"><input type="hidden" id="userId" name="userId"><label for="usernameInput">Username:</label><input type="text" id="usernameInput" name="username" required autocomplete="off"><label for="passwordInput">Contraseña:</label><input type="password" id="passwordInput" name="password" placeholder="Dejar en blanco para no cambiar" autocomplete="new-password"><label for="nombreCompletoInput">Nombre Completo:</label><input type="text" id="nombreCompletoInput" name="nombreCompleto"><label for="rolInput">Rol:</label><select id="rolInput" name="rol" required><option value="calidad">Calidad</option><option value="admin">Admin</option></select><button type="submit">Guardar</button></form></div></div>

    <script>
        // --- Bloque 1: Verificación de Autenticación y Variables Globales ---
        window.addEventListener('pageshow', function(event) { if (event.persisted) { window.location.reload(); } });
        
        const token = localStorage.getItem('jwtToken');
        const username = localStorage.getItem('username');
        const userRole = localStorage.getItem('userRole');
        const contextPath = document.body.dataset.contextPath || "/AgenteMensajesIA";
        let userCache = [];
        
        if (!token || userRole !== 'admin') { 
            alert('Acceso no autorizado. Redirigiendo a login.');
            window.location.href = contextPath + '/login.jsp'; 
        }
        
        // --- Bloque 2: Lógica de la Página ---
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('usernameDisplay').textContent = username;
            document.getElementById('logoutButton').addEventListener('click', () => { localStorage.clear(); alert('Sesión cerrada.'); window.location.href = contextPath + '/login.jsp'; });
            document.getElementById('showCreateUserFormBtn').addEventListener('click', openUserModalForCreate);
            document.getElementById('closeModalBtn').addEventListener('click', () => { document.getElementById('userModal').style.display = 'none'; });
            window.addEventListener('click', (event) => { if (event.target == document.getElementById('userModal')) { document.getElementById('userModal').style.display = 'none'; } });
            document.getElementById('userForm').addEventListener('submit', handleFormSubmit);
            document.getElementById('userListTableContainer').addEventListener('click', handleTableActions);
            fetchUsers();
        });

        // --- Bloque 3: Definición de Funciones ---
        function handleTableActions(event) {
            const editButton = event.target.closest('.edit-btn');
            if (editButton) {
                const userIdToEdit = editButton.dataset.id;
                const userToEdit = userCache.find(user => user.id == userIdToEdit);
                if (userToEdit) { openUserModalForEdit(userToEdit); }
                return;
            }
            const deactivateButton = event.target.closest('.deactivate-btn');
            if (deactivateButton) {
                const userId = deactivateButton.dataset.id;
                const userUsername = deactivateButton.dataset.username;
                if (confirm(`¿Estás seguro de que quieres desactivar al usuario "${userUsername}"?`)) {
                    deactivateUser(userId);
                }
            }
        }

        function fetchUsers() {
            fetch(contextPath + '/api/usuarios', { headers: { 'Authorization': 'Bearer ' + token } })
            .then(res => res.ok ? res.json() : Promise.reject(new Error(`Error ${res.status}`)))
            .then(users => {
                userCache = users;
                let tableHtml = '<table><thead><tr><th>ID</th><th>Username</th><th>Nombre</th><th>Rol</th><th>Activo</th><th>Acciones</th></tr></thead><tbody>';
                if (users && users.length > 0) {
                    users.forEach(user => {
                        // CORRECCIÓN FINAL: Se añade la barra invertida \ a cada 
                        tableHtml += `<tr>
                                        <td>\${user.id}</td>
                                        <td>\${escapeHtml(user.username)}</td>
                                        <td>\${escapeHtml(user.nombreCompleto || '')}</td>
                                        <td>\${escapeHtml(user.rol)}</td>
                                        <td>\${user.activo ? 'Sí' : 'No'}</td>
                                        <td>
                                            <button class="btn btn-edit" data-id="\${user.id}">Editar</button>
                                            <button class="btn btn-deactivate" data-id="\${user.id}" data-username="\${escapeHtml(user.username)}">Desactivar</button>
                                        </td>
                                    </tr>`;
                    });
                } else { tableHtml += '<tr><td colspan="6">No se encontraron usuarios.</td></tr>'; }
                tableHtml += '</tbody></table>';
                document.getElementById('userListTableContainer').innerHTML = tableHtml;
                document.getElementById('errorMessage').textContent = '';
            }).catch(error => { document.getElementById('errorMessage').textContent = "Error al cargar usuarios."; console.error(error); });
        }
        
        function openUserModalForCreate() { document.getElementById('formTitle').textContent = 'Crear Nuevo Usuario'; document.getElementById('userForm').reset(); document.getElementById('userId').value = ''; document.getElementById('usernameInput').disabled = false; document.getElementById('passwordInput').placeholder = "Contraseña requerida"; document.getElementById('userModal').style.display = 'block'; }
        function openUserModalForEdit(user) { document.getElementById('formTitle').textContent = 'Editar Usuario'; document.getElementById('userForm').reset(); document.getElementById('userId').value = user.id; document.getElementById('usernameInput').value = user.username; document.getElementById('usernameInput').disabled = true; document.getElementById('nombreCompletoInput').value = user.nombreCompleto; document.getElementById('rolInput').value = user.rol; document.getElementById('passwordInput').placeholder = "Dejar en blanco para no cambiar"; document.getElementById('userModal').style.display = 'block'; }
        function handleFormSubmit(event) { event.preventDefault(); const userId = document.getElementById('userId').value; const userData = { username: document.getElementById('usernameInput').value, passwordHash: document.getElementById('passwordInput').value, nombreCompleto: document.getElementById('nombreCompletoInput').value, rol: document.getElementById('rolInput').value, activo: true }; if (userId && !userData.passwordHash) { delete userData.passwordHash; } if (userId) { updateUser(userId, userData); } else { createUser(userData); } }
        function createUser(userData) { fetch(contextPath + '/api/usuarios', { method: 'POST', headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json' }, body: JSON.stringify(userData) }).then(res => res.ok ? res.json() : Promise.reject('Error al crear')).then(newUser => { alert(`Usuario "${newUser.username}" creado.`); fetchUsers(); document.getElementById('userModal').style.display = 'none'; }).catch(error => alert(error)); }
        function updateUser(userId, userData) { fetch(contextPath + `/api/usuarios/${userId}`, { method: 'PUT', headers: { 'Authorization': 'Bearer ' + token, 'Content-Type': 'application/json' }, body: JSON.stringify(userData) }).then(res => res.ok ? res.json() : Promise.reject('Error al actualizar')).then(updatedUser => { alert(`Usuario "${updatedUser.username}" actualizado.`); fetchUsers(); document.getElementById('userModal').style.display = 'none'; }).catch(error => alert(error)); }
        function deactivateUser(userId) { fetch(contextPath + `/api/usuarios/${userId}/desactivar`, { method: 'DELETE', headers: { 'Authorization': 'Bearer ' + token } }).then(res => res.ok ? res.json() : Promise.reject('Error al desactivar')).then(data => { alert(data.mensaje); fetchUsers(); }).catch(error => alert(error)); }
        function escapeHtml(unsafe) { return unsafe ? unsafe.toString().replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;") : ''; }
    </script>
</body>
</html>
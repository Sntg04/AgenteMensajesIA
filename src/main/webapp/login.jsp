<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Iniciar Sesión - Agente IA</title>
    <style>
        body { font-family: sans-serif; margin: 20px; background-color: #f4f4f4; }
        .container { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); width: 300px; margin: auto; }
        h2 { text-align: center; color: #333; }
        label { display: block; margin-bottom: 8px; color: #555; }
        input[type="text"], input[type="password"] { width: calc(100% - 20px); padding: 10px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px; }
        button { background-color: #5cb85c; color: white; padding: 10px 15px; border: none; border-radius: 4px; cursor: pointer; width: 100%; font-size: 16px; }
        button:hover { background-color: #4cae4c; }
        .error-message { color: red; text-align: center; margin-top: 10px; }
        .success-message { color: green; text-align: center; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Iniciar Sesión</h2>
        <form id="loginForm">
            <div>
                <label for="username">Usuario:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div>
                <label for="password">Contraseña:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit">Ingresar</button>
        </form>
        <div id="message" class="error-message"></div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', function(event) {
            event.preventDefault(); // Evitar que el formulario se envíe de la forma tradicional

            const usernameInput = document.getElementById('username');
            const passwordInput = document.getElementById('password');
            const messageDiv = document.getElementById('message');

            const username = usernameInput.value;
            const password = passwordInput.value;

            messageDiv.textContent = ''; // Limpiar mensajes anteriores
            messageDiv.className = ''; // Resetear clase del mensaje

            // URL de tu endpoint de login
            const loginUrl = '${pageContext.request.contextPath}/api/auth/login';

            fetch(loginUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ username: username, password: password })
            })
            .then(response => {
                if (!response.ok) {
                    // Si la respuesta no es OK (ej. 401, 400, 500), obtenemos el JSON del error si existe
                    return response.json().then(errorData => {
                        throw new Error(errorData.error || `Error HTTP ${response.status}`);
                    }).catch(() => {
                        // Si el cuerpo del error no es JSON o está vacío
                        throw new Error(`Error HTTP ${response.status} - ${response.statusText}`);
                    });
                }
                return response.json(); // Convertir la respuesta a JSON si es OK
            })
            .then(data => {
                // Login exitoso
                messageDiv.textContent = '¡Login exitoso! Redirigiendo...';
                messageDiv.className = 'success-message';

                // Guardar el token en localStorage (o sessionStorage)
                // localStorage persiste incluso después de cerrar el navegador
                // sessionStorage se borra cuando se cierra la pestaña/navegador
                localStorage.setItem('jwtToken', data.token);
                localStorage.setItem('username', data.username);
                localStorage.setItem('userRole', data.role);

                // Redirigir a una página de bienvenida o dashboard después de un breve retraso
                // Cambia "dashboard.jsp" a la página a la que quieras ir
                setTimeout(function() {
                    if (data.role === 'admin') {
                        window.location.href = '${pageContext.request.contextPath}/adminDashboard.jsp'; // Ejemplo
                    } else if (data.role === 'calidad') {
                        window.location.href = '${pageContext.request.contextPath}/calidadDashboard.jsp'; // Ejemplo
                    } else {
                         window.location.href = '${pageContext.request.contextPath}/index.html'; // Página por defecto
                    }
                }, 1500); 
            })
            .catch(error => {
                console.error('Error en el login:', error);
                messageDiv.textContent = error.message || 'Error al intentar iniciar sesión.';
                messageDiv.className = 'error-message';
                // Limpiar campos en caso de error podría ser útil
                // usernameInput.value = '';
                // passwordInput.value = '';
            });
        });
    </script>
</body>
</html>
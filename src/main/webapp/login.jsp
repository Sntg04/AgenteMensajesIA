<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - Agente IA</title>
    <style>
        /* ... Tus estilos (sin cambios) ... */
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #212121; }
        .container { background-color: #2b2b2b; padding: 30px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.5); width: 320px; border: 1px solid #444; }
        h2 { text-align: center; color: #f1f1f1; margin-top: 0; margin-bottom: 25px; }
        label { display: block; margin-bottom: 8px; color: #ccc; font-size: 14px; }
        input[type="text"], input[type="password"] { width: calc(100% - 22px); padding: 10px; margin-bottom: 20px; border: 1px solid #555; border-radius: 4px; background-color: #444; color: #f1f1f1; font-size: 16px; }
        input[type="text"]:focus, input[type="password"]:focus { outline: none; border-color: #f1f1f1; }
        button { background-color: #f1f1f1; color: #111; padding: 12px 15px; border: none; border-radius: 4px; cursor: pointer; width: 100%; font-size: 16px; font-weight: bold; transition: background-color 0.3s; }
        button:hover { background-color: #ffffff; }
        .error-message { color: #ff6b6b; text-align: center; margin-top: 15px; height: 20px; }
        .success-message { color: #63e6be; text-align: center; margin-top: 15px; height: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Iniciar Sesión</h2>
        <form id="loginForm">
            <div>
                <label for="username">Usuario:</label>
                <input type="text" id="username" name="username" required autocomplete="username">
            </div>
            <div>
                <label for="password">Contraseña:</label>
                <input type="password" id="password" name="password" required autocomplete="current-password">
            </div>
            <button type="submit">Ingresar</button>
        </form>
        <div id="message" class="error-message"></div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', function(event) {
            event.preventDefault();

            const usernameInput = document.getElementById('username');
            const passwordInput = document.getElementById('password');
            const messageDiv = document.getElementById('message');

            const username = usernameInput.value;
            const password = passwordInput.value;

            messageDiv.textContent = ''; 
            messageDiv.className = ''; 

            const contextPath = "/AgenteMensajesIA";
            const loginUrl = contextPath + '/api/auth/login';

            fetch(loginUrl, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ username: username, password: password })
            })
            .then(response => {
                // =========================================================================
                // == CORRECCIÓN APLICADA AQUÍ ==
                // =========================================================================
                if (!response.ok) {
                    // Si la respuesta no es exitosa (ej. 401 Unauthorized), 
                    // intentamos leer el cuerpo del error como JSON.
                    return response.json().then(errorData => {
                        // Lanzamos un error con el mensaje que viene del servidor (ej. "Credenciales inválidas")
                        throw new Error(errorData.error || `Error HTTP ${response.status}`);
                    }).catch(() => {
                        // Si el cuerpo del error no es JSON (ej. un error 500 HTML), lanzamos un error genérico.
                        throw new Error(`Error HTTP ${response.status} - No se pudo procesar la respuesta del servidor.`);
                    });
                }
                return response.json(); 
            })
            .then(data => {
                messageDiv.textContent = '¡Login exitoso! Redirigiendo...';
                messageDiv.className = 'success-message';
                
                localStorage.setItem('jwtToken', data.token);
                localStorage.setItem('username', data.username);
                localStorage.setItem('userRole', data.role);

                setTimeout(function() {
                    if (data.role === 'admin') {
                        window.location.href = contextPath + '/admin.jsp'; 
                    } else if (data.role === 'calidad') {
                        window.location.href = contextPath + '/calidadDashboard.jsp'; 
                    } else {
                         window.location.href = contextPath + '/index.html';
                    }
                }, 1500); 
            })
            .catch(error => {
                // El bloque catch ahora recibe el error con el mensaje correcto.
                console.error('Error en el login:', error);
                messageDiv.textContent = error.message; // Muestra "Credenciales inválidas..." u otro error.
                messageDiv.className = 'error-message';
            });
        });
    </script>
</body>
</html>
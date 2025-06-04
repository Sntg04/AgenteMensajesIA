package com.ia.mensajes.agentemensajesia.resources; // Asegúrate que este sea tu paquete correcto

import com.ia.mensajes.agentemensajesia.model.LoginRequest;
import com.ia.mensajes.agentemensajesia.model.Usuario;
import com.ia.mensajes.agentemensajesia.services.AuthService;
import com.ia.mensajes.agentemensajesia.util.JwtUtil; // ¡NUEVA IMPORTACIÓN!

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

// Importar una clase para crear el objeto de respuesta JSON con el token
import java.util.HashMap; // Opción simple para el DTO de respuesta
import java.util.Map;    // Opción simple para el DTO de respuesta


@Path("/auth") // Ruta base para todos los endpoints de autenticación: /api/auth
public class AuthResource {

    private AuthService authService;

    public AuthResource() {
        this.authService = new AuthService();
    }

    @POST
    @Path("/login") // Endpoint completo: /api/auth/login
    @Consumes(MediaType.APPLICATION_JSON) // Espera recibir datos en formato JSON
    @Produces(MediaType.APPLICATION_JSON) // Devolverá datos en formato JSON
    public Response login(LoginRequest loginRequest) {
        if (loginRequest == null || loginRequest.getUsername() == null || loginRequest.getPassword() == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                           .entity("{\"error\":\"Usuario y contraseña son requeridos\"}")
                           .build();
        }

        try {
            Usuario usuarioAutenticado = authService.login(loginRequest.getUsername(), loginRequest.getPassword());

            if (usuarioAutenticado != null) {
                // ¡CAMBIO IMPORTANTE AQUÍ!
                // Generar el token JWT
                String token = JwtUtil.generateToken(usuarioAutenticado);

                // Crear un objeto de respuesta que incluya el token y datos del usuario
                // Puedes crear un DTO específico para esto o usar un Map como ejemplo:
                Map<String, Object> responseData = new HashMap<>();
                responseData.put("token", token);
                responseData.put("username", usuarioAutenticado.getUsername());
                responseData.put("role", usuarioAutenticado.getRol());
                // Puedes añadir más datos del usuario si es necesario para el frontend
                // responseData.put("nombreCompleto", usuarioAutenticado.getNombreCompleto());

                return Response.ok(responseData).build();
            } else {
                // Credenciales inválidas
                return Response.status(Response.Status.UNAUTHORIZED)
                               .entity("{\"error\":\"Credenciales inválidas o usuario inactivo\"}")
                               .build();
            }
        } catch (Exception e) {
            // Manejo de errores inesperados
            e.printStackTrace(); // Loguear el error en el servidor
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                           .entity("{\"error\":\"Error interno del servidor: " + e.getMessage() + "\"}")
                           .build();
        }
    }
}
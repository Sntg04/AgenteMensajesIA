package com.ia.mensajes.agentemensajesia.resources; // Asegúrate que este sea tu paquete correcto

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/hello") // Este recurso estará disponible en /api/hello
public class HelloResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN + ";charset=utf-8") // CORRECCIÓN: Añadido ;charset=utf-8
    public String sayHello() {
        return "¡Hola Mundo desde JAX-RS!";
    }

    @GET
    @Path("/json") // Este método estará en /api/hello/json
    @Produces(MediaType.APPLICATION_JSON) // Producirá JSON
    public MessageObject sayHelloJson() {
        return new MessageObject("¡Hola Mundo en JSON desde JAX-RS!");
    }

    // Clase interna simple para el ejemplo JSON
    // En una aplicación real, esta estaría en su propio archivo, posiblemente en el paquete 'model'
    public static class MessageObject {
        private String message;

        // Constructor vacío necesario para la deserialización JSON si alguna vez lo necesitas
        public MessageObject() {
        }

        public MessageObject(String message) {
            this.message = message;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }
    }
}
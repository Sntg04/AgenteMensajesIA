package com.ia.mensajes.agentemensajesia.config; // Asegúrate que este sea tu paquete correcto

import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;

/**
 * Activa JAX-RS en la aplicación.
 * Todas las rutas de los recursos JAX-RS estarán prefijadas por "/api".
 * Por ejemplo, si un recurso tiene @Path("/mensajes"), su URL completa será /AgenteMensajesIA/api/mensajes
 */
@ApplicationPath("/api") // Define la ruta base para todos tus servicios REST
public class JaxRsActivator extends Application {
    // No se necesita contenido adicional en esta clase por ahora.
    // JAX-RS escaneará automáticamente las clases anotadas con @Path, @Provider, etc.
    // en tu proyecto gracias a las dependencias de Jersey que añadimos.
}
// Asegúrate de que el paquete coincida con tu proyecto
package com.ia.mensajes.agentemensajesia.resources;

import com.ia.mensajes.agentemensajesia.model.Mensaje;
import com.ia.mensajes.agentemensajesia.services.MensajeService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.glassfish.jersey.media.multipart.FormDataContentDisposition;
import org.glassfish.jersey.media.multipart.FormDataParam;

import java.io.InputStream;
import java.util.List;
import java.util.Map;

@Path("/mensajes")
public class MensajeResource {

    private final MensajeService mensajeService;

    public MensajeResource() {
        this.mensajeService = new MensajeService();
    }

    @POST
    @Path("/upload")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed({"admin", "calidad"})
    public Response subirArchivoExcel(
            @FormDataParam("file") InputStream fileInputStream,
            @FormDataParam("file") FormDataContentDisposition fileMetaData) {
        
        System.out.println("Recibiendo archivo para procesar: " + fileMetaData.getFileName());

        try {
            List<Mensaje> mensajesProcesados = mensajeService.procesarArchivoExcel(fileInputStream);
            
            if (mensajesProcesados.isEmpty()) {
                return Response.ok(Map.of("mensaje", "El archivo estaba vacío o no contenía datos válidos.", "mensajes", List.of(), "loteId", "")).build();
            }

            // =======================================================
            // == CORRECCIÓN CLAVE: Construir una respuesta con loteId y mensajes ==
            // =======================================================
            String loteId = mensajesProcesados.get(0).getLoteCarga();
            Map<String, Object> respuesta = Map.of(
                "loteId", loteId,
                "mensajes", mensajesProcesados
            );

            return Response.ok(respuesta).build();
            
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, String> errorResponse = Map.of("error", "No se pudo procesar el archivo: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(errorResponse).build();
        }
    }

    // --- Endpoints para Filtros (sin cambios) ---
    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed({"admin", "calidad"})
    public void obtenerTodosLosMensajes() {
        // ... (este método sigue igual)
    }

    @GET
    @Path("/alertas")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed({"admin", "calidad"})
    public void obtenerMensajesDeAlerta() {
        // ... (este método sigue igual)
    }
}
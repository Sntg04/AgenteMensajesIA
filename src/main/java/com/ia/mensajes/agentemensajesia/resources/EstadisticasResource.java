// Asegúrate de que el paquete coincida con tu proyecto
package com.ia.mensajes.agentemensajesia.resources;

import com.ia.mensajes.agentemensajesia.model.EstadisticaMensaje;
import com.ia.mensajes.agentemensajesia.services.EstadisticasService;

import jakarta.annotation.security.RolesAllowed;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.io.ByteArrayInputStream;
import java.util.List;

@Path("/estadisticas")
public class EstadisticasResource {

    private final EstadisticasService estadisticasService;

    public EstadisticasResource() {
        this.estadisticasService = new EstadisticasService();
    }

    @GET
    @Path("/frecuencia-mensajes")
    @Produces(MediaType.APPLICATION_JSON)
    @RolesAllowed({"admin", "calidad"})
    public Response getFrecuencia(@QueryParam("lote") String loteId) {
        try {
            List<EstadisticaMensaje> estadisticas = estadisticasService.getFrecuenciaMensajesPorLote(loteId);
            return Response.ok(estadisticas).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                           .entity("{\"error\":\"Error al obtener estadísticas\"}")
                           .build();
        }
    }

    @GET
    @Path("/frecuencia-mensajes/exportar")
    @Produces("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    @RolesAllowed({"admin", "calidad"})
    public Response exportarFrecuencia(@QueryParam("lote") String loteId) {
        try {
            ByteArrayInputStream excelStream = estadisticasService.exportarFrecuenciaAExcel(loteId);
            
            // Cabeceras para forzar la descarga del archivo en el navegador
            return Response.ok(excelStream)
                    .header("Content-Disposition", "attachment; filename=reporte_frecuencia.xlsx")
                    .build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("Error al generar el reporte.").build();
        }
    }
}
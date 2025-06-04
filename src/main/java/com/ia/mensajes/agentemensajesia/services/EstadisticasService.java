package com.ia.mensajes.agentemensajesia.services;

import com.ia.mensajes.agentemensajesia.dao.MensajeDAO;
import com.ia.mensajes.agentemensajesia.model.EstadisticaMensaje;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class EstadisticasService {
    
    private final MensajeDAO mensajeDAO;

    public EstadisticasService() {
        this.mensajeDAO = new MensajeDAO();
    }

    public List<EstadisticaMensaje> getFrecuenciaMensajesPorLote(String loteId) {
        if (loteId == null || loteId.trim().isEmpty()) {
            return new ArrayList<>();
        }
        return this.mensajeDAO.obtenerFrecuenciaMensajesPorAsesor(loteId);
    }

    public ByteArrayInputStream exportarFrecuenciaAExcel(String loteId) throws IOException {
        List<EstadisticaMensaje> estadisticas = getFrecuenciaMensajesPorLote(loteId);
        return ExcelExportService.crearReporteFrecuenciaExcel(estadisticas);
    }
}
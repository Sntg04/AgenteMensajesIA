package com.ia.mensajes.agentemensajesia.services;

import com.ia.mensajes.agentemensajesia.dao.MensajeDAO;
import com.ia.mensajes.agentemensajesia.ia.ClasificadorMensajes;
import com.ia.mensajes.agentemensajesia.ia.ResultadoClasificacion;
import com.ia.mensajes.agentemensajesia.model.Mensaje;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

public class MensajeService {

    private final MensajeDAO mensajeDAO = new MensajeDAO();
    private final ClasificadorMensajes clasificadorIA = new ClasificadorMensajes();

    public List<Mensaje> procesarArchivoExcel(InputStream inputStream) throws IOException {
        List<Mensaje> mensajesDelArchivo = new ArrayList<>();
        String loteCargaId = UUID.randomUUID().toString();
        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet primeraHoja = workbook.getSheetAt(0);
            Iterator<Row> iterator = primeraHoja.iterator();
            if (iterator.hasNext()) {
                iterator.next(); // Omitir la cabecera
            }

            while (iterator.hasNext()) {
                Row siguienteFila = iterator.next();
                
                String aplicacion = getStringValueFromCell(siguienteFila.getCell(0));
                String textoOriginal = getStringValueFromCell(siguienteFila.getCell(7));
                String nombreAsesor = getStringValueFromCell(siguienteFila.getCell(9));
                Cell celdaFechaHora = siguienteFila.getCell(10);

                if (nombreAsesor == null || nombreAsesor.trim().isEmpty() || textoOriginal == null || textoOriginal.trim().isEmpty()) {
                    continue; // Saltar filas sin datos esenciales
                }

                Mensaje mensaje = new Mensaje();
                mensaje.setAplicacion(aplicacion != null ? aplicacion : "N/A");
                mensaje.setNombreAsesor(nombreAsesor);
                mensaje.setTextoOriginal(textoOriginal);
                mensaje.setLoteCarga(loteCargaId);
                
                if (celdaFechaHora != null && celdaFechaHora.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(celdaFechaHora)) {
                    Date fechaHoraCompleta = celdaFechaHora.getDateCellValue();
                    LocalDateTime ldt = fechaHoraCompleta.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
                    mensaje.setFechaMensaje(java.sql.Date.valueOf(ldt.toLocalDate()));
                    mensaje.setHoraMensaje(ldt.toLocalTime());
                }
                
                ResultadoClasificacion resultado = clasificadorIA.clasificar(textoOriginal);
                mensaje.setClasificacion(resultado.getClasificacion());

                if ("Alerta".equals(resultado.getClasificacion())) {
                    mensaje.setNecesitaRevision(true);
                    String motivo = "Motivo: " + resultado.getPalabraClaveEncontrada() + ". ";
                    mensaje.setTextoReescrito(motivo + clasificadorIA.reescribir(textoOriginal));
                } else {
                    mensaje.setNecesitaRevision(false);
                    mensaje.setTextoReescrito(""); // Asegurarse de que no haya sugerencia si no es alerta
                }
                
                mensaje.setConteoPalabras(textoOriginal.split("\\s+").length);
                mensaje.setConteoCaracteres(textoOriginal.length());
                mensajesDelArchivo.add(mensaje);
            }
        }
        if (!mensajesDelArchivo.isEmpty()) {
            mensajeDAO.guardarVarios(mensajesDelArchivo);
        }
        return mensajesDelArchivo;
    }

    private String getStringValueFromCell(Cell cell) {
        if (cell == null) {
            return null;
        }
        DataFormatter formatter = new DataFormatter();
        return formatter.formatCellValue(cell);
    }

    public List<Mensaje> obtenerAlertasPorLote(String loteId) {
        if (loteId == null || loteId.trim().isEmpty()) {
            return new ArrayList<>();
        }
        return mensajeDAO.listarAlertasPorLote(loteId);
    }
    
    // Este método podría ser obsoleto o puedes mantenerlo si tienes una exportación solo de alertas
    public ByteArrayInputStream exportarAlertasAExcel(String loteId) throws IOException {
        List<Mensaje> alertas = obtenerAlertasPorLote(loteId);
        // Esto requeriría un método específico en ExcelExportService, pero ahora usaremos el completo
        // return ExcelExportService.crearReporteAlertas(alertas); 
        return ExcelExportService.crearReporteCompletoDeLote(alertas); // O reutilizar el nuevo
    }

    // --- MÉTODO NUEVO PARA LA EXPORTACIÓN COMPLETA ---
    public ByteArrayInputStream exportarLoteCompletoAExcel(String loteId) throws IOException {
        // 1. Obtener TODOS los mensajes del lote usando el nuevo método del DAO
        List<Mensaje> mensajesDelLote = mensajeDAO.listarPorLote(loteId);
        
        // 2. Pasar la lista completa al servicio de Excel para generar el archivo con 3 hojas
        return ExcelExportService.crearReporteCompletoDeLote(mensajesDelLote);
    }
}
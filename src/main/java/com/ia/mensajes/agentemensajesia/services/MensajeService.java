// Asegúrate de que el paquete coincida con tu proyecto
package com.ia.mensajes.agentemensajesia.services;

import com.ia.mensajes.agentemensajesia.dao.MensajeDAO;
import com.ia.mensajes.agentemensajesia.ia.ClasificadorMensajes;
import com.ia.mensajes.agentemensajesia.ia.ResultadoClasificacion;
import com.ia.mensajes.agentemensajesia.model.Mensaje;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

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

    private final MensajeDAO mensajeDAO;
    private final ClasificadorMensajes clasificadorIA;

    public MensajeService() {
        this.mensajeDAO = new MensajeDAO();
        this.clasificadorIA = new ClasificadorMensajes();
    }

    public List<Mensaje> procesarArchivoExcel(InputStream inputStream) throws IOException {
        List<Mensaje> mensajesDelArchivo = new ArrayList<>();
        String loteCargaId = UUID.randomUUID().toString();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet primeraHoja = workbook.getSheetAt(0);
            Iterator<Row> iterator = primeraHoja.iterator();

            if (iterator.hasNext()) { iterator.next(); } // Omitir cabecera

            while (iterator.hasNext()) {
                Row siguienteFila = iterator.next();
                
                String aplicacion = getStringValueFromCell(siguienteFila.getCell(0));
                String textoOriginal = getStringValueFromCell(siguienteFila.getCell(7));
                String nombreAsesor = getStringValueFromCell(siguienteFila.getCell(9));
                Cell celdaFechaHora = siguienteFila.getCell(10);

                if (nombreAsesor == null || nombreAsesor.trim().isEmpty() || textoOriginal == null || textoOriginal.trim().isEmpty()) {
                    continue;
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
                    
                    // =========================================================================
                    // == CORRECCIÓN APLICADA AQUÍ ==
                    // =========================================================================
                    // Se asigna directamente el LocalTime, que coincide con el tipo en Mensaje.java
                    mensaje.setHoraMensaje(ldt.toLocalTime());
                }
                
                // Lógica de IA para clasificar
                ResultadoClasificacion resultado = clasificadorIA.clasificar(textoOriginal);
                mensaje.setClasificacion(resultado.getClasificacion());

                if ("Alerta".equals(resultado.getClasificacion())) {
                    mensaje.setNecesitaRevision(true);
                    String motivo = "Motivo: " + resultado.getPalabraClaveEncontrada() + ". ";
                    mensaje.setTextoReescrito(motivo + clasificadorIA.reescribir(textoOriginal));
                } else {
                    mensaje.setNecesitaRevision(false);
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
        if (cell == null) { return null; }
        DataFormatter formatter = new DataFormatter();
        return formatter.formatCellValue(cell);
    }
    
    public List<Mensaje> obtenerTodosLosMensajes() { 
        return mensajeDAO.listarTodos(); 
    }
    
    public List<Mensaje> obtenerAlertas() { 
        return mensajeDAO.listarAlertas(); 
    }
}
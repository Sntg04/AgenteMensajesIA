package com.ia.mensajes.agentemensajesia.services;

import com.ia.mensajes.agentemensajesia.model.EstadisticaMensaje;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;

public class ExcelExportService {

    public static ByteArrayInputStream crearReporteFrecuenciaExcel(List<EstadisticaMensaje> estadisticas) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            XSSFSheet sheet = workbook.createSheet("Reporte_Frecuencia");

            // Crear la fila de encabezado
            Row headerRow = sheet.createRow(0);
            String[] headers = {"Asesor", "Mensaje Original", "Cantidad"};
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
            }

            // Llenar las filas con los datos de las estadísticas
            int rowIdx = 1;
            for (EstadisticaMensaje stat : estadisticas) {
                Row row = sheet.createRow(rowIdx++);
                row.createCell(0).setCellValue(stat.getNombreAsesor());
                row.createCell(1).setCellValue(stat.getTextoOriginal());
                row.createCell(2).setCellValue(stat.getCantidad());
            }

            workbook.write(out);
            return new ByteArrayInputStream(out.toByteArray());
        }
    }
}
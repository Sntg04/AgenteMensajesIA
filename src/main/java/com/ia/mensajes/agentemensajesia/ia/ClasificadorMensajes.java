package com.ia.mensajes.agentemensajesia.ia;

import java.text.Normalizer;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class ClasificadorMensajes {

    private static final Set<String> PALABRAS_ALERTA_ORIGINALES = Set.of(
        "silencio negativo", "reportes negativos", "localización interna", "cobro externo",
        "instancias jurídicas", "debito automático", "embargo", "localización a terceros",
        "retención de vienes", "cobros por derecha", "visita domiciliaria", "embargo de vienes",
        "abogado", "juridico", "responsabilidad financiera", "cobro automatico", "no ignore sus deudas",
        "mora critica", "renuencia al pago", "evasivo", "evasión de pago", "obligacion",
        "irresponsable", "incumplimientos", "proceso", "escala de cuenta", "cobros por honorarios",
        "portafolio en mora", "está incumpliendo con su deber", "será reportado de inmediato",
        "procederemos con acciones legales", "no se haga el desentendido", "no hay más excusas",
        "se tomarán medidas drásticas", "aplicación de sanciones", "cartera castigada", "traslado",
        "protocolo", "departamento de penalizacion", "cobro definitivo", "búsqueda interna",
        "protocolo de cobranzas", "presion", "buro crediticio"
    );

    private static final Set<String> PALABRAS_ALERTA_NORMALIZADAS;

    static {
        PALABRAS_ALERTA_NORMALIZADAS = PALABRAS_ALERTA_ORIGINALES.stream()
                                           .map(ClasificadorMensajes::normalizar)
                                           .collect(Collectors.toSet());
    }
    
    public ResultadoClasificacion clasificar(String textoMensaje) {
        if (textoMensaje == null || textoMensaje.trim().isEmpty()) {
            return new ResultadoClasificacion("Bueno", null); 
        }
        String mensajeNormalizado = normalizar(textoMensaje);
        for (String palabraClaveNormalizada : PALABRAS_ALERTA_NORMALIZADAS) {
            if (mensajeNormalizado.contains(palabraClaveNormalizada)) {
                return new ResultadoClasificacion("Alerta", palabraClaveNormalizada);
            }
        }
        return new ResultadoClasificacion("Bueno", null);
    }

    public String reescribir(String textoOriginal) {
        return "Sugerencia: intente usar un tono más neutral y informativo.";
    }

    private static String normalizar(String texto) {
        if (texto == null) return "";
        String textoNormalizado = texto.toLowerCase();
        textoNormalizado = Normalizer.normalize(textoNormalizado, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        textoNormalizado = pattern.matcher(textoNormalizado).replaceAll("");
        textoNormalizado = textoNormalizado.replaceAll("\\p{Punct}", "");
        textoNormalizado = textoNormalizado.replaceAll("\\s+", " ").trim();
        return textoNormalizado;
    }
}
package com.ia.mensajes.agentemensajesia.ia;

import opennlp.tools.lemmatizer.LemmatizerME;
import opennlp.tools.lemmatizer.LemmatizerModel;
import opennlp.tools.postag.POSModel;
import opennlp.tools.postag.POSTaggerME;
import opennlp.tools.tokenize.TokenizerME;
import opennlp.tools.tokenize.TokenizerModel;

import java.io.IOException;
import java.io.InputStream;
import java.text.Normalizer;
import java.util.Set;
import java.util.regex.Pattern;

public class ClasificadorMensajes {

    // Lista de palabras clave (lemas) - Sin cambios
    private static final Set<String> PALABRAS_ALERTA_LEMAS = Set.of(
        "deber", "obligacion", "incumplimiento", "proceso", "juridico", "abogado",
        "embargo", "retencion", "sancion", "demanda", "legal", "reportar", "cobro",
        "amenaza", "consecuencia", "evasion", "responsabilidad", "deuda", "mora",
        "buro", "presion", "penalizacion", "visita", "tercero", "localizacion", "castigado"
    );

    // --- INICIALIZACIÓN DE MODELOS NLP ---
    private static final TokenizerME tokenizer;
    private static final POSTaggerME posTagger;
    private static final LemmatizerME lemmatizer; // <--- CAMBIO AQUÍ

    static {
        try {
            // Cargar modelo de Tokenizer (sin cambios)
            try (InputStream modelIn = ClasificadorMensajes.class.getResourceAsStream("/models/es/es-token.bin")) {
                if (modelIn == null) throw new IOException("No se encontró el modelo de tokenizer: /models/es/es-token.bin");
                TokenizerModel tokenModel = new TokenizerModel(modelIn);
                tokenizer = new TokenizerME(tokenModel);
            }

            // Cargar modelo de POS Tagger (sin cambios)
            try (InputStream modelIn = ClasificadorMensajes.class.getResourceAsStream("/models/es/es-pos-maxent.bin")) {
                if (modelIn == null) throw new IOException("No se encontró el modelo POS: /models/es/es-pos-maxent.bin");
                POSModel posModel = new POSModel(modelIn);
                posTagger = new POSTaggerME(posModel);
            }

            // --- CAMBIO IMPORTANTE: Cargar MODELO de Lemmatizer ---
            try (InputStream modelIn = ClasificadorMensajes.class.getResourceAsStream("/models/es/es-lemmatizer.bin")) {
                if (modelIn == null) throw new IOException("No se encontró el modelo de lematización: /models/es/es-lemmatizer.bin");
                LemmatizerModel lemmatizerModel = new LemmatizerModel(modelIn);
                lemmatizer = new LemmatizerME(lemmatizerModel);
            }

        } catch (IOException e) {
            throw new RuntimeException("Fallo al cargar los modelos de NLP. Asegúrese de que los archivos .bin estén en la ruta correcta y renombrados.", e);
        }
    }

    // El resto de la clase no necesita cambios...
    
    public ResultadoClasificacion clasificar(String textoMensaje) {
        if (textoMensaje == null || textoMensaje.trim().isEmpty()) {
            return new ResultadoClasificacion("Bueno", null);
        }

        String mensajeNormalizado = normalizar(textoMensaje);
        String[] tokens = tokenizer.tokenize(mensajeNormalizado);
        String[] tags = posTagger.tag(tokens);
        String[] lemas = lemmatizer.lemmatize(tokens, tags);

        for (String lema : lemas) {
            if (PALABRAS_ALERTA_LEMAS.contains(lema)) {
                return new ResultadoClasificacion("Alerta", lema);
            }
        }
        
        return new ResultadoClasificacion("Bueno", null);
    }

    public String reescribir(String textoOriginal) {
        return "Sugerencia: Intente reformular la frase usando un tono más neutral y enfocado en soluciones, evitando palabras que puedan interpretarse como una amenaza o presión.";
    }

    private static String normalizar(String texto) {
        if (texto == null) return "";
        String textoNormalizado = texto.toLowerCase();
        textoNormalizado = Normalizer.normalize(textoNormalizado, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        textoNormalizado = pattern.matcher(textoNormalizado).replaceAll("");
        textoNormalizado = textoNormalizado.replaceAll("\\s+", " ").trim();
        return textoNormalizado;
    }
}
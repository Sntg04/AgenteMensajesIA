package com.ia.mensajes.agentemensajesia.ia;

public class ResultadoClasificacion {
    private final String clasificacion; // "Bueno" o "Alerta"
    private final String palabraClaveEncontrada; // La palabra que causó la alerta

    public ResultadoClasificacion(String clasificacion, String palabraClaveEncontrada) {
        this.clasificacion = clasificacion;
        this.palabraClaveEncontrada = palabraClaveEncontrada;
    }

    public String getClasificacion() {
        return clasificacion;
    }

    public String getPalabraClaveEncontrada() {
        return palabraClaveEncontrada;
    }
}
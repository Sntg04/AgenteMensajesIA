package com.ia.mensajes.agentemensajesia.model;

public class EstadisticaMensaje {
    private String nombreAsesor;
    private String textoOriginal;
    private long cantidad;

    public EstadisticaMensaje(String nombreAsesor, String textoOriginal, long cantidad) {
        this.nombreAsesor = nombreAsesor;
        this.textoOriginal = textoOriginal;
        this.cantidad = cantidad;
    }

    // Getters y Setters
    public String getNombreAsesor() { return nombreAsesor; }
    public void setNombreAsesor(String nombreAsesor) { this.nombreAsesor = nombreAsesor; }
    public String getTextoOriginal() { return textoOriginal; }
    public void setTextoOriginal(String textoOriginal) { this.textoOriginal = textoOriginal; }
    public long getCantidad() { return cantidad; }
    public void setCantidad(long cantidad) { this.cantidad = cantidad; }
}
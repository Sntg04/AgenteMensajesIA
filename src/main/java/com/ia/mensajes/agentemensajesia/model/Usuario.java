package com.ia.mensajes.agentemensajesia.model; // Asegúrate que este sea tu paquete correcto

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Column;
import jakarta.persistence.Temporal;
import jakarta.persistence.TemporalType;
import java.io.Serializable;
import java.util.Date;

@Entity // Indica que esta clase es una entidad JPA
@Table(name = "usuarios") // Mapea esta entidad a la tabla "usuarios" en la BD
public class Usuario implements Serializable {

    private static final long serialVersionUID = 1L;

    @Id // Marca este campo como la clave primaria
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Indica que el ID es autogenerado por la BD
    @Column(name = "id")
    private Integer id;

    @Column(name = "username", nullable = false, unique = true, length = 50)
    private String username;

    @Column(name = "password_hash", nullable = false, length = 255)
    private String passwordHash; // Usamos camelCase en Java, se mapea a password_hash

    @Column(name = "rol", nullable = false, length = 20)
    private String rol;

    @Column(name = "nombre_completo", length = 100)
    private String nombreCompleto;

    @Column(name = "activo", nullable = false)
    private boolean activo = true; // Valor por defecto

    @Column(name = "fecha_creacion", nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP) // Especifica el tipo de dato de fecha/hora para JPA
    private Date fechaCreacion;

    // Constructores
    public Usuario() {
        this.fechaCreacion = new Date(); // Establecer fecha de creación al crear un nuevo usuario
        this.activo = true;
    }

    // Getters y Setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getNombreCompleto() {
        return nombreCompleto;
    }

    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public Date getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(Date fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    // (Opcional) Métodos toString(), hashCode(), equals() si los necesitas

    @Override
    public String toString() {
        return "Usuario{" +
               "id=" + id +
               ", username='" + username + '\'' +
               ", rol='" + rol + '\'' +
               ", nombreCompleto='" + nombreCompleto + '\'' +
               ", activo=" + activo +
               ", fechaCreacion=" + fechaCreacion +
               '}';
    }
}
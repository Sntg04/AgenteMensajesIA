// Asegúrate de que el paquete coincida con tu proyecto
package com.ia.mensajes.agentemensajesia.dao;

import com.ia.mensajes.agentemensajesia.model.EstadisticaMensaje;
import com.ia.mensajes.agentemensajesia.model.Mensaje;
import com.ia.mensajes.agentemensajesia.util.JPAUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;

import java.util.List;

public class MensajeDAO {

    private EntityManager getEntityManager() {
        return JPAUtil.getEntityManagerFactory().createEntityManager();
    }

    public void guardarVarios(List<Mensaje> mensajes) {
        if (mensajes == null || mensajes.isEmpty()) {
            return;
        }
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            for (Mensaje mensaje : mensajes) {
                em.persist(mensaje);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
            throw new RuntimeException("Error al guardar la lista de mensajes en el DAO.", e);
        } finally {
            em.close();
        }
    }

    public Mensaje buscarPorId(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Mensaje.class, id);
        } finally {
            em.close();
        }
    }
    
    public List<Mensaje> listarTodos() {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Mensaje> query = em.createQuery("SELECT m FROM Mensaje m ORDER BY m.fechaCargaDb DESC", Mensaje.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    public List<Mensaje> listarAlertas() {
        EntityManager em = getEntityManager();
        try {
            String jpql = "SELECT m FROM Mensaje m WHERE m.clasificacion = :tipoClasificacion ORDER BY m.fechaCargaDb DESC";
            TypedQuery<Mensaje> query = em.createQuery(jpql, Mensaje.class);
            query.setParameter("tipoClasificacion", "Alerta");
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    public List<Mensaje> listarPorLote(String loteCarga) {
        EntityManager em = getEntityManager();
        try {
            String jpql = "SELECT m FROM Mensaje m WHERE m.loteCarga = :lote";
            TypedQuery<Mensaje> query = em.createQuery(jpql, Mensaje.class);
            query.setParameter("lote", loteCarga);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
    
    // =========================================================================
    // == MÉTODO CORREGIDO PARA LAS ESTADÍSTICAS POR LOTE ==
    // =========================================================================
    
    /**
     * Calcula la frecuencia de mensajes por asesor PARA UN LOTE DE CARGA ESPECÍFICO.
     * @param loteId El identificador único del lote de carga.
     * @return Una lista de objetos EstadisticaMensaje con los resultados.
     */
    public List<EstadisticaMensaje> obtenerFrecuenciaMensajesPorAsesor(String loteId) {
        EntityManager em = getEntityManager();
        try {
            // Se añade la cláusula WHERE para filtrar por lote de carga
            String jpql = "SELECT NEW com.mycompany.auditoriamensajes.model.EstadisticaMensaje(m.nombreAsesor, m.textoOriginal, COUNT(m)) " +
                          "FROM Mensaje m " +
                          "WHERE m.loteCarga = :loteId " + // Se filtra por el lote
                          "GROUP BY m.nombreAsesor, m.textoOriginal " +
                          "ORDER BY COUNT(m) DESC, m.nombreAsesor";
            
            TypedQuery<EstadisticaMensaje> query = em.createQuery(jpql, EstadisticaMensaje.class);
            query.setParameter("loteId", loteId); // Se asigna el valor al parámetro
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}
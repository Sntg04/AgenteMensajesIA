package com.ia.mensajes.agentemensajesia.dao;

import com.ia.mensajes.agentemensajesia.model.Usuario;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.NoResultException;
import jakarta.persistence.Persistence;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class UsuarioDAO {

    private static EntityManagerFactory emf = Persistence.createEntityManagerFactory("AgenteMensajesIAPU");

    public EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    /**
     * Guarda un nuevo usuario en la base de datos.
     * @param usuario El objeto Usuario a persistir.
     * @return El usuario persistido (con su ID generado).
     */
    public Usuario crear(Usuario usuario) { // Devuelve Usuario
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            em.persist(usuario);
            em.getTransaction().commit();
            return usuario; // Devolver el usuario con su ID ya asignado
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace(); 
            throw new RuntimeException("Error al crear el usuario en DAO", e); 
        } finally {
            em.close();
        }
    }

    /**
     * Busca un usuario por su ID.
     * @param id El ID del usuario a buscar.
     * @return El objeto Usuario si se encuentra, null en caso contrario.
     */
    public Usuario buscarPorId(Integer id) {
        EntityManager em = getEntityManager();
        try {
            return em.find(Usuario.class, id);
        } finally {
            em.close();
        }
    }

    /**
     * Busca un usuario por su nombre de usuario (username).
     * @param username El nombre de usuario a buscar.
     * @return El objeto Usuario si se encuentra, null en caso contrario.
     */
    public Usuario buscarPorUsername(String username) {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Usuario> query = em.createQuery(
                "SELECT u FROM Usuario u WHERE u.username = :username", Usuario.class);
            query.setParameter("username", username);
            return query.getSingleResult();
        } catch (NoResultException e) {
            return null; 
        } finally {
            em.close();
        }
    }

    /**
     * Actualiza un usuario existente en la base de datos.
     * @param usuario El objeto Usuario con los datos actualizados.
     * @return El usuario actualizado.
     */
    public Usuario actualizar(Usuario usuario) {
        EntityManager em = getEntityManager();
        Usuario usuarioActualizado = null;
        try {
            em.getTransaction().begin();
            usuarioActualizado = em.merge(usuario);
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
        } finally {
            em.close();
        }
        return usuarioActualizado;
    }

    /**
     * Elimina un usuario de la base de datos por su ID.
     * @param id El ID del usuario a eliminar.
     */
    public void eliminar(Integer id) {
        EntityManager em = getEntityManager();
        try {
            em.getTransaction().begin();
            Usuario usuario = em.find(Usuario.class, id);
            if (usuario != null) {
                em.remove(usuario);
            }
            em.getTransaction().commit();
        } catch (Exception e) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    /**
     * Obtiene todos los usuarios.
     * @return Una lista de todos los usuarios.
     */
    public List<Usuario> listarTodos() {
        EntityManager em = getEntityManager();
        try {
            TypedQuery<Usuario> query = em.createQuery("SELECT u FROM Usuario u", Usuario.class);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
}
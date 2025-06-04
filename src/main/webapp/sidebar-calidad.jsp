<%-- Archivo: sidebar-calidad.jsp --%>
<nav class="sidebar">
    <h2>Menú Calidad</h2>
    <ul>
        <li><a href="<%= request.getContextPath() %>/calidadDashboard.jsp">Inicio</a></li>
        <li><a href="<%= request.getContextPath() %>/revisarMensajes.jsp">Revisar Mensajes</a></li>
        <li><a href="<%= request.getContextPath() %>/verAlertas.jsp">Ver Alertas</a></li>
        <%-- CORRECCIÓN: El enlace ahora apunta a la página de reportes unificada --%>
        <li><a href="<%= request.getContextPath() %>/reportes.jsp">Reportes</a></li>
        <li><a href="#">Configuración</a></li>
    </ul>
</nav>
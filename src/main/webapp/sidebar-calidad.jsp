<%-- Archivo: sidebar-calidad.jsp --%>
<nav class="sidebar">
    <h2>Men� Calidad</h2>
    <ul>
        <li><a href="<%= request.getContextPath() %>/calidadDashboard.jsp">Inicio</a></li>
        <li><a href="<%= request.getContextPath() %>/revisarMensajes.jsp">Revisar Mensajes</a></li>
        <li><a href="<%= request.getContextPath() %>/verAlertas.jsp">Ver Alertas</a></li>
        <%-- CORRECCI�N: El enlace ahora apunta a la p�gina de reportes unificada --%>
        <li><a href="<%= request.getContextPath() %>/reportes.jsp">Reportes</a></li>
        <li><a href="#">Configuraci�n</a></li>
    </ul>
</nav>
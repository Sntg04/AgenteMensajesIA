<%-- Archivo: sidebar.jsp (para el rol de Admin) --%>
<nav class="sidebar">
    <h2>Menú Admin</h2>
    <ul>
        <li><a href="<%= request.getContextPath() %>/admin.jsp">Inicio</a></li>
        <li><a href="<%= request.getContextPath() %>/usuarios.jsp">Usuarios</a></li>
        <%-- CORRECCIÓN: El enlace ahora apunta a la página de reportes unificada --%>
        <li><a href="<%= request.getContextPath() %>/reportes.jsp">Reportes</a></li>
        <li><a href="#">Configuración</a></li>
    </ul>
</nav>
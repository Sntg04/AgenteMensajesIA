<%-- Archivo: sidebar.jsp (para el rol de Admin) --%>
<nav class="sidebar">
    <h2>Men� Admin</h2>
    <ul>
        <li><a href="<%= request.getContextPath() %>/admin.jsp">Inicio</a></li>
        <li><a href="<%= request.getContextPath() %>/usuarios.jsp">Usuarios</a></li>
        <%-- CORRECCI�N: El enlace ahora apunta a la p�gina de reportes unificada --%>
        <li><a href="<%= request.getContextPath() %>/reportes.jsp">Reportes</a></li>
        <li><a href="#">Configuraci�n</a></li>
    </ul>
</nav>
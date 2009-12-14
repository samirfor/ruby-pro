<%-- 
    Document   : listar
    Created on : Dec 14, 2009, 9:34:43 AM
    Author     : madmac
--%>
<%@page import="app.Cliente"%>
<%@page import="dao.ClienteDao"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Iterator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Lista de Clientes</h1>
        <table border="1" width="80%">
           <thead>
              <tr>
                 <th>#</th>
                 <th>Nome</th>
                 <th>Fone</th>
                 <th>RG</th>
                 <th>CPF</th>
                 <th>Data de Nascimento</th>
              </tr>
           </thead>
           <tbody>
              <%
              List<Cliente> lista = ClienteDao.getInstance().findAll();
              for (Iterator iter = lista.iterator();iter.hasNext();) {
                  Cliente cliente = (Cliente) iter.next();
              %>
              <tr>
                 <td><%=cliente.getId() %></td>
                 <td><%=cliente.getNome() %></td>
                 <td><%=cliente.getFone() %></td>
                 <td><%=cliente.getRG() %></td>
                 <td><%=cliente.getCPF() %></td>
                 <td><%=cliente.getDataNascimento() %></td>
              </tr>
              <%}%>
           </tbody>
        </table>
    </body>
</html>

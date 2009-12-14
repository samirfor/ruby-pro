<%-- 
    Document   : listar
    Created on : Dec 14, 2009, 9:34:43 AM
    Author     : madmac
--%>
<%@page import="app.Filme"%>
<%@page import="dao.FilmeDao"%>
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
        <h1>Lista de Filmes</h1>
        <table border="1" width="80%">
           <thead>
              <tr>
                 <th>#</th>
                 <th>Título</th>
                 <th>Ano Lançamento</th>
                 <th>Duração</th>
                 <th>Diretor</th>
                 <th>Gênero</th>
              </tr>
           </thead>
           <tbody>
              <%
              List<Filme> listFilmes = FilmeDao.getInstance().findAll();
              for (Iterator iter = listFilmes.iterator();iter.hasNext();) {
                  Filme filme = (Filme)iter.next();
              %>
              <tr>
                 <td><%=filme.getId() %></td>
                 <td><%=filme.getTitulo() %></td>
                 <td><%=filme.getAno() %></td>
                 <td><%=filme.getDuracao() %></td>
                 <td><%=filme.getDiretor() %></td>
                 <td><%=filme.getGenero().getDescricao() %></td>
              </tr>
              <%}%>
           </tbody>
        </table>
    </body>
</html>

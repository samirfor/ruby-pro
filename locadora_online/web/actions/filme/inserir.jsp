<%-- 
    Document   : inserir
    Created on : Dec 14, 2009, 9:13:41 AM
    Author     : madmac
--%>
<%@page import="app.Filme"%>
<%@page import="dao.FilmeDao"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Novo Filme</title>
    </head>
    <body>
        <%
        String titulo = request.getParameter("titulo");
        Integer ano = Integer.parseInt(request.getParameter("ano"));
        Integer duracao = Integer.parseInt(request.getParameter("duracao"));
        String diretor = request.getParameter("diretor");
        Integer generoId = Integer.parseInt(request.getParameter("genero_id"));

        Filme filme = new Filme();
        filme.setTitulo(titulo);
        filme.setAno(ano);
        filme.setDuracao(duracao);
        filme.setDiretor(diretor);
        filme.getGenero().setId(generoId);
        try{
           FilmeDao.getInstance().insert(filme);
           %>
           <p>Filme Inserido. <a href="../../index.jsp"><input type="button" value="Back" name="back" /></a></p>
           <%
        } catch (Exception e) {
           %>
           <p>Um erro ocorreu. [<%=e.getMessage() %>]<br/>
           <input type="button" value="Back" name="back" onclick="javascript:history.go(-1)" /></p>
           <%
        }
        %>
    </body>
</html>

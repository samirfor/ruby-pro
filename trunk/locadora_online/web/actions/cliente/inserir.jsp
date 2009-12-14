<%-- 
    Document   : inserir
    Created on : Dec 14, 2009, 9:13:41 AM
    Author     : samir
--%>
<%@page import="app.Cliente"%>
<%@page import="dao.ClienteDao"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<%@page import="java.sql.Date" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Novo Cliente</title>
    </head>
    <body>
        <%
        String nome = request.getParameter("nome");
        Long fone = Long.parseLong(request.getParameter("fone"));
        Long rg = Long.parseLong(request.getParameter("rg"));
        Long cpf = Long.parseLong(request.getParameter("cpf"));
        SimpleDateFormat data_format = new SimpleDateFormat("dd/MM/yyyy");
        Date data_nasc = (Date) data_format.parse(request.getParameter("data"));

        Cliente cliente = new Cliente();
        cliente.setNome(nome);
        cliente.setFone(fone);
        cliente.setRG(rg);
        cliente.setCPF(cpf);
        cliente.setDataNascimento(data_nasc);
        try{
           ClienteDao.getInstance().insert(cliente);
           %>
           <p>Cliente inserido. <a href="../../index.jsp"><input type="button" value="Voltar" name="back" /></a></p>
           <%
        } catch (Exception e) {
           %>
           <p>Um erro ocorreu. [<%=e.getMessage() %>]<br/>
           <input type="button" value="Voltar" name="back" onclick="javascript:history.go(-1)" /></p>
           <%
        }
        %>
    </body>
</html>

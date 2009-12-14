<%-- 
    Document   : filme
    Created on : Dec 14, 2009, 8:52:49 AM
    Author     : madmac
--%>
<%@page import="app.Genero"%>
<%@page import="dao.GeneroDao"%>
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
      <h1>Novo Filme</h1>
      <form name="inserir_filme" action="../../actions/filme/inserir.jsp" method="POST">
         <table border="0" cellpadding="3" width="50%">
            <tbody>
               <tr>
                  <td>Título</td>
                  <td><input type="text" name="titulo" value="" size="60" /></td>
               </tr>
               <tr>
                  <td>Ano Lançamento</td>
                  <td><input type="text" name="ano" value="" size="6" /> Ex.: 1999</td>
               </tr>
               <tr>
                  <td>Duração</td>
                  <td><input type="text" name="duracao" value="" size="6" /> minutos.</td>
               </tr>
               <tr>
                  <td>Diretor</td>
                  <td><input type="text" name="diretor" value="" size="50" /></td>
               </tr>
               <tr>
                  <td>Gênero</td>
                  <td>
                     <select name="genero_id">
                        <option value="">Selecione O Gênero</option>
                        <%
                              List<Genero> listGenero = GeneroDao.getInstance().findAll();
                              for (Iterator iter = listGenero.iterator(); iter.hasNext();) {
                                 Genero genero = (Genero) iter.next();
                        %>
                        <option value="<%=genero.getId()%>"><%=genero.getDescricao()%></option>
                        <%
                              }
                        %>
                     </select>
                  </td>
               </tr>
               <tr>
                  <td></td>
                  <td><input type="submit" value="Ok" />&nbsp;
                     <input type="reset" value="Clear" /></td>
               </tr>
            </tbody>
         </table>
      </form>
   </body>
</html>

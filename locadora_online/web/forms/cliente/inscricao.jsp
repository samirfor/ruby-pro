<%-- 
    Document   : inscricao
    Created on : 14/12/2009, 08:11:08
    Author     : multi
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Incricao Cliente</title>
    </head>
    <body>
        <h1>Incrição de Clientes</h1>
        <table border="1" cellpadding="3" width="50%">
           <tbody>
              <tr>
                 <td>Nome Completo</td>
                 <td><input type="text" name="nome" value="" size="50" /></td>
              </tr>
              <tr>
                 <td>Telefone</td>
                 <td><input type="text" name="fone" value="" size="15" /></td>
              </tr>
              <tr>
                 <td>RG</td>
                 <td><input type="text" name="rg" value="" size="15" /></td>
              </tr>
              <tr>
                 <td>CPF</td>
                 <td><input type="text" name="cpf" value="" size="15" /></td>
              </tr>
              <tr>
                 <td>Data Nasc.</td>
                 <td><input type="text" name="data_nasc" value="" size="10" /></td>
              </tr>
              <tr>
                 <td><input type="submit" value="Ok" /></td>
                 <td><input type="reset" value="Clear" /></td>
              </tr>
           </tbody>
        </table>
    </body>
</html>

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * Question.java
 *
 * Created on 23/10/2009, 07:59:41
 */
package grafico;

import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.UIManager;
import javax.swing.text.BadLocationException;

/**
 *
 * @author Samir <samirfor@gmail.com>
 */
public class Question extends javax.swing.JFrame {

    /** Creates new form Question */
    public Question() {
        initComponents();
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        links = new javax.swing.JTextArea();
        download = new javax.swing.JButton();
        jLabel1 = new javax.swing.JLabel();
        titulo = new javax.swing.JLabel();
        limpar = new javax.swing.JButton();
        jLabel2 = new javax.swing.JLabel();
        avisos = new javax.swing.JLabel();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("R_p_dSha_e D_w_loader v0.0.1 Beta");

        links.setColumns(20);
        links.setRows(5);
        links.setAutoscrolls(true);
        jScrollPane1.setViewportView(links);

        download.setFont(new java.awt.Font("DejaVu Sans", 1, 13));
        download.setText("D_o_w_n_l_0_@_d");
        download.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                downloadActionPerformed(evt);
            }
        });

        jLabel1.setText("Lista de links: (um por linha)");

        titulo.setFont(new java.awt.Font("DejaVu Sans", 1, 18));
        titulo.setText("R_p_dSha_e D_w_loader v0.0.1 Beta");

        limpar.setText("Limpar");
        limpar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                limparActionPerformed(evt);
            }
        });

        jLabel2.setText("Criado por Samir <samirfor@gmail.com>");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addContainerGap()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                            .addComponent(titulo)
                            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 673, Short.MAX_VALUE)
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(limpar)
                                .addGap(9, 9, 9)
                                .addComponent(download))
                            .addComponent(avisos)))
                    .addGroup(layout.createSequentialGroup()
                        .addGap(12, 12, 12)
                        .addComponent(jLabel1)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 226, Short.MAX_VALUE)
                        .addComponent(jLabel2)))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(titulo)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel1)
                    .addComponent(jLabel2))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 284, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(avisos)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 23, Short.MAX_VALUE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(download)
                    .addComponent(limpar))
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void downloadActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_downloadActionPerformed
        String listaLinks = links.getText();
        String[] argumento = new String[1];
        if (listaLinks.equals(null)) {
            links.setText("Não há links para baixar.");
            avisos.setText("Não há links para baixar.");
        } else {
            for (int i = 0; i < links.getLineCount(); i++) {
                try {
                    int inicio = links.getLineStartOffset(i);
                    int fim = links.getLineEndOffset(i);
                    String linha = links.getText(inicio, fim - inicio);
                    argumento[0] = linha.replaceAll("^(:/)\\W", "");
                    System.out.println("Linha de download: " + argumento[0]);
                    avisos.setText("Baixando: " + linha.replaceAll("http://\\S+/\\S+/\\S+/", ""));
                } catch (BadLocationException ble) {
                    System.out.println("Erro nos links. Linha " + (i + 1));
                    avisos.setText("Erro nos links. Linha " + (i + 1));
                }


            }
        }
    }//GEN-LAST:event_downloadActionPerformed

    private void limparActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_limparActionPerformed
        links.setText(null);
    }//GEN-LAST:event_limparActionPerformed

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {

            public void run() {
                try {
                    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
                } catch (Exception e) {
                }
                new Question().setVisible(true);
            }
        });
    }
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel avisos;
    private javax.swing.JButton download;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JButton limpar;
    private javax.swing.JTextArea links;
    private javax.swing.JLabel titulo;
    // End of variables declaration//GEN-END:variables
}
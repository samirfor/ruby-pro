/*
 * MainInterface.java
 *
 * Created on 16/10/2009, 02:40:36
 */
package app.interfacegrafica;

import java.awt.image.BufferedImage;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.UIManager;

/**
 *
 * @author samir
 */
public class MainInterface extends javax.swing.JFrame {

    /** Creates new form MainInterface */
    public MainInterface() {
        //
        // Read the image that will be used as the application icon. Using "/"
        // in front of the image file name will locate the image at the root
        // folder of our application. If you don't use a "/" then the image file
        // should be on the same folder with your class file.
        //
        BufferedImage icone = null;
        try {
            icone = ImageIO.read(getClass().getResource("/pixmap/samir_sp_boka.png"));
            setIconImage(icone);
        } catch (IOException e) {
            System.out.println("Erro ao carregar o ícone do JFrame.\n" + e);
        }

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

        buttonGroup1 = new javax.swing.ButtonGroup();
        jPanel1 = new javax.swing.JPanel();
        bCriar = new javax.swing.JButton();
        rCriar = new javax.swing.JRadioButton();
        fPorta = new javax.swing.JFormattedTextField();
        lPorta = new javax.swing.JLabel();
        tServidor = new javax.swing.JTextField();
        lServidor = new javax.swing.JLabel();
        lStatus = new javax.swing.JLabel();
        rEntrar = new javax.swing.JRadioButton();
        jButton1 = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("Dominó Online");
        setResizable(false);

        bCriar.setText("Criar");
        bCriar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                bCriarActionPerformed(evt);
            }
        });

        buttonGroup1.add(rCriar);
        rCriar.setSelected(true);
        rCriar.setText("Criar um jogo");
        rCriar.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                rCriarItemStateChanged(evt);
            }
        });

        fPorta.setFormatterFactory(new javax.swing.text.DefaultFormatterFactory(new javax.swing.text.NumberFormatter(new java.text.DecimalFormat("###0"))));
        fPorta.setHorizontalAlignment(javax.swing.JTextField.CENTER);
        fPorta.setText("61200");
        fPorta.setToolTipText("Informe a porta a ser usada");
        fPorta.setDragEnabled(true);
        fPorta.setFocusCycleRoot(true);

        lPorta.setText("Porta:");

        tServidor.setText("192.168.254.254");
        tServidor.setToolTipText("Informe o nome ou endereço IP da máquina que quer se conectar.");
        tServidor.setEnabled(false);

        lServidor.setText("IP do Servidor:");

        lStatus.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        lStatus.setText("Status");

        buttonGroup1.add(rEntrar);
        rEntrar.setText("Entrar em um jogo");
        rEntrar.addItemListener(new java.awt.event.ItemListener() {
            public void itemStateChanged(java.awt.event.ItemEvent evt) {
                rEntrarItemStateChanged(evt);
            }
        });

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                    .addComponent(rCriar)
                    .addComponent(rEntrar)
                    .addComponent(lServidor)
                    .addComponent(tServidor, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(lPorta)
                    .addComponent(fPorta, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(bCriar, javax.swing.GroupLayout.PREFERRED_SIZE, 119, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(lStatus, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 162, Short.MAX_VALUE))
                .addContainerGap())
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(rCriar)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(rEntrar)
                .addGap(18, 18, 18)
                .addComponent(lServidor)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(tServidor, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(lPorta)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(fPorta, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(bCriar)
                .addGap(18, 18, 18)
                .addComponent(lStatus)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jButton1.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/samir_sp_boka.png"))); // NOI18N

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addContainerGap()
                        .addComponent(jButton1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addGroup(layout.createSequentialGroup()
                        .addGap(81, 81, 81)
                        .addComponent(jPanel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addGap(87, 87, 87)))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jButton1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void bCriarActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_bCriarActionPerformed
        if (rCriar.isSelected()) {
            try {
                Interface.run(); //Integer.parseInt(fPorta.getText()));
                lStatus.setText("Esperando outro jogador.");
            } catch (Exception e) {
                System.out.println("Não foi possível abrir um servidor.");
                System.out.println(e);
            }
        } else {
            try {
                Interface.run();
                lStatus.setText("Iniciando jogo.");
            } catch (Exception e) {
                System.out.println("Não foi possível se conectar nesse servidor.");
                System.out.println(e);
            }
        }
    }//GEN-LAST:event_bCriarActionPerformed

    private void rCriarItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_rCriarItemStateChanged
        if (rCriar.isSelected()) {
            tServidor.setEnabled(false);
        }
    }//GEN-LAST:event_rCriarItemStateChanged

    private void rEntrarItemStateChanged(java.awt.event.ItemEvent evt) {//GEN-FIRST:event_rEntrarItemStateChanged
        if (rEntrar.isSelected()) {
            tServidor.setEnabled(true);
        }
    }//GEN-LAST:event_rEntrarItemStateChanged

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
                new MainInterface().setVisible(true);
            }
        });
    }
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton bCriar;
    private javax.swing.ButtonGroup buttonGroup1;
    private javax.swing.JFormattedTextField fPorta;
    private javax.swing.JButton jButton1;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JLabel lPorta;
    private javax.swing.JLabel lServidor;
    private javax.swing.JLabel lStatus;
    private javax.swing.JRadioButton rCriar;
    private javax.swing.JRadioButton rEntrar;
    private javax.swing.JTextField tServidor;
    // End of variables declaration//GEN-END:variables
}
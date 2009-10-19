package app;

import java.net.InetAddress;
import java.net.UnknownHostException;
import javax.swing.UIManager;

/**
 *
 * @author multi
 */
public class Interface extends javax.swing.JFrame {

    /** Creates new form Show */
    public Interface() {
        initComponents();

        try {
            InetAddress endereco = InetAddress.getLocalHost();
            if (!endereco.isLoopbackAddress()) {
                ip.setText("Seu IP: " + endereco.getHostAddress());
            } else {
                ip.setText("Não foi possível obter seu IP.");
            }
        } catch (UnknownHostException e) {
            ip.setText("Não foi possível obter seu IP.");
        }

        painelEscolha.setVisible(false);
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        maoJogador = new javax.swing.JPanel();
        peca0 = new javax.swing.JLabel();
        peca1 = new javax.swing.JLabel();
        peca2 = new javax.swing.JLabel();
        peca3 = new javax.swing.JLabel();
        peca4 = new javax.swing.JLabel();
        peca5 = new javax.swing.JLabel();
        peca6 = new javax.swing.JLabel();
        peca7 = new javax.swing.JLabel();
        peca8 = new javax.swing.JLabel();
        peca9 = new javax.swing.JLabel();
        peca10 = new javax.swing.JLabel();
        peca11 = new javax.swing.JLabel();
        peca12 = new javax.swing.JLabel();
        peca13 = new javax.swing.JLabel();
        peca14 = new javax.swing.JLabel();
        peca15 = new javax.swing.JLabel();
        peca16 = new javax.swing.JLabel();
        peca17 = new javax.swing.JLabel();
        peca18 = new javax.swing.JLabel();
        peca19 = new javax.swing.JLabel();
        peca20 = new javax.swing.JLabel();
        painelEscolha = new javax.swing.JPanel();
        jogada = new javax.swing.JLabel();
        jogar = new javax.swing.JButton();
        peca_escolhida = new javax.swing.JLabel();
        painelTitulo = new javax.swing.JPanel();
        titulo = new javax.swing.JLabel();
        flag = new javax.swing.JLabel();
        ip = new javax.swing.JLabel();
        tabuleiro = new javax.swing.JPanel();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("Dominó Online");
        setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
        setMinimumSize(null);

        maoJogador.setBorder(javax.swing.BorderFactory.createTitledBorder(null, "Suas peças", javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION, javax.swing.border.TitledBorder.DEFAULT_POSITION, new java.awt.Font("DejaVu Sans", 1, 13))); // NOI18N
        maoJogador.setAutoscrolls(true);

        peca0.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/dePeis/2-6.gif"))); // NOI18N
        peca0.setToolTipText("Clique para escolher esta peça.");
        peca0.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca0MouseClicked(evt);
            }
        });

        peca1.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/dePeis/0-5.gif"))); // NOI18N
        peca1.setToolTipText("Clique para escolher esta peça.");
        peca1.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca1MouseClicked(evt);
            }
        });

        peca2.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/dePeis/5-5.gif"))); // NOI18N
        peca2.setToolTipText("Clique para escolher esta peça.");
        peca2.setFocusable(false);
        peca2.setVerticalTextPosition(javax.swing.SwingConstants.TOP);
        peca2.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca2MouseClicked(evt);
            }
        });

        peca3.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/dePeis/4-6.gif"))); // NOI18N
        peca3.setToolTipText("Clique para escolher esta peça.");
        peca3.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca3MouseClicked(evt);
            }
        });

        peca4.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/dePeis/2-5.gif"))); // NOI18N
        peca4.setToolTipText("Clique para escolher esta peça.");
        peca4.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca4MouseClicked(evt);
            }
        });

        peca5.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/dePeis/4-4.gif"))); // NOI18N
        peca5.setToolTipText("Clique para escolher esta peça.");
        peca5.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca5MouseClicked(evt);
            }
        });

        peca6.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/dePeis/1-3.gif"))); // NOI18N
        peca6.setToolTipText("Clique para escolher esta peça.");
        peca6.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca6MouseClicked(evt);
            }
        });

        peca7.setToolTipText("Clique para escolher esta peça.");
        peca7.setEnabled(false);
        peca7.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca7MouseClicked(evt);
            }
        });

        peca8.setToolTipText("Clique para escolher esta peça.");
        peca8.setEnabled(false);
        peca8.setFocusable(false);
        peca8.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca8MouseClicked(evt);
            }
        });

        peca9.setToolTipText("Clique para escolher esta peça.");
        peca9.setEnabled(false);
        peca9.setFocusable(false);
        peca9.setVerticalTextPosition(javax.swing.SwingConstants.TOP);
        peca9.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca9MouseClicked(evt);
            }
        });

        peca10.setToolTipText("Clique para escolher esta peça.");
        peca10.setEnabled(false);
        peca10.setFocusable(false);
        peca10.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca10MouseClicked(evt);
            }
        });

        peca11.setToolTipText("Clique para escolher esta peça.");
        peca11.setEnabled(false);
        peca11.setFocusable(false);
        peca11.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca11MouseClicked(evt);
            }
        });

        peca12.setToolTipText("Clique para escolher esta peça.");
        peca12.setEnabled(false);
        peca12.setFocusable(false);
        peca12.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca12MouseClicked(evt);
            }
        });

        peca13.setToolTipText("Clique para escolher esta peça.");
        peca13.setEnabled(false);
        peca13.setFocusable(false);
        peca13.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca13MouseClicked(evt);
            }
        });

        peca14.setToolTipText("Clique para escolher esta peça.");
        peca14.setEnabled(false);
        peca14.setFocusable(false);
        peca14.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca14MouseClicked(evt);
            }
        });

        peca15.setToolTipText("Clique para escolher esta peça.");
        peca15.setEnabled(false);
        peca15.setFocusable(false);
        peca15.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca15MouseClicked(evt);
            }
        });

        peca16.setToolTipText("Clique para escolher esta peça.");
        peca16.setEnabled(false);
        peca16.setFocusable(false);
        peca16.setVerticalTextPosition(javax.swing.SwingConstants.TOP);
        peca16.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca16MouseClicked(evt);
            }
        });

        peca17.setToolTipText("Clique para escolher esta peça.");
        peca17.setEnabled(false);
        peca17.setFocusable(false);
        peca17.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca17MouseClicked(evt);
            }
        });

        peca18.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/dePeis/3-5.gif"))); // NOI18N
        peca18.setToolTipText("Clique para escolher esta peça.");
        peca18.setFocusable(false);
        peca18.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca18MouseClicked(evt);
            }
        });

        peca19.setToolTipText("Clique para escolher esta peça.");
        peca19.setEnabled(false);
        peca19.setFocusable(false);
        peca19.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca19MouseClicked(evt);
            }
        });

        peca20.setToolTipText("Clique para escolher esta peça.");
        peca20.setEnabled(false);
        peca20.setFocusable(false);
        peca20.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mouseClicked(java.awt.event.MouseEvent evt) {
                peca20MouseClicked(evt);
            }
        });

        javax.swing.GroupLayout maoJogadorLayout = new javax.swing.GroupLayout(maoJogador);
        maoJogador.setLayout(maoJogadorLayout);
        maoJogadorLayout.setHorizontalGroup(
            maoJogadorLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(maoJogadorLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(maoJogadorLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(maoJogadorLayout.createSequentialGroup()
                        .addComponent(peca0, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca2, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca3, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca4, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca5, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(26, 26, 26)
                        .addComponent(peca6, javax.swing.GroupLayout.DEFAULT_SIZE, 37, Short.MAX_VALUE))
                    .addGroup(maoJogadorLayout.createSequentialGroup()
                        .addComponent(peca7, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca8, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca9, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca10, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca11, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca12, javax.swing.GroupLayout.DEFAULT_SIZE, 36, Short.MAX_VALUE)
                        .addGap(26, 26, 26)
                        .addComponent(peca13, javax.swing.GroupLayout.DEFAULT_SIZE, 37, Short.MAX_VALUE))
                    .addGroup(maoJogadorLayout.createSequentialGroup()
                        .addComponent(peca14, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca15, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca16, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca17, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca18, javax.swing.GroupLayout.DEFAULT_SIZE, 67, Short.MAX_VALUE)
                        .addGap(22, 22, 22)
                        .addComponent(peca19, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)
                        .addGap(26, 26, 26)
                        .addComponent(peca20, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)))
                .addContainerGap())
        );
        maoJogadorLayout.setVerticalGroup(
            maoJogadorLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(maoJogadorLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(maoJogadorLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                    .addComponent(peca1, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca2, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca4, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca5, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca6, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca3, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca0, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(maoJogadorLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                    .addComponent(peca8, javax.swing.GroupLayout.DEFAULT_SIZE, 13, Short.MAX_VALUE)
                    .addComponent(peca9, javax.swing.GroupLayout.DEFAULT_SIZE, 13, Short.MAX_VALUE)
                    .addComponent(peca11, javax.swing.GroupLayout.DEFAULT_SIZE, 13, Short.MAX_VALUE)
                    .addComponent(peca12, javax.swing.GroupLayout.DEFAULT_SIZE, 13, Short.MAX_VALUE)
                    .addComponent(peca13, javax.swing.GroupLayout.DEFAULT_SIZE, 13, Short.MAX_VALUE)
                    .addComponent(peca10, javax.swing.GroupLayout.DEFAULT_SIZE, 13, Short.MAX_VALUE)
                    .addComponent(peca7, javax.swing.GroupLayout.DEFAULT_SIZE, 13, Short.MAX_VALUE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(maoJogadorLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                    .addComponent(peca15, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca16, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca18, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca19, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca20, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca17, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)
                    .addComponent(peca14, javax.swing.GroupLayout.DEFAULT_SIZE, 84, Short.MAX_VALUE)))
        );

        jogada.setFont(new java.awt.Font("DejaVu Sans", 1, 13));
        jogada.setText("Peça escolhida:");
        jogada.setToolTipText("Clique em uma de suas peças ao lado para jogar.");

        jogar.setFont(new java.awt.Font("DejaVu Sans", 1, 13));
        jogar.setText("Jogar!");
        jogar.setToolTipText("Confirmar a sua jogada.");
        jogar.setAutoscrolls(true);
        jogar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jogarActionPerformed(evt);
            }
        });

        peca_escolhida.setToolTipText("Clique em uma de suas peças ao lado para jogar.");

        javax.swing.GroupLayout painelEscolhaLayout = new javax.swing.GroupLayout(painelEscolha);
        painelEscolha.setLayout(painelEscolhaLayout);
        painelEscolhaLayout.setHorizontalGroup(
            painelEscolhaLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, painelEscolhaLayout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(painelEscolhaLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.CENTER)
                    .addComponent(peca_escolhida)
                    .addComponent(jogada)
                    .addComponent(jogar, javax.swing.GroupLayout.PREFERRED_SIZE, 95, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap())
        );
        painelEscolhaLayout.setVerticalGroup(
            painelEscolhaLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, painelEscolhaLayout.createSequentialGroup()
                .addContainerGap(83, Short.MAX_VALUE)
                .addComponent(jogada)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(peca_escolhida)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(jogar)
                .addGap(6, 6, 6))
        );

        jogar.getAccessibleContext().setAccessibleDescription("Fazer a jogada.");

        titulo.setFont(new java.awt.Font("DejaVu Sans", 1, 18));
        titulo.setText("Dominó Online");

        flag.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
        flag.setIcon(new javax.swing.ImageIcon(getClass().getResource("/pixmap/flag_red.png"))); // NOI18N
        flag.setText("Aguardando o outro jogador.");
        flag.setToolTipText("Indica o status do jogo.");

        ip.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
        ip.setText("Seu IP: 192.168.254.1");

        javax.swing.GroupLayout painelTituloLayout = new javax.swing.GroupLayout(painelTitulo);
        painelTitulo.setLayout(painelTituloLayout);
        painelTituloLayout.setHorizontalGroup(
            painelTituloLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(painelTituloLayout.createSequentialGroup()
                .addGroup(painelTituloLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(painelTituloLayout.createSequentialGroup()
                        .addComponent(titulo)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 208, Short.MAX_VALUE)
                        .addComponent(flag))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, painelTituloLayout.createSequentialGroup()
                        .addContainerGap(419, Short.MAX_VALUE)
                        .addComponent(ip)))
                .addContainerGap())
        );
        painelTituloLayout.setVerticalGroup(
            painelTituloLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(painelTituloLayout.createSequentialGroup()
                .addGroup(painelTituloLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(titulo)
                    .addComponent(flag))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(ip)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        tabuleiro.setBorder(javax.swing.BorderFactory.createTitledBorder(null, "Tabuleiro", javax.swing.border.TitledBorder.DEFAULT_JUSTIFICATION, javax.swing.border.TitledBorder.DEFAULT_POSITION, new java.awt.Font("DejaVu Sans", 1, 13))); // NOI18N
        tabuleiro.setAutoscrolls(true);

        javax.swing.GroupLayout tabuleiroLayout = new javax.swing.GroupLayout(tabuleiro);
        tabuleiro.setLayout(tabuleiroLayout);
        tabuleiroLayout.setHorizontalGroup(
            tabuleiroLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 559, Short.MAX_VALUE)
        );
        tabuleiroLayout.setVerticalGroup(
            tabuleiroLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 6, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                    .addComponent(painelTitulo, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(tabuleiro, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(javax.swing.GroupLayout.Alignment.LEADING, layout.createSequentialGroup()
                        .addComponent(maoJogador, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(painelEscolha, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(painelTitulo, javax.swing.GroupLayout.PREFERRED_SIZE, 50, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(tabuleiro, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addGap(93, 93, 93)
                        .addComponent(painelEscolha, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(layout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addComponent(maoJogador, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                .addContainerGap())
        );

        getAccessibleContext().setAccessibleDescription("Dominó Online");

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void jogarActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jogarActionPerformed
        // TODO ação do botão jogar
    }//GEN-LAST:event_jogarActionPerformed

    private void peca0MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca0MouseClicked
        if (peca0.isEnabled()) {
            peca_escolhida.setIcon(peca0.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca0MouseClicked

    private void peca1MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca1MouseClicked
        if (peca1.isEnabled()) {
            peca_escolhida.setIcon(peca1.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca1MouseClicked

    private void peca2MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca2MouseClicked
        if (peca2.isEnabled()) {
            peca_escolhida.setIcon(peca2.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca2MouseClicked

    private void peca6MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca6MouseClicked
        if (peca6.isEnabled()) {
            peca_escolhida.setIcon(peca6.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca6MouseClicked

    private void peca3MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca3MouseClicked
        if (peca3.isEnabled()) {
            peca_escolhida.setIcon(peca3.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca3MouseClicked

    private void peca4MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca4MouseClicked
        if (peca4.isEnabled()) {
            peca_escolhida.setIcon(peca4.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca4MouseClicked

    private void peca5MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca5MouseClicked
        if (peca5.isEnabled()) {
            peca_escolhida.setIcon(peca5.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca5MouseClicked

    private void peca7MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca7MouseClicked
        if (peca7.isEnabled()) {
            peca_escolhida.setIcon(peca7.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca7MouseClicked

    private void peca8MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca8MouseClicked
        if (peca8.isEnabled()) {
            peca_escolhida.setIcon(peca8.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca8MouseClicked

    private void peca9MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca9MouseClicked
        if (peca9.isEnabled()) {
            peca_escolhida.setIcon(peca9.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca9MouseClicked

    private void peca10MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca10MouseClicked
        if (peca10.isEnabled()) {
            peca_escolhida.setIcon(peca10.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca10MouseClicked

    private void peca11MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca11MouseClicked
        if (peca11.isEnabled()) {
            peca_escolhida.setIcon(peca11.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca11MouseClicked

    private void peca12MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca12MouseClicked
        if (peca12.isEnabled()) {
            peca_escolhida.setIcon(peca12.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca12MouseClicked

    private void peca13MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca13MouseClicked
        if (peca13.isEnabled()) {
            peca_escolhida.setIcon(peca13.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca13MouseClicked

    private void peca14MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca14MouseClicked
        if (peca14.isEnabled()) {
            peca_escolhida.setIcon(peca14.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca14MouseClicked

    private void peca15MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca15MouseClicked
        if (peca15.isEnabled()) {
            peca_escolhida.setIcon(peca15.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca15MouseClicked

    private void peca16MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca16MouseClicked
        if (peca16.isEnabled()) {
            peca_escolhida.setIcon(peca16.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca16MouseClicked

    private void peca17MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca17MouseClicked
        if (peca17.isEnabled()) {
            peca_escolhida.setIcon(peca17.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca17MouseClicked

    private void peca18MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca18MouseClicked
        if (peca18.isEnabled()) {
            peca_escolhida.setIcon(peca18.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca18MouseClicked

    private void peca19MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca19MouseClicked
        if (peca19.isEnabled()) {
            peca_escolhida.setIcon(peca19.getIcon());
            painelEscolha.setVisible(true);
        }
    }//GEN-LAST:event_peca19MouseClicked

    private void peca20MouseClicked(java.awt.event.MouseEvent evt) {//GEN-FIRST:event_peca20MouseClicked
        if (peca20.isEnabled()) {
            peca_escolhida.setIcon(peca20.getIcon());
            painelEscolha.setVisible(true);
        }
}//GEN-LAST:event_peca20MouseClicked

    /**
     * @param args the command line arguments
     */
    public static void run() {
        java.awt.EventQueue.invokeLater(new Runnable() {

            public void run() {
                try {
                    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
                } catch (Exception e) {
                }
                new Interface().setVisible(true);
            }
        });
    }
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel flag;
    private javax.swing.JLabel ip;
    private javax.swing.JLabel jogada;
    private javax.swing.JButton jogar;
    private javax.swing.JPanel maoJogador;
    private javax.swing.JPanel painelEscolha;
    private javax.swing.JPanel painelTitulo;
    private javax.swing.JLabel peca0;
    private javax.swing.JLabel peca1;
    private javax.swing.JLabel peca10;
    private javax.swing.JLabel peca11;
    private javax.swing.JLabel peca12;
    private javax.swing.JLabel peca13;
    private javax.swing.JLabel peca14;
    private javax.swing.JLabel peca15;
    private javax.swing.JLabel peca16;
    private javax.swing.JLabel peca17;
    private javax.swing.JLabel peca18;
    private javax.swing.JLabel peca19;
    private javax.swing.JLabel peca2;
    private javax.swing.JLabel peca20;
    private javax.swing.JLabel peca3;
    private javax.swing.JLabel peca4;
    private javax.swing.JLabel peca5;
    private javax.swing.JLabel peca6;
    private javax.swing.JLabel peca7;
    private javax.swing.JLabel peca8;
    private javax.swing.JLabel peca9;
    private javax.swing.JLabel peca_escolhida;
    private javax.swing.JPanel tabuleiro;
    private javax.swing.JLabel titulo;
    // End of variables declaration//GEN-END:variables
}
package leaf;

import javax.swing.*;
import javax.swing.event.AncestorEvent;
import javax.swing.event.AncestorListener;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.cert.Certificate;
import java.util.Enumeration;

public class SignUI {

    protected SignUI() {}

    public static String askForData() {
        final JOptionPane optionPane = new JOptionPane();
        optionPane.setMessageType(JOptionPane.PLAIN_MESSAGE);
        final JTextField textField = new JTextField("", 12);
        textField.addAncestorListener(new AncestorListener() {
            @Override
            public void ancestorAdded(AncestorEvent event) { event.getComponent().requestFocusInWindow(); }

            @Override
            public void ancestorRemoved(AncestorEvent event) { }

            @Override
            public void ancestorMoved(AncestorEvent event) { }
        });
        JLabel label = new JLabel("Input data to sign");
        JPanel panel = new JPanel();
        panel.add(label);
        panel.add(textField);
        JButton signButton = new JButton("Sign");
        signButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                optionPane.setValue(JOptionPane.OK_OPTION);
            }
        });
        JButton cancelButton = new JButton("Cancel");
        cancelButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                optionPane.setValue(JOptionPane.CLOSED_OPTION);
            }
        });
        optionPane.setMessage(panel);
        optionPane.setOptions(new Object[]{ signButton, cancelButton });
        JDialog dialog = optionPane.createDialog(null, "Data");
        dialog.setVisible(true);
        int retVal = (optionPane.getValue() instanceof Integer) ? (Integer) optionPane.getValue() : -1;
        dialog.dispose();
        return retVal == JOptionPane.OK_OPTION ? textField.getText() : "";
    }

    private static Certificate askForCertificate(final KeyStore keyStore) {
        final Choice certificateComboBox = new Choice();
        final JOptionPane optionPane = new JOptionPane();
        optionPane.setMessageType(JOptionPane.PLAIN_MESSAGE);
        JButton signButton = new JButton("Sign");
        signButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                optionPane.setValue(JOptionPane.OK_OPTION);
            }
        });
        JButton cancelButton = new JButton("Cancel");
        cancelButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                optionPane.setValue(JOptionPane.CLOSED_OPTION);
            }
        });
        JButton refreshCertificateButton = new JButton();
        refreshCertificateButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                updateComboBox(certificateComboBox, keyStore);
            }
        });
        refreshCertificateButton.setIcon(new ImageIcon("refresh.png"));
        refreshCertificateButton.setBorderPainted(false);
        refreshCertificateButton.setFocusPainted(true);
        refreshCertificateButton.setContentAreaFilled(false);
        refreshCertificateButton.setPreferredSize(new java.awt.Dimension(20,20));
        JPanel panel = new JPanel();
        panel.add(certificateComboBox);
        panel.add(refreshCertificateButton);
        updateComboBox(certificateComboBox, keyStore);
        optionPane.setMessage(panel);
        optionPane.setOptions(new Object[] { signButton, cancelButton });
        JDialog dialog = optionPane.createDialog(null, "Certificate selection");
        dialog.setAlwaysOnTop(true);
        dialog.setVisible(true);
        int retVal = (optionPane.getValue() instanceof Integer) ? (Integer) optionPane.getValue() : -1;
        dialog.dispose();
        try {
            if (retVal == JOptionPane.OK_OPTION) {
                String alias = certificateComboBox.getSelectedItem();
                if (!alias.equals("Certificate for Digital Signature")) {
                    showErrorMessage("Invalid certificate for digital signing");
                    askForCertificate(keyStore);
                }
                return keyStore.getCertificate(alias);
            }
        } catch (KeyStoreException e) {
            e.printStackTrace();
        }
        return null;
    }

    static char[] askForPin() {
        final JOptionPane optionPane = new JOptionPane();
        optionPane.setMessageType(JOptionPane.PLAIN_MESSAGE);
        final JPasswordField passwordField = new JPasswordField(8);
        passwordField.addAncestorListener(new AncestorListener() {
            @Override
            public void ancestorAdded(AncestorEvent event) {
                event.getComponent().requestFocusInWindow();
            }

            @Override
            public void ancestorRemoved(AncestorEvent event) { }

            @Override
            public void ancestorMoved(AncestorEvent event) { }
        });
        JLabel label = new JLabel("Insert PIN for token");
        JPanel panel = new JPanel();
        panel.add(passwordField);
        panel.add(label);
        JButton okButton = new JButton("OK");
        okButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                optionPane.setValue(JOptionPane.OK_OPTION);
            }
        });
        JButton cancelButton = new JButton("Cancel");
        cancelButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                optionPane.setValue(JOptionPane.CLOSED_OPTION);
            }
        });
        optionPane.setMessage(panel);
        optionPane.setOptions(new Object[] { okButton, cancelButton });
        JDialog dialog = optionPane.createDialog(null, "PIN");
        dialog.setAlwaysOnTop(true);
        dialog.setVisible(true);
        int retVal = (optionPane.getValue() instanceof Integer) ? (Integer) optionPane.getValue() : -1;
        dialog.dispose();
        return retVal == JOptionPane.OK_OPTION ? (new String(passwordField.getPassword())).toCharArray() : null;
    }

    private static void updateComboBox(Choice certificateComboBox, KeyStore keyStore) {
        certificateComboBox.removeAll();
        certificateComboBox.addItem("--Select Certificate--");
        certificateComboBox.select(0);
        try {
            Enumeration enumeration = keyStore.aliases();
            while (enumeration.hasMoreElements()) {
                String alias = (String) enumeration.nextElement();
                certificateComboBox.addItem(alias);
            }
            if (certificateComboBox.getItemCount() == 1) {
                certificateComboBox.removeAll();
                certificateComboBox.addItem("--Not Certificates Available!--");
            } else {
                if (certificateComboBox.getItemCount() == 2) certificateComboBox.remove(0);
            }
        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(null, "ERROR LOADING CERTIFICATES:\n" + e.getMessage(),
                    "ERROR", JOptionPane.ERROR_MESSAGE);
        }
    }

    private boolean isValidCertificate(Choice certificateComboBox) {
        return true;
    }

    public static void showErrorMessage(String message) {
        JOptionPane.showMessageDialog(null, message, "ERROR", JOptionPane.ERROR_MESSAGE);
    }

}

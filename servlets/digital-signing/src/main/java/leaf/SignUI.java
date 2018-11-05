package leaf;

import javax.swing.*;
import javax.swing.event.AncestorEvent;
import javax.swing.event.AncestorListener;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Objects;

public class SignUI {

    protected SignUI() {}

    static char[] askForPin() {
        final JOptionPane optionPane = new JOptionPane();
        optionPane.setMessageType(JOptionPane.PLAIN_MESSAGE);
        final JPasswordField passwordField = new JPasswordField(8);
        passwordField.setToolTipText("Input PIN");
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
        JLabel leafLabel = formatIconLabel("sign-in-with-piv.png");
        JPanel panel = new JPanel();
        panel.add(leafLabel);
        JButton okButton = new JButton("OK");
        okButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                optionPane.setValue(JOptionPane.OK_OPTION);
            }
        });
        optionPane.setMessage(panel);
        optionPane.setOptions(new Object[] { passwordField, okButton });
        JDialog dialog = optionPane.createDialog(null, "PIN");
        dialog.getRootPane().setDefaultButton(okButton);
        dialog.setAlwaysOnTop(true);
        dialog.setVisible(true);
        dialog.pack();
        int retVal = (optionPane.getValue() instanceof Integer) ? (Integer) optionPane.getValue() : -1;
        dialog.dispose();
        return retVal == JOptionPane.OK_OPTION ? (new String(passwordField.getPassword())).toCharArray() : null;
    }

    private static JLabel formatIconLabel(String resource) {
        ImageIcon imageIcon = new ImageIcon(Objects.requireNonNull(SignUI.class.getClassLoader().getResource(resource)));
        JLabel label = new JLabel(imageIcon);
        label.setPreferredSize(new Dimension(215, 314));
        return label;
    }

    public static void showErrorMessage(String message) {
        JOptionPane.showMessageDialog(null, message, "ERROR", JOptionPane.ERROR_MESSAGE);
    }

}
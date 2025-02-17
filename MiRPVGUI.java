import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.*;

public class MiRPVGUI {
    private JFrame frame;
    private JTextField inputFileField;
    private JTextArea logArea;
    private JButton browseButton, runButton;
    
    public MiRPVGUI() {
        frame = new JFrame("miRPV Pipeline GUI");
        frame.setSize(600, 400);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        JPanel panel = new JPanel();
        panel.setLayout(new BorderLayout());

        // File Selection
        JPanel topPanel = new JPanel(new FlowLayout());
        inputFileField = new JTextField(30);
        browseButton = new JButton("Browse");
        topPanel.add(new JLabel("Input File:"));
        topPanel.add(inputFileField);
        topPanel.add(browseButton);

        // Run Button
        runButton = new JButton("Run Pipeline");

        // Log Output
        logArea = new JTextArea();
        logArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(logArea);

        // Adding components
        panel.add(topPanel, BorderLayout.NORTH);
        panel.add(runButton, BorderLayout.CENTER);
        panel.add(scrollPane, BorderLayout.SOUTH);

        // Event Listeners
        browseButton.addActionListener(new BrowseAction());
        runButton.addActionListener(new RunPipelineAction());

        frame.add(panel);
        frame.setVisible(true);
    }

    // Browse for input file
    private class BrowseAction implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            JFileChooser fileChooser = new JFileChooser();
            if (fileChooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
                File selectedFile = fileChooser.getSelectedFile();
                inputFileField.setText(selectedFile.getAbsolutePath());
            }
        }
    }

    // Run miRPV pipeline
    private class RunPipelineAction implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            String inputFilePath = inputFileField.getText();
            if (inputFilePath.isEmpty()) {
                JOptionPane.showMessageDialog(frame, "Please select an input file.");
                return;
            }

            logArea.setText("Running miRPV pipeline...\n");
            runMiRPVScript(inputFilePath);
        }
    }

    // Execute miRPV.sh script
    private void runMiRPVScript(String inputFilePath) {
        try {
            ProcessBuilder builder = new ProcessBuilder("bash", "miRPV.sh", inputFilePath);
            builder.redirectErrorStream(true);
            Process process = builder.start();

            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                logArea.append(line + "\n");
            }

            process.waitFor();
            logArea.append("\nPipeline execution completed!");
        } catch (Exception ex) {
            logArea.append("\nError executing pipeline: " + ex.getMessage());
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(MiRPVGUI::new);
    }
}

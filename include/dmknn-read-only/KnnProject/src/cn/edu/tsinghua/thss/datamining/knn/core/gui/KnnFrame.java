package cn.edu.tsinghua.thss.datamining.knn.core.gui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;
import javax.swing.filechooser.FileFilter;
import javax.swing.filechooser.FileNameExtensionFilter;

import cn.edu.tsinghua.thss.datamining.knn.control.ClassifierControl;
import cn.edu.tsinghua.thss.datamining.knn.core.ClassifierKnn;
import cn.edu.tsinghua.thss.datamining.knn.evaluate.EvaluationResult;

/**
 * The GUI Frame.
 * 
 * @author Wang Yue,Han Lu
 * 
 */
public class KnnFrame extends JFrame implements ActionListener {

	private static final long serialVersionUID = 1L;

	/** the training file chooser */
	private JFileChooser trainfc;
	/** the testing file chooser */
	private JFileChooser testfc;
	/** the input field of number of neighbors */
	private JTextField kinput;
	/** the combo box to choose weighting type */
	private JComboBox weightchooser;
	/** the output area */
	private JTextArea outputarea;

	private String train_file;
	private String test_file;
	private int k = 1;
	private int weight_type = ClassifierKnn.WEIGHT_NONE;

	public KnnFrame() {
		this.setTitle("KNN Classifier");
		this.setSize(new Dimension(800, 600));
		this.setLocation(200, 50);
		this.setLayout(new BorderLayout());
		this.setDefaultCloseOperation(EXIT_ON_CLOSE);
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch (ClassNotFoundException e1) {
			e1.printStackTrace();
		} catch (InstantiationException e1) {
			e1.printStackTrace();
		} catch (IllegalAccessException e1) {
			e1.printStackTrace();
		} catch (UnsupportedLookAndFeelException e1) {
			e1.printStackTrace();
		}

		JPanel inputPanel = new JPanel();
		inputPanel.setSize(600, 200);

		JButton trainfcbutton = new JButton("Select training file");
		JButton testfcbutton = new JButton("Select testing file");
		trainfc = new JFileChooser();
		testfc = new JFileChooser();
		FileFilter arfffilter = new FileNameExtensionFilter("arff files",
				"arff");
		trainfc.addChoosableFileFilter(arfffilter);
		testfc.addChoosableFileFilter(arfffilter);
		trainfcbutton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				int ret = trainfc.showDialog(null, "Open file");
				if (ret == JFileChooser.APPROVE_OPTION) {
					train_file = trainfc.getSelectedFile().getAbsolutePath();
					System.out.println("Training file:" + train_file);
				}
			}
		});
		testfcbutton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				int ret = testfc.showDialog(null, "Open file");

				if (ret == JFileChooser.APPROVE_OPTION) {
					test_file = testfc.getSelectedFile().getAbsolutePath();
					System.out.println("Testing file:" + test_file);
				}
			}
		});
		JLabel klabel = new JLabel("KNN:");
		kinput = new JTextField("1", 5);
		kinput.setSize(40, 20);
		String[] weight_types = { "None", "Inverse", "Similarity" };
		weightchooser = new JComboBox(weight_types);
		weightchooser.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				String type_str = (String) weightchooser.getSelectedItem();
				if (type_str.equals("None"))
					weight_type = ClassifierKnn.WEIGHT_NONE;
				else if (type_str.equals("Inverse"))
					weight_type = ClassifierKnn.WEIGHT_INVERSE;
			}
		});
		JButton startbutton = new JButton("Start");
		startbutton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent e) {
				k = Integer.parseInt(kinput.getText());
				System.out.println("k:" + k);
				System.out.println("Begin classifying");
				EvaluationResult result = ClassifierControl
						.getInstance()
						.doClassification(train_file, test_file, k, weight_type);
				outputarea.setText(result.toString());
			}
		});

		inputPanel.add(trainfcbutton);
		inputPanel.add(testfcbutton);
		inputPanel.add(klabel);
		inputPanel.add(kinput);
		inputPanel.add(new JLabel("Weight type:"));
		inputPanel.add(weightchooser);
		inputPanel.add(startbutton);

		outputarea = new JTextArea(50, 60);

		JScrollPane pScroll = new JScrollPane(outputarea,
				JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
				JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);

		this.add(inputPanel, BorderLayout.NORTH);
		this.add(pScroll, BorderLayout.CENTER);
		this.setVisible(true);
	}

	@Override
	public void actionPerformed(ActionEvent e) {

	}

	public static void main(String[] args) {
		KnnFrame mainframe = new KnnFrame();
	}
}

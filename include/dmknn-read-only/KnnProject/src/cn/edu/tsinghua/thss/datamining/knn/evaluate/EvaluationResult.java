package cn.edu.tsinghua.thss.datamining.knn.evaluate;

import java.text.DecimalFormat;
import java.util.Vector;

import cn.edu.tsinghua.thss.datamining.knn.model.DataSet;

/**
 * Defines the result of the evaluation, which contains the classification
 * accuracy, the true positive rates, false positive rates, recall and
 * precision, etc.
 * 
 * @author Wang Yue
 * 
 */
public class EvaluationResult {
	/** the confusion matrix */
	private int[][] matrix;

	/** the dimension size of the matrix */
	private int matrix_size;

	/** the test set */
	private DataSet dataset;
	private int dataset_size;

	/** the true positive rates */
	private double[] tp_rate;

	/** the false positive rates */
	private double[] fp_rate;

	/** the precision */
	private double[] precision;

	/** the recall */
	private double[] recall;

	/** the number of correctly classified instances */
	private int tp_total;

	/** the classification accuracy on the test set */
	private double accuracy;

	/**
	 * Instantiates an evaluation result.
	 * 
	 * @param confusionMatrix
	 *            the confusion matrix
	 * @param dataset_size
	 *            the size of the test set
	 */
	public EvaluationResult(int[][] confusionMatrix, DataSet dataset) {
		this.matrix = confusionMatrix;
		this.dataset = dataset;
		dataset_size = dataset.getSize();
		matrix_size = matrix[0].length;
		recall = tp_rate = new double[matrix_size];
		fp_rate = new double[matrix_size];
		precision = new double[matrix_size];

		evaluate();
	}

	/**
	 * Caculate the evaluation indicators.
	 */
	private void evaluate() {
		// Compute accuracy
		for (int i = 0; i < matrix_size; i++)
			tp_total += matrix[i][i];
		accuracy = ((double) (tp_total)) / dataset_size;

		// Compute recall(TP Rate)
		for (int i = 0; i < matrix_size; i++) {
			double temp_sum = 0;
			for (int j = 0; j < matrix_size; j++)
				temp_sum += matrix[i][j];
			recall[i] = matrix[i][i] / temp_sum;
		}

		// Compute FP Rate
		for (int i = 0; i < matrix_size; i++) {
			double temp_sum = 0;
			for (int j = 0; j < matrix_size; j++)
				temp_sum += matrix[j][i];
			fp_rate[i] = (temp_sum - matrix[i][i]) / temp_sum;
		}

		// Compute precision
		for (int i = 0; i < matrix_size; i++) {
			double temp_sum = 0;
			for (int j = 0; j < matrix_size; j++)
				temp_sum += matrix[j][i];
			precision[i] = matrix[i][i] / temp_sum;
		}
	}

	/**
	 * Get the confusion matrix
	 * 
	 * @return the confusion matrix
	 */
	public int[][] getMatrix() {
		return matrix;
	}

	/**
	 * Get the total number of instances in the test set.
	 * 
	 * @return the size of the test set
	 */
	public int getDataset_size() {
		return dataset_size;
	}

	/**
	 * Get values of the recall indicator.
	 * 
	 * @return the recall values.
	 */
	public double[] getRecall() {
		return recall;
	}

	/**
	 * Get values of the precision indicator
	 * 
	 * @return the precision values
	 */
	public double[] getPrecision() {
		return precision;
	}

	/**
	 * Get the classification accuracy.
	 * 
	 * @return the classification accuracy
	 */
	public double getAccuracy() {
		return accuracy;
	}

	/**
	 * Get the number of classes of the target attribute
	 * 
	 * @return the number of classes
	 */
	public int getMatrix_size() {
		return matrix_size;
	}

	/**
	 * Get values of the true positive rate.
	 * 
	 * @return true positive rates
	 */
	public double[] getTp_rate() {
		return tp_rate;
	}

	/**
	 * Get values of the false positive rate.
	 * 
	 * @return false positive rates
	 */
	public double[] getFp_rate() {
		return fp_rate;
	}

	/**
	 * Get the number of correctly classified instances.
	 * 
	 * @return the number of correctly classified instances
	 */
	public int getTp_total() {
		return tp_total;
	}

	public String toString() {
		DecimalFormat threePlaces = new DecimalFormat("0.000");

		StringBuffer text = new StringBuffer("");
		text.append("=== Evaluation on test set ===\n");
		text.append("Correctly classified instances\t" + tp_total + "\t"
				+ threePlaces.format(accuracy * 100) + "%\n");
		text.append("Inorrectly classified instances\t"
				+ (dataset_size - tp_total) + "\t"
				+ threePlaces.format(100 - accuracy * 100) + "%\n");

		text.append("===Detailed accuracy by class===\n");
		Vector<String> classes = dataset.getTarget().getAttribute_values();
		text.append("TP Rate  FP Rate  Precision  Recall  Class\n");
		for (int i = 0; i < matrix_size; i++)
			text.append(threePlaces.format(tp_rate[i]) + "\t"
					+ threePlaces.format(fp_rate[i]) + "\t"
					+ threePlaces.format(precision[i]) + "\t"
					+ threePlaces.format(recall[i]) + "\t" + classes.get(i)
					+ "\n");

		text.append("=== Confusion Matrix ===\n");
		for (int i = 0; i < matrix_size; i++)
			text.append((char) ('a' + i) + "\t");
		text.append("<-- classified as\n");
		for (int i = 0; i < matrix_size; i++) {
			for (int j = 0; j < matrix_size; j++)
				text.append(matrix[i][j] + "\t");
			text.append((char) ('a' + i) + "=" + classes.get(i) + "\n");
		}

		return text.toString();
	}
}

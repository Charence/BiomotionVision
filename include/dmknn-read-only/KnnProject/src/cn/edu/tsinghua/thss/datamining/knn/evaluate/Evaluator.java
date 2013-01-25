package cn.edu.tsinghua.thss.datamining.knn.evaluate;

import cn.edu.tsinghua.thss.datamining.knn.core.ClassifierKnn;
import cn.edu.tsinghua.thss.datamining.knn.model.Attribute;
import cn.edu.tsinghua.thss.datamining.knn.model.DataSet;
import cn.edu.tsinghua.thss.datamining.knn.model.Instance;

/**
 * Defines the evaluation process.
 * 
 * @author Wang Yue
 * 
 */
public class Evaluator {
	/** the classifier to evaluate */
	private ClassifierKnn classifier;
	/** the test set to evaluate on */
	private DataSet testset;

	/** the target attribute of the dataset */
	private Attribute target_attribute;
	/** number of values or intervals of the target attribute */
	private int label_num;
	/** the confusion matrix */
	private int[][] confusion_matrix;

	/**
	 * The constructor.
	 * 
	 * @param classifier
	 *            the classifier to evaluate
	 * @param testset
	 *            the test set to evaluate on
	 */
	public Evaluator(ClassifierKnn classifier, DataSet testset) {
		this.classifier = classifier;
		this.testset = testset;
		testset.replaceMissingValues();
		target_attribute = testset.getTarget();
		label_num = target_attribute.getLabelNum();
		confusion_matrix = new int[label_num][label_num];
		for (int i = 0; i < label_num; i++)
			for (int j = 0; j < label_num; j++)
				confusion_matrix[i][j] = 0;
	}

	/**
	 * Evaluate the classification of the classifier on the test set.
	 * 
	 * @return the evaluation result
	 */
	public EvaluationResult evaluateClassification() {
		for (Instance instance : testset.getInstances()) {
			double label = classifier.classifyNewInstance(instance);
			double label_check = instance.getLabel();
			int label_class = target_attribute.getLabelClass(label);
			int check_class = target_attribute.getLabelClass(label_check);
			System.out.println("Label:" + label + "VS" + label_check);
			if (label_class == check_class)
				confusion_matrix[label_class][label_class]++;
			else
				confusion_matrix[check_class][label_class]++;

		}
		EvaluationResult result = new EvaluationResult(confusion_matrix,
				testset);
		return result;
	}
}

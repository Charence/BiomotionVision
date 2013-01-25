package cn.edu.tsinghua.thss.datamining.knn.control;

import cn.edu.tsinghua.thss.datamining.knn.core.ArffTransformer;
import cn.edu.tsinghua.thss.datamining.knn.core.ClassifierKnn;
import cn.edu.tsinghua.thss.datamining.knn.core.ClassifierKnnDiscrete;
import cn.edu.tsinghua.thss.datamining.knn.evaluate.EvaluationResult;
import cn.edu.tsinghua.thss.datamining.knn.evaluate.Evaluator;
import cn.edu.tsinghua.thss.datamining.knn.model.DataSet;

/**
 * A simple control class to pass the classifying arguments to the backend and
 * return the classification result to the frontend.
 * 
 * @author Wang Yue
 * 
 */
public class ClassifierControl {

	/**
	 * Gets an instance.
	 * 
	 * @return an instance of this class
	 */
	public static ClassifierControl getInstance() {
		return new ClassifierControl();
	}

	/**
	 * Trains a classifier ,test it with the test set and gets the evaluation
	 * result
	 * 
	 * @param train_file
	 *            the absolute path of the training file
	 * @param test_file
	 *            the absolute path of the testing file
	 * @param k
	 *            the classifying argument k
	 * @param weight_type
	 *            the type of distance weighting
	 * @return
	 */
	public EvaluationResult doClassification(String train_file,
			String test_file, int k, int weight_type) {
		ArffTransformer arffTrans = new ArffTransformer(train_file);
		DataSet trainingset = arffTrans.getDatasetFromFile();
		arffTrans = new ArffTransformer(test_file);
		DataSet testset = arffTrans.getDatasetFromFile();
		ClassifierKnn classifier = new ClassifierKnnDiscrete(k, trainingset);
		classifier.setWeight_type(weight_type);
		Evaluator evaluator = new Evaluator(classifier, testset);
		return evaluator.evaluateClassification();
	}
}

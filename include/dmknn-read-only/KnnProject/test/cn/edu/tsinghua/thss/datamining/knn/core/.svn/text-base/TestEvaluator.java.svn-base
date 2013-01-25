package cn.edu.tsinghua.thss.datamining.knn.core;

import org.junit.BeforeClass;
import org.junit.Test;

import cn.edu.tsinghua.thss.datamining.knn.evaluate.EvaluationResult;
import cn.edu.tsinghua.thss.datamining.knn.evaluate.Evaluator;
import cn.edu.tsinghua.thss.datamining.knn.model.DataSet;

public class TestEvaluator {
	private static ClassifierKnn classifier;
	private static Evaluator evaluator;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		ArffTransformer arffTrans = new ArffTransformer("c:/train.arff");
		DataSet trainingset = arffTrans.getDatasetFromFile();
		arffTrans = new ArffTransformer("c:/test.arff");
		DataSet testset = arffTrans.getDatasetFromFile();
		classifier = new ClassifierKnnDiscrete(1, trainingset);
		evaluator = new Evaluator(classifier, testset);
	}

	@Test
	public void testEvaluate() {
		EvaluationResult result = evaluator.evaluateClassification();
		System.out.println(result);
	}

}

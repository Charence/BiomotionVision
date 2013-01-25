package cn.edu.tsinghua.thss.datamining.knn.core;

import java.util.Vector;

import cn.edu.tsinghua.thss.datamining.knn.model.DataSet;
import cn.edu.tsinghua.thss.datamining.knn.model.Instance;

/**
 * Defines the KNN classifier that deals with instances with a continuous-valued
 * label.
 * 
 * @author Wang Yue
 * 
 */
public class ClassifierKnnContinuous extends ClassifierKnn {

	public ClassifierKnnContinuous(int k, DataSet trainingset) {
		super(k, trainingset);
	}

	@Override
	public double classifyNewInstance(Instance newinstance) {
		Vector<Instance> nearestNeighbours = getNearestNeighbours(newinstance);
		double sum = 0;
		for (Instance neighbor : nearestNeighbours)
			sum += neighbor.getLabel();
		return sum / trainingset.getSize();
	}

}

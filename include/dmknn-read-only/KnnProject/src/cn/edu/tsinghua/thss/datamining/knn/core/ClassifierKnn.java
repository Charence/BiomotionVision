package cn.edu.tsinghua.thss.datamining.knn.core;

import java.util.Vector;

import cn.edu.tsinghua.thss.datamining.knn.model.DataSet;
import cn.edu.tsinghua.thss.datamining.knn.model.Instance;

/**
 * Defines the KNN classifier.
 * 
 * @author Wang Yue, Han Lu
 * 
 */
public abstract class ClassifierKnn {
	/** the number of neighbors */
	private int k;
	/** the training set */
	protected DataSet trainingset;
	/**
	 * the type of distance weighting: WEIGHT_NONE,WEIGHT_INVERSE, or
	 * WEIGHT_SIMILARITY
	 */
	private int weight_type;

	/** No distance weighting */
	public static final int WEIGHT_NONE = 1;
	/** weight = 1/distance */
	public static final int WEIGHT_INVERSE = 2;

	/**
	 * Instantiates a KNN classifier.
	 * 
	 * @param k
	 *            the number of neighbors
	 * @param trainingset
	 *            the training dataset
	 */
	public ClassifierKnn(int k, DataSet trainingset) {
		if (k <= 0)
			throw new IllegalArgumentException("K must be greater than zero!");
		this.k = k;
		this.trainingset = trainingset;
		trainingset.replaceMissingValues();
		this.weight_type = WEIGHT_NONE;
	}

	/**
	 * Classifies a new instance.
	 * 
	 * @param newinstance
	 *            a new instance to classify
	 * @return the class the new instance belongs to
	 */
	public abstract double classifyNewInstance(Instance newinstance);

	public Vector<Instance> getNearestNeighbours(Instance newinstance) {
		Vector<Instance> neighbors = new Vector<Instance>();
		Vector<Double> distances = new Vector<Double>();
		for (Instance instance : trainingset.getInstances()) {
			double distance = getDistance(instance, newinstance);
			for (int i = 0; i < neighbors.size(); i++) {
				if (distances.get(i) > distance) {
					neighbors.insertElementAt(instance, i);
					distances.insertElementAt(distance, i);
					break;
				}
			}
			if (neighbors.size() < k) {
				neighbors.add(instance);
				distances.add(distance);
			}
			if (neighbors.size() > k) {
				neighbors.remove(k);
				distances.remove(k);
			}
		}

		System.out.println("Instance:" + newinstance);
		System.out.println("Neighbors:");
		for (int i = 0; i < k; i++) {
			Instance neighbor = neighbors.get(i);
			System.out.println(trainingset.getInstances().indexOf(neighbor)
					+ ":" + distances.get(i) + neighbor.toString());
		}

		return neighbors;
	}

	/**
	 * Caculate the distance between two distinct instances
	 * 
	 * @param a
	 *            an instance
	 * @param b
	 *            another instance
	 * @return the distance between the two
	 */
	protected double getDistance(Instance a, Instance b) {
		int attr_num = trainingset.getFeatures().size();
		double distance = 0;
		for (int i = 0; i < attr_num; i++) {
			double x = a.getFeature_values().get(i);
			double y = b.getFeature_values().get(i);
			distance += (x - y) * (x - y);
		}
		return Math.sqrt(distance);
	}

	/**
	 * Get the training dataset
	 * 
	 * @return the training set
	 */
	public DataSet getTrainingset() {
		return trainingset;
	}

	/**
	 * Set the training dataset
	 * 
	 * @param trainingset
	 *            the training set
	 */
	public void setTrainingset(DataSet trainingset) {
		this.trainingset = trainingset;
	}

	/**
	 * Set the type of distance weighting
	 * 
	 * @param weightType
	 *            the type of distance weighting
	 */
	public void setWeight_type(int weightType) {
		this.weight_type = weightType;
	}

	/**
	 * Get weight value
	 */
	public double getWeight(double distance) {
		if (weight_type == WEIGHT_NONE)
			return 1;
		else {
			if (distance == 0)
				return Double.NaN;
			else
				return 1 / distance;
		}
	}
}

package cn.edu.tsinghua.thss.datamining.knn.model;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

/**
 * Defines the data set.
 * 
 * @author Wang Yue, Han Lu
 * 
 */
public class DataSet {
	/** How many instances are there */
	private int size;
	/** How many features does an instance have */
	private Vector<Attribute> features;
	/** The most common values of these features */
	private Vector<Double> feature_missing_values;
	/** The target attribute */
	private Attribute target;
	/** The instances */
	private List<Instance> instances;

	/**
	 * The constructor
	 * 
	 * @param features
	 *            the features that an instance have
	 * @param target
	 *            the target attribute
	 */
	public DataSet(Vector<Attribute> features, Attribute target) {
		this.features = features;
		for (Attribute attr : features)
			attr.setDataset(this);
		this.target = target;
		this.feature_missing_values = new Vector<Double>();
		size = 0;
		instances = new ArrayList<Instance>();
	}

	/**
	 * Get the size of the data set
	 * 
	 * @return the size of the data set
	 */
	public int getSize() {
		return size;
	}

	/**
	 * Set the size of the data set
	 * 
	 * @param size
	 *            the size of the data set
	 */
	public void setSize(int size) {
		this.size = size;
	}

	/**
	 * Get the features of the instance
	 * 
	 * @return the features of the instance
	 */
	public Vector<Attribute> getFeatures() {
		return features;
	}

	public void setFeatures(Vector<Attribute> features) {
		this.features = features;
	}

	public Attribute getTarget() {
		return target;
	}

	public void setTarget(Attribute target) {
		this.target = target;
	}

	public List<Instance> getInstances() {
		return instances;
	}

	public void setInstances(List<Instance> instances) {
		this.instances = instances;
	}

	/**
	 * Add an instance to the data set and update the statistics.
	 * 
	 * @param instance
	 *            the new instance to add
	 */
	public void addInstance(Instance instance) {
		instances.add(instance);
		instance.setDataset(this);
		size++;
		for (int i = 0; i < features.size(); i++) {
			features.get(i).incrementValue(instance.getFeature_values().get(i));
		}
	}

	/**
	 * Replace missing values of instances with the most common values in the
	 * data set
	 */
	public void replaceMissingValues() {
		for (int i = 0; i < features.size(); i++)
			feature_missing_values.add(features.get(i).getMissingValue());

		for (Instance instance : instances) {
			for (int j = 0; j < features.size(); j++) {
				if (instance.isMissing(j))
					instance.setValue(j, features.get(j).getMissingValue());
			}
		}
	}
}

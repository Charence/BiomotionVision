package cn.edu.tsinghua.thss.datamining.knn.model;

import java.util.Vector;

/**
 * Defines the instance
 * 
 * @author Wang Yue,Han Lu
 * 
 */
public class Instance {
	/** the value of each attribute */
	private Vector<Double> feature_values;
	/** Which dataset does it belong to */
	private DataSet dataset;
	/** the value of the target attribute */
	private double label;

	/**
	 * The constructor.
	 * 
	 * @param feature_values
	 *            the value of each attribute
	 * @param label
	 *            the value of the target attribute
	 */
	public Instance(Vector<Double> feature_values, double label) {
		this.feature_values = feature_values;
		this.label = label;
		if (label == Double.NaN)
			throw new IllegalArgumentException("Label cannot be missing!");
	}

	public Vector<Double> getFeature_values() {
		return feature_values;
	}

	public void setFeature_values(Vector<Double> featureValues) {
		feature_values = featureValues;
	}

	public DataSet getDataset() {
		return dataset;
	}

	public void setDataset(DataSet dataset) {
		this.dataset = dataset;
	}

	public double getLabel() {
		return label;
	}

	public void setLabel(double label) {
		this.label = label;
	}

	/**
	 * Check whether the value for an attribute is missing.
	 * 
	 * @param i
	 *            the attribute's position
	 * @return whether the values is missing
	 */
	public boolean isMissing(int i) {
		if (i >= feature_values.size())
			throw new IllegalArgumentException("Out of bound!");
		return feature_values.get(i).isNaN();
	}

	/**
	 * Set the value of the specified attribute
	 * 
	 * @param i
	 *            the attribute's position
	 * @param value
	 *            the value of the attribute to set
	 */
	public void setValue(int i, double value) {
		feature_values.set(i, value);
	}

	public String toString() {
		String text = "<";
		for (double value : feature_values)
			text += value + "\t";
		text += label;
		text += ">";
		return text;
	}

}

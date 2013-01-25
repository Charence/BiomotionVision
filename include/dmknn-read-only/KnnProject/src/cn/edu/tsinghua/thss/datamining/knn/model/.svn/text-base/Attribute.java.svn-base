package cn.edu.tsinghua.thss.datamining.knn.model;

import java.util.Hashtable;
import java.util.Vector;

/**
 * Defines the attribute of an instance.
 * 
 * @author Wang Yue
 * 
 */
public class Attribute {

	/** numeric type */
	public final static int NUMERIC_TYPE = 0;
	/** nominal type */
	public final static int NOMINAL_TYPE = 1;

	/** the name of the attribute */
	private String attribute_name;

	/** the type of the attribute: numeric or nominal */
	private int attribute_type;

	/** String values of the attribute. Only for nominal features */
	private Vector<String> attribute_values;

	/** the data set that the attribute belongs to */
	private DataSet dataset;

	/**
	 * The count of instances on each attribute value in this dataset(for
	 * nominal attributes)
	 */
	private int[] nominal_count;
	/**
	 * The total of values of the attributes on all instances of the dataset
	 * (for numeric attributes)
	 */
	private double numeric_total;

	/**
	 * Map the nominal values to integer values.
	 */
	private Hashtable<String, Integer> hashtable;

	/** Number of intervals in the continuous value range */
	private int num_intervals;
	/** the lower bound of the numeric value */
	private double lower_bound;
	/** the upper bound of the numeric value */
	private double upper_bound;
	/** the lower bounds of each interval */
	private double[] lower_bounds;
	/** the upper bounds of each interval */
	private double[] upper_bounds;

	/**
	 * The constructor.
	 * 
	 * @param attribute_name
	 *            the name of the attribute
	 * @param type
	 *            the type of the attribute
	 * @param attribute_values
	 *            the nominal values of the attribute
	 */
	public Attribute(String attribute_name, int type,
			Vector<String> attribute_values) {
		this.attribute_name = attribute_name;
		this.attribute_values = attribute_values;
		this.attribute_type = type;

		if (type == NUMERIC_TYPE) {
			attribute_values = null;
			num_intervals = 1;
			numeric_total = 0;
		} else {
			int size = attribute_values.size();
			nominal_count = new int[size];
			for (int i = 0; i < size; i++)
				nominal_count[i] = 0;
			hashtable = new Hashtable<String, Integer>();
			for (int i = 0; i < size; i++) {
				String value = attribute_values.get(i);
				if (hashtable.containsKey(value)) {
					throw new IllegalArgumentException("A nominal attribute ("
							+ attribute_name + ") cannot"
							+ " have duplicate labels (" + value + ").");
				}
				hashtable.put(value, i);
			}
		}
	}

	/**
	 * Get the mapping integer value of a nominal value.
	 * 
	 * @param value
	 *            the nominal value
	 * @return the integer value
	 */
	public double getNumericValue(String value) {
		return hashtable.get(value);
	}

	/**
	 * Get the name of the attribute
	 * 
	 * @return the name of the attribute
	 */
	public String getAttribute_name() {
		return attribute_name;
	}

	/**
	 * Set the name of the attribute
	 * 
	 * @param attributeName
	 *            the name of the attribute
	 */
	public void setAttribute_name(String attributeName) {
		attribute_name = attributeName;
	}

	public Vector<String> getAttribute_values() {
		return attribute_values;
	}

	public void setAttribute_values(Vector<String> attributeValues) {
		attribute_values = attributeValues;
	}

	public double getLower_bound() {
		return lower_bound;
	}

	public void setLower_bound(double lowerBound) {
		lower_bound = lowerBound;
	}

	public double getUpper_bound() {
		return upper_bound;
	}

	public void setUpper_bound(double upperBound) {
		upper_bound = upperBound;
	}

	public int getAttribute_type() {
		return attribute_type;
	}

	public void setAttribute_type(int attributeType) {
		attribute_type = attributeType;
	}

	/**
	 * Get the replace values for a missing attribute. If nominal, it's the most
	 * popular one If numeric, adopt the average.
	 * 
	 * @return the replace value
	 */
	public double getMissingValue() {
		if (attribute_type == NOMINAL_TYPE) {
			int max = 0;
			int max_i = -1;
			for (int i = 0; i < nominal_count.length; i++) {
				int count = nominal_count[i];
				if (count > max) {
					max = count;
					max_i = i;
				}
			}
			return max_i;
		} else
			return numeric_total / dataset.getSize();
	}

	/**
	 *When a new instance is added to the dataset, the value statistics will be
	 * updated accordingly.
	 * 
	 * @param value
	 */
	public void incrementValue(double value) {
		if (attribute_type == NOMINAL_TYPE)
			nominal_count[(int) value]++;
		else
			numeric_total += value;
	}

	/**
	 * Get the data set
	 * 
	 * @return the data set
	 */
	public DataSet getDataset() {
		return dataset;
	}

	/**
	 * Sets the data set
	 * 
	 * @param dataset
	 *            the data set
	 */
	public void setDataset(DataSet dataset) {
		this.dataset = dataset;
	}

	public String toString() {
		String text = "Name:" + attribute_name + " Type:"
				+ (attribute_type == 0 ? "Numeric" : "Nominal");
		if (attribute_values != null) {
			text += " Values:";
			for (String value : attribute_values)
				text += value + " ";
		}
		return text;
	}

	/**
	 * Check if an instance is correctly classfied by comparing the label value.
	 * 
	 * @param a
	 *            the classified label
	 * @param b
	 *            the actual label
	 * @return whether correctly classified
	 */
	public boolean checkLabelEquals(double a, double b) {
		if (attribute_type == NOMINAL_TYPE)
			return a == b;
		else
			return (a - b) * (a - b) < 0.1;
	}

	/**
	 * Get the number of intervals
	 * 
	 * @return the number of intervals
	 */
	public int getNum_intervals() {
		return num_intervals;
	}

	/**
	 * Set the number of intervals
	 * 
	 * @param numIntervals
	 *            the number of intervals
	 */
	public void setNum_intervals(int numIntervals) {
		num_intervals = numIntervals;
	}

	/**
	 * Get the class that a label value belongs to
	 * 
	 * @param label
	 *            the label value
	 * @return the class
	 */
	public int getLabelClass(double label) {
		if (attribute_type == NOMINAL_TYPE)
			return (int) label;
		else {
			for (int i = 0; i < num_intervals; i++)
				if (label > lower_bounds[i] && label < upper_bounds[i])
					return i;
		}
		throw new IllegalArgumentException("Label out of bound!");
	}

	/**
	 * Get the number of values (for nominal type) or the number of
	 * intervals(for numeric type)
	 * 
	 * @return
	 */
	public int getLabelNum() {
		return attribute_type == NOMINAL_TYPE ? attribute_values.size()
				: num_intervals;
	}
}

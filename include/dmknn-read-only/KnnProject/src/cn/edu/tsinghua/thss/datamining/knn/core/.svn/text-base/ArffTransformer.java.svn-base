package cn.edu.tsinghua.thss.datamining.knn.core;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Vector;

import cn.edu.tsinghua.thss.datamining.knn.model.Attribute;
import cn.edu.tsinghua.thss.datamining.knn.model.DataSet;
import cn.edu.tsinghua.thss.datamining.knn.model.Instance;

/**
 * Defines a file transformer which reads an .arff file and translates it into a
 * dataset.
 * 
 * @author Han Lu
 * 
 */
public class ArffTransformer {
	/** The absolute path of the file to read */
	private String file_path;

	/** The generated dataset */
	private DataSet dataset;

	public ArffTransformer(String file_path) {
		this.file_path = file_path;
	}

	/**
	 * Translates the file into the dataset.
	 * 
	 * @return the dataset
	 */
	public DataSet getDatasetFromFile() {
		Vector<Attribute> attributes = new Vector<Attribute>();
		try {
			FileReader fr = new FileReader(file_path);
			BufferedReader br = new BufferedReader(fr);
			String Line = br.readLine();
			Line = br.readLine();
			Line = br.readLine();

			while (Line.length() != 0) // go to the third line,read attribute
			// value
			{
				String[] spLine = Line.split(" ");
				String attribute_name = spLine[1];
				int type;
				Vector<String> attribute_values = new Vector<String>();
				if (spLine[2].equals("numeric")) {
					type = Attribute.NUMERIC_TYPE;
					attribute_values.add(null);
				} else {
					type = Attribute.NOMINAL_TYPE;
					String[] aValues = spLine[2].substring(1,
							spLine[2].length() - 1).split(",");// get values
					// between {}
					for (int i = 0; i < aValues.length; i++) {
						attribute_values.add(aValues[i]);
					}
				}

				attributes.add(new Attribute(attribute_name, type,
						attribute_values));
				Line = br.readLine();
			}

			Attribute target = attributes.get(attributes.size() - 1);
			attributes.remove(attributes.size() - 1);
			dataset = new DataSet(attributes, target);
			Line = br.readLine(); // read instance data
			if (!Line.equals("@data"))
				System.out.println("error!can't read instance date");
			else {
				Line = br.readLine();

				while (Line != null) {
					Vector<Double> feature_values = new Vector<Double>();
					String[] fValues = Line.split(",");
					int length = fValues.length;
					for (int j = 0; j < length - 1; j++) {
						Attribute attribute = attributes.get(j);
						if (fValues[j].equals("?"))
							feature_values.add(Double.NaN);
						else if (attribute.getAttribute_type() == Attribute.NOMINAL_TYPE)
							feature_values.add(attribute
									.getNumericValue(fValues[j]));
						else
							feature_values.add(Double.parseDouble(fValues[j]));
					}
					double label = target.getNumericValue(fValues[length - 1]);
					dataset.addInstance(new Instance(feature_values, label));
					Line = br.readLine();
				}
			}

		} catch (IOException e) {
			e.printStackTrace();
		}

		return dataset;

	}
}

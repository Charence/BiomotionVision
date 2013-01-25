package svmlearn;

import java.io.*;
import java.util.*;

/**
 * Class representing an optimization problem (a data setting);
 * taken from liblinear; "bias" excluded
 * @author miafranc
 *
 */
public class Problem {
	/** The number of training data */
	public int l;
	/** The number of features (including the bias feature if bias &gt;= 0) */
	public int n;
	/** Array containing the target values */
	public int[] y;
	/** Map of categories to allow various ID's to identify classes with. */
	public CategoryMap<Integer> catmap;
	/** Array of sparse feature nodes */
	public FeatureNode[][] x;
	public Problem() {
		l = 0;
		n = 0;
		catmap = new CategoryMap<Integer>();
	}
	/**
	 * Loads a binary problem from file, i.e. having 2 classes.
	 * @param filename The filename containing the problem in LibSVM format.
	 */
	public void loadBinaryProblem(String filename) {
		String row;
		ArrayList<Integer> classes = new ArrayList<Integer>();
		ArrayList<FeatureNode []> examples = new ArrayList<FeatureNode []>();
		try {
			BufferedReader r = new BufferedReader(new FileReader(filename));
			while ((row = r.readLine()) != null) {
				String [] elems = row.split(" ");
				//Category:
				if (elems[0].charAt(0) == '+') {//to allow for example +1 as class label
					elems[0] = elems[0].substring(1);
				}
				Integer cat = Integer.parseInt(elems[0]);
				catmap.addCategory(cat);
				if (catmap.size() > 2) {
					throw new IllegalArgumentException("only 2 classes allowed!");
				}
				classes.add(catmap.getNewCategoryOf(cat));
				//Index/value pairs:
				examples.add(parseRow(elems));
			}
			x = new FeatureNode[examples.size()][];
			y = new int[examples.size()];
			for (int i=0; i<examples.size(); i++) {
				x[i] = examples.get(i);
				y[i] = 2*classes.get(i)-1; //0,1 => -1,1
			}
			l = examples.size();
		} catch (Exception e) {
			System.out.println(e);
		}
	}
	/**
	 * Parses a row from a LibSVM format file.
	 * @param row The already split row on spaces.
	 * @return The corresponding FeatureNode.
	 */
	public FeatureNode [] parseRow(String [] row) {
		FeatureNode [] example = new FeatureNode[row.length-1];
		int maxindex = 0;
		for (int i=1; i<row.length; i++) {
			String [] iv = row[i].split(":");
			int index = Integer.parseInt(iv[0]);
			if (index <= maxindex) {
				throw new IllegalArgumentException("indices must be in increasing order!");
			}
			maxindex = index;
			double value = Double.parseDouble(iv[1]);
			example[i-1] = new FeatureNode(index, value);
		}
		if (n < maxindex)
			n = maxindex;
		return example;
	}
}

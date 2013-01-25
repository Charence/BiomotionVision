package svmlearn;

/**
 * Class representing a feature;
 * taken from liblinear
 * @author miafranc
 *
 */
public class FeatureNode {
	public final int index;
	public final double value;

	public FeatureNode(final int index, final double value) {
		if (index < 1) throw new IllegalArgumentException("index must be >= 1");
		this.index = index;
		this.value = value;
	}
}

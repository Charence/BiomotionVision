package svmlearn;

/**
 * Class providing some general purpose kernels: 
 * linear, polynomial, Gaussian (RBF) and tanh (sigmoid)
 * @author miafranc
 *
 */
public class Kernel {
	/**
	 * Calculates the squared Euclidean distance of two vectors
	 * @param x the first point (vector)
	 * @param z the second point (vector)
	 * @return The squared Euclidean distance
	 */
	public static double euclidean_dist2(FeatureNode [] x, FeatureNode [] z) {
		double sum=0;
		int i,j;
		for (i=0,j=0;x!=null && z!=null && i<x.length && j<z.length;) {
			if (x[i].index<z[j].index) {
				sum+=x[i].value*x[i].value;
				i++;
			}
			else if (z[j].index<x[i].index) {
				sum+=z[j].value*z[j].value;
				j++;
			}
			else {
				sum+=(x[i].value-z[j].value)*(x[i].value-z[j].value);
				i++;
				j++;
			}
		}
		for (;x!=null && i<x.length;i++) {
			sum+=x[i].value*x[i].value;
		}
		for (;z!=null && j<z.length;j++) {
			sum+=z[j].value*z[j].value;
		}
		return sum;
	}
	/**
	 * Calculates the dot product of two vectors
	 * @param x the first vector
	 * @param z the second vector
	 * @return The dot product of the vectors
	 */
	public static double dot_product(FeatureNode [] x, FeatureNode [] z) {
		double sum=0;
		int i,j;
		for (i=0,j=0;x!=null && z!=null && i<x.length && j<z.length;) {
			if (x[i].index<z[j].index) {
				i++;
			}
			else if (z[j].index<x[i].index) {
				j++;
			}
			else {
				sum+=x[i].value*z[j].value;
				i++;
				j++;
			}
		}
		return sum;
	}
	/**
	 * Linear kernel: k(x,z) = <x,z>
	 * @param x first vector
	 * @param z second vector
	 * @return linear kernel value
	 */
	public static double kLinear(FeatureNode [] x, FeatureNode [] z) {
		return dot_product(x, z);
	}
	/**
	 * Polynomial kernel: k(x,z) = (a*<x,z>+b)^c
	 * @param x first vector
	 * @param z second vector
	 * @param a coefficient of <x,z>
	 * @param b bias
	 * @param c power
	 * @return polynomial kernel value
	 */
	public static double kPoly(FeatureNode [] x, FeatureNode [] z, double a, double b, double c) {
		if (c == 1.0)
			return a*dot_product(x, z)+b;
		return Math.pow(a*dot_product(x, z)+b, c);
	}
	/**
	 * Gaussian (RBF) kernel: k(x,z) = (-0.5/sigma^2)*||x-z||^2
	 * @param x first vector
	 * @param z second vector
	 * @param sigma parameter (standard deviation)
	 * @return Gaussian kernel value
	 */
	public static double kGaussian(FeatureNode [] x, FeatureNode [] z, double sigma) {
		return (-0.5/sigma*sigma)*euclidean_dist2(x, z);
	}
	/**
	 * Tanh (sigmoid) kernel: k(x,z) = tanh(a*<x,z>+b)
	 * @param x first vector
	 * @param z second vector
	 * @param a coefficient of <x,z>
	 * @param b bias
	 * @return tanh kernel value
	 */
	public static double kTanh(FeatureNode [] x, FeatureNode [] z, double a, double b) {
		return Math.tanh(a*dot_product(x, z)+b);
	}
}

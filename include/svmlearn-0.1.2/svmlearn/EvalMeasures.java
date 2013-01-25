package svmlearn;

public class EvalMeasures {
	double [] tp;
	double [] fp;
	double [] fn;
	Problem p;
	int [] predicted;
	int catnum;
	int computed;
	
	public EvalMeasures(Problem p, int [] predicted, int catnum) {
		if (predicted.length != p.l) {
			System.err.println("Length error!");
			return;
		}
		this.p = p;
		this.predicted = predicted;
		this.catnum = catnum;
		computed = 0;
	}
	public double Accuracy() {
		int ret = 0;
		for (int i=0; i<p.l; i++) {
			if (p.y[i] == predicted[i]) {
				ret++;
			}
		}
		return (double)ret/p.l;
	}
}

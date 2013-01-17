import com.googlecode.javacv.CanvasFrame;
import com.googlecode.javacv.cpp.opencv_core.IplImage;


public class IndexedCanvasFrame extends CanvasFrame {
	
	int updateCounter;

	public IndexedCanvasFrame() {
		super("", 1); // gamma = 1
		resetUpdateCounter();
	}
	
	public int getUpdateCount() {
		return updateCounter;
	}
	
	public void resetUpdateCounter() {
		updateCounter = 0;
	}
	
	public void incrementUpdateCounter() {
		updateCounter++;
	}
	
	public void showImage(IplImage image) {
		super.showImage(image);
		incrementUpdateCounter();
	}

}

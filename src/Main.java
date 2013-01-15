import javax.swing.JFrame;

import com.googlecode.javacpp.Loader;
import com.googlecode.javacv.*;
import com.googlecode.javacv.cpp.*;
import static com.googlecode.javacv.cpp.opencv_core.*;
import static com.googlecode.javacv.cpp.opencv_highgui.*;
import static com.googlecode.javacv.cpp.opencv_imgproc.*;
import static com.googlecode.javacv.cpp.opencv_video.*;

import com.googlecode.javacv.CanvasFrame;
import com.googlecode.javacv.cpp.opencv_core.IplImage;


public class Main {
	// model background using Mixture of Gaussian (see paper)
	private static BackgroundSubtractor background = new BackgroundSubtractorMOG2();
	private static CanvasFrame frame;
	
	public static void main(String [] args) {
		frame = new CanvasFrame("Test");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		String filename = "/home/charence/Workspace/biomotion-vision/images/set2/1/10/frame%04d.jpg";
		int start = 0;
		int end = 10;// 2485;
		
		for (int i = start; i <= end; i++) {
			addImage(String.format(filename, i));
		}
	}
	
	/**
	 * Processes an image
	 * @param filename
	 */
	private static void addImage(String filename) {
		IplImage image = cvLoadImage(filename);
		if (image != null) {
			frame.showImage(image);
			
			// background subtraction
			CvMat fgmask = CvMat.create(image.height(), image.width());
			background.apply(image, fgmask, 0.2);
			// subtract background from original image
			//foreground = null;
			
			// edge information
			
			// weight map and weighted-gradient image
			// apply Gaussian filter (size = 9 and sd = 1.5) to edge information from foreground image
			// create Gaussian filter
			// filter
			// multiply gradient image of original input with weight map image
			
			// snake algorithm
			//cvSaveImage(filename, image);
			cvReleaseImage(image);
		}
		//frame.dispose();
	}
}

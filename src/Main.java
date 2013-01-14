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
	public static void main(String [] args) {
		CanvasFrame frame = new CanvasFrame("Test");
		
		String filename = "/Users/charence/Workspace/biomotion-vision/images/set2/1/10/frame0000.jpg";
		
		IplImage image = cvLoadImage(filename);
		if (image != null) {
			frame.showImage(image);
			
			// background subtraction
			// model background using Mixture of Gaussian (see paper)
			BackgroundSubtractor background = new BackgroundSubtractorMOG2();
			CvMat fgmask = new CvMat();
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
			cvSaveImage(filename, image);
			cvReleaseImage(image);
		}
		frame.dispose();
	}
}

import java.util.HashMap;

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
	private static BackgroundSubtractor bgmodel = new BackgroundSubtractorMOG2();
	//private static CanvasFrame canvas = new CanvasFrame("", 1);   // gamma=1
	private static HashMap<String, CanvasFrame> canvases = new HashMap<String, CanvasFrame>();
	
	public static void main(String [] args) {
		String filename = "/home/charence/Workspace/biomotion-vision/images/set2/1/10/frame%04d.jpg";
		if (System.getProperty("os.name").toLowerCase().indexOf("mac") >= 0)
			filename = filename.replaceAll("home", "Users");
		int start = 0;
		int end = 2485;
		
		// process sequence
		for (int i = start; i <= end; i++) {
			addImage(String.format(filename, i));
		}
		
		// signal end of sequence
		for (CanvasFrame canvas : canvases.values()) {
			canvas.setTitle(canvas.getTitle() + " - done");
		}
	}
	
	/**
	 * Processes an image
	 * @param filename
	 */
	private static void addImage(String filename) {
		IplImage image = cvLoadImage(filename);
		if (image != null) {
			// background subtraction
			IplImage fgmask = IplImage.create(image.width(), image.height(), image.depth(), 1);
			bgmodel.apply(image, fgmask, 0.001);
			cvSmooth(fgmask, fgmask, CV_GAUSSIAN, 5);
			IplImage background = IplImage.create(image.width(), image.height(), image.depth(), 3);
			bgmodel.getBackgroundImage(background);
			// subtract background from original image
			IplImage foreground = IplImage.create(image.width(), image.height(), image.depth(), 3);
			cvNot(fgmask, fgmask);
			//cvSubS(image, CV_RGB(0,0,0), foreground, fgmask);
			cvSub(image, image, foreground, fgmask);
			//ShowImage(image, "Original");
			//ShowImage(foreground, "Foreground");
			ShowImage(fgmask, "fgmask");
			ShowImage(background, "Background");
			
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
	
	private static void ShowImage(IplImage image, String caption) {
		CvMat mat = image.asCvMat();
		int width = mat.cols(); if(width < 1) width = 1;
		int height = mat.rows(); if(height < 1) height = 1;
		double aspect = 1.0 * width / height;
		if(height < 128) { height = 128; width = (int) ( height * aspect ); }
		if(width < 128) width = 128;
		height = (int) ( width / aspect );
		ShowImage(image, caption, width, height);
	}

	public static void ShowImage(IplImage image, String caption, int size) {
		if(size < 128) size = 128;
		CvMat mat = image.asCvMat();
		int width = mat.cols(); if(width < 1) width = 1;
		int height = mat.rows(); if(height < 1) height = 1;
		double aspect = 1.0 * width / height;
		if(height != size) { height = size; width = (int) ( height * aspect ); }
		if(width != size) width = size;
		height = (int) ( width / aspect );
		ShowImage(image, caption, width, height);
	}
	
	public static void ShowImage(IplImage image, String caption, int width, int height) {
		CanvasFrame canvas = canvases.get(caption);
		if (null == canvas) {
			canvas = new CanvasFrame("", 1); // gamma = 1
			canvas.setDefaultCloseOperation(javax.swing.JFrame.EXIT_ON_CLOSE);
			canvases.put(caption, canvas);
		}
		canvas.setTitle(caption); // + "" + canvas.getUpdateCount());
		canvas.setCanvasSize(width, height);
		canvas.showImage(image);
	}
}

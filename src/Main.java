import java.util.HashMap;

import javax.swing.JFrame;

import com.googlecode.javacpp.Loader;
import com.googlecode.javacv.*;
import com.googlecode.javacv.cpp.*;
import static com.googlecode.javacv.cpp.opencv_core.*;
import static com.googlecode.javacv.cpp.opencv_highgui.*;
import static com.googlecode.javacv.cpp.opencv_imgproc.*;
import static com.googlecode.javacv.cpp.opencv_video.*;
import static com.googlecode.javacv.cpp.opencv_legacy.*;

import com.googlecode.javacv.CanvasFrame;
import com.googlecode.javacv.cpp.opencv_core.IplImage;

public class Main {
	// model background using Mixture of Gaussian (see paper)
	private static final int history = 200;
	private static final int varThreshold = 48;
	private static BackgroundSubtractorMOG2 bgmodel = new BackgroundSubtractorMOG2(history, varThreshold, true);
	private static double learningRate = 0.001;
	//private static CanvasFrame canvas = new CanvasFrame("", 1);   // gamma=1
	private static HashMap<String, CanvasFrame> canvases = new HashMap<String, CanvasFrame>();
	private static CvMemStorage contourStorage = CvMemStorage.create();
	
	public static void main(String [] args) {
		int persons = 2;
		
		String filename = "/home/charence/Workspace/biomotion-vision/images/set2/" + persons + "/10/frame%04d.jpg";
		// is it my mac?
		if (System.getProperty("os.name").toLowerCase().indexOf("mac") >= 0)
			filename = filename.replaceAll("home", "Users");
		// is it on doc?
		if (System.getProperty("user.home").toLowerCase().indexOf("homes") >= 0)
			filename = "/media/Charence500/Data/20121221/10/" + persons + "/frame%04d.jpg";
		
		int start = 0;
		int end = 2485; // (2) 2739; // (1) 2485;
		switch(persons) {
			case 1 : end = 2485; break;
			case 2 : end = 3739; break;
			case 3 : end = 4489; break;
		}
		
		// process sequence
		for (int i = start; i <= end; i++) {
			learningRate = (i > 200) ? 0.00001 : 0.01;
			//System.out.println(learningRate);
			if (i == 154)
				System.out.println(i);
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
			// convert to HSV
			IplImage imageHSV = IplImage.create(image.width(), image.height(), image.depth(), 3);
			cvCvtColor(image, imageHSV, CV_RGB2HSV);
			//IplImage greyImage = IplImage.create(image.width(), image.height(), image.depth(), 1);
			//cvCvtColor(image, greyImage, CV_BGR2GRAY);
			//cvCvtColor(greyImage, image, CV_GRAY2BGR);
			//IplImage blurImage = IplImage.create(image.width(), image.height(), image.depth(), 3);
			//cvSmooth(image, blurImage, CV_GAUSSIAN, 7);
			//cvCvtColor(image, image, CV_BGR2HSV);
			
			// split channels
			IplImage imageR = IplImage.create(image.cvSize(), image.depth(), 1);
			IplImage imageG = IplImage.create(image.cvSize(), image.depth(), 1);
			IplImage imageB = IplImage.create(image.cvSize(), image.depth(), 1);
			cvSplit(imageHSV, imageR, imageG, imageB, null);
			ShowImage(imageR, "Red");
			ShowImage(imageG, "Green");
			ShowImage(imageB, "Blue");
			
			// background subtraction
			IplImage fgMask = IplImage.create(image.width(), image.height(), image.depth(), 1);
			bgmodel.apply(image, fgMask, learningRate); //0.001);
			//cvSmooth(fgMask, fgMask, CV_GAUSSIAN, 5);
			//cvDilate(fgMask, fgMask, null, 5);
			//cvErode(fgMask, fgMask, null, 5);
			IplImage background = IplImage.create(image.width(), image.height(), image.depth(), 3);
			bgmodel.getBackgroundImage(background);
			
			// subtract background from original image
			IplImage foreground = IplImage.create(image.width(), image.height(), image.depth(), 3);
			//cvNot(fgMask, fgMask);
			//cvThreshold(fgMask, fgMask, 128, 255, CV_THRESH_BINARY); //127
			//cvSubS(image, CV_RGB(0,0,0), foreground, fgmask);
			cvSub(image, image, foreground, fgMask);
			ShowImage(imageHSV, "Original");
			//ShowImage(foreground, "Foreground");
			ShowImage(background, "Background");
			ShowImage(fgMask, "fgmask");
			
			// contours
			//IplImage greyForegroundMask = IplImage.create(image.width(), image.height(), IPL_DEPTH_8U, 1);
			//cvCvtColor(weightedGradient, greyWeightedGradient, CV_RGB2GRAY);
			//cvThreshold(greyWeightedGradient, greyWeightedGradient, 127, 255, CV_THRESH_BINARY);
			// find contour
			CvSeq contours = new CvSeq(new CvPoint());
			int contourCount = cvFindContours(fgMask, contourStorage, contours, Loader.sizeof(CvContour.class), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
			while (null != contours) {
				cvDrawContours(image, contours, CV_RGB(Math.random()*255,Math.random()*255,Math.random()*255), cvScalarAll(255), 1, CV_FILLED, 8, cvPoint(0,0));
				contours = (contourCount > 0) ? contours.h_next() : null; // some kind of strange javacv bug...
			}
			ShowImage(image, "Contours");

			/*
			// edge information
			// http://docs.opencv.org/doc/tutorials/imgproc/imgtrans/canny_detector/canny_detector.html
			IplImage edgeMask = IplImage.create(image.width(), image.height(), image.depth(), 1);
			int lowThreshold = 100;
			int ratio = 3;
			int kernelSize = 3;
			blur(fgMask, edgeMask,  cvSize(3,3), cvPoint(-1,1), BORDER_DEFAULT);
			cvCanny(edgeMask, edgeMask, lowThreshold, lowThreshold*ratio, kernelSize);
			//IplImage edges = IplImage.create(image.width(), image.height(), image.depth(), 3);
			//image.copyTo(edges, edgeMask);
			ShowImage(edgeMask, "Edges");
			
			// weight map and weighted-gradient image
			// apply Gaussian filter (size = 9 and sd = 1.5) to edge information from foreground image
			// create Gaussian filter
			IplImage weightMap = IplImage.create(image.width(), image.height(), image.depth(), 1);
			CvSize weightMapKernelSize = cvSize(9, 9);
			double sigma = 1.5;
			// filter
			GaussianBlur(edgeMask, weightMap, weightMapKernelSize, sigma, sigma, BORDER_DEFAULT);
			ShowImage(weightMap, "Weight Map");
			// multiply gradient image of original input with weight map image
			// gradient image
			IplImage gradient = IplImage.create(image.width(), image.height(), image.depth(), 3);
			int xorder = 1;
			int yorder = 1;
			cvSobel(image, gradient, xorder, yorder, 3);
			ShowImage(gradient, "Gradient Image");
			// weighted-gradient image
			IplImage weightedGradient = IplImage.create(image.width(), image.height(), image.depth(), 3);
			//IplImage weightMapT = IplImage.create(weightMap.height(), weightMap.width(), weightMap.depth(), 3);
			//cvTranspose(weightMap, weightMapT);
			//cvMultiplyAcc(gradient, weightMapT, weightedGradient, null);
			IplImage colourWeightMap = IplImage.create(image.width(), image.height(), image.depth(), 3);
			cvCvtColor(weightMap, colourWeightMap, CV_GRAY2BGR);
			cvMul(gradient, colourWeightMap, weightedGradient, 1);
			ShowImage(weightedGradient, "Weighted-Gradient Image");
			
			// snake algorithm
			IplImage greyWeightedGradient = IplImage.create(image.width(), image.height(), IPL_DEPTH_8U, 1);
			cvCvtColor(weightedGradient, greyWeightedGradient, CV_RGB2GRAY);
			cvThreshold(greyWeightedGradient, greyWeightedGradient, 127, 255, CV_THRESH_BINARY);
			// find contour
			CvSeq contours = new CvSeq(new CvPoint());
			int contourCount = cvFindContours(greyWeightedGradient, contourStorage, contours, Loader.sizeof(CvContour.class), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
			while (null != contours) {
				cvDrawContours(image, contours, CV_RGB(Math.random()*255,Math.random()*255,Math.random()*255), cvScalarAll(255), 1, 1, 8, cvPoint(0,0));
				contours = (contourCount > 0) ? contours.h_next() : null; // some kind of strange javacv bug...
			}
			ShowImage(image, "Contours");
			// snake
			//float[] test = {1};
			//cvSnakeImage(greyWeightedGradient, contours, 1, test, test, test, 1, cvSize(1,1), cvTermCriteria(1, 1, 1.0), 1);
			 */
			
			//cvSaveImage("result_" + filename, image);
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

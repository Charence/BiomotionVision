#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <vector>
#include <stdexcept>

#include <opencv2/core/core.hpp>
#include <opencv2/video/background_segm.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/video/tracking.hpp>

//#include "object_info.hpp"
#include "object_tracker.hpp"
#include "point_tracker.h"
#include "filepath.h"

#define PI 3.14159265

using namespace cv;
using namespace std;

// methods
static vector<ObjectInfo> detectObjects(cv::Mat image);
static void trackObjects(vector<ObjectInfo> detectedObjects);

// constants
const int history = 200;
const int varThreshold = 48;
cv::RNG rng(12345);
const bool drawContour = true;
const bool drawRectangle = false;
const bool drawEllipse = false;
const bool drawCircle = true;
const bool drawLines = false;
const bool storeContourArea = false;
const bool storeRectangleCenter = true;
const bool storeRectangleAngle = false;
const bool storeRectangleSize = false;
const bool storeCircleCenter = false;
const bool storeCircleRadius = true;

// global vars
static double learningRate = 0.001;
static cv::BackgroundSubtractorMOG2 bgmodel;
static cv::KalmanFilter KF(2, 1, 0);
static cv::Mat state(2, 1, CV_32F); // (phi, delta_phi)
static cv::Mat processNoise(2, 1, CV_32F);
static cv::Mat measurement = Mat::zeros(1, 1, CV_32F);
//ObjectTracker* objectTracker = new ObjectTracker();
PointTracker pointTracker;
static int imageNum;

int main(int argc, const char** argv) {
	int persons = 1;
	const bool recalibrate = true;

	// setup path to file
	char* filepath;
	filepath = "/home/charence/Workspace/biomotion-vision/images/set2/%d/10/frame%04d.jpg";
	// is it my mac?
	#ifdef MYMAC
	filepath = "/Users/charence/Workspace/biomotion-vision/images/set2/%d/10/frame%04d.jpg";
	#endif
	// is it on doc?
	#ifdef ONDOC
	filepath = "/media/Charence500/Data/20121221/10/%d/frame%04d.jpg";
	#endif

	int start = 0;
	int end = 2485;
	switch(persons) {
		case 1: end = 2485; break;
		case 2: end = 3621; break;
		case 3: end = 4489; break;
	}

	// setup background model
	bgmodel.set("history", history);
	bgmodel.set("varThreshold", varThreshold);
	bgmodel.set("detectShadows", true);

	// setup homography
	if (recalibrate) {
	}
	else {
	}

	// setup tracker
	pointTracker.setArguments(3.5, 1.5);

	//cout << "ImageNum,ContourArea,RectCentreX,RectCentreY,RectAngle,RectWidth,RectHeight,CircCentreX,CircCentreY,Radius" << endl;
	//cout << "ImageNum,ContourArea,CircCentreX,CircCentreY,Radius" << endl;

	// process sequence
	for (int i = start; i <= end; i++) {
		char filename [128];
		sprintf(filename, filepath, persons, i);
		//cout << "In: " << filename << endl;
		imageNum = i;
		// load image
		cv::Mat image = cv::imread(filename);
		if (image.empty()) {
			throw runtime_error("Could not load image");
		}

		// detect objects
		learningRate = (i > 200) ? 0.00005 : 0.01;
		vector<ObjectInfo> detectedObjects = detectObjects(image);
		// homography
		//detectedObjects = ho
		// track objects
		//objectTracker->update(detectedObjects);
		trackObjects(detectedObjects);
		// translate coordinates
	}

	return 0;
}

static vector<ObjectInfo> detectObjects(cv::Mat image) {
	vector<ObjectInfo> objects;

	// convert to HSV
	cv::Mat imageHSV;
	cv::cvtColor(image, imageHSV, CV_BGR2HSV);
	vector<cv::Mat> imageHSVSlices;
	cv::split(imageHSV, imageHSVSlices);
	//cv::threshold(imageHSVSlices[0], imageHSVSlices[0], 160, 200, cv::THRESH_BINARY);

	// background subtraction
	cv::Mat fgMask;
	bgmodel(image, fgMask, learningRate);
	// tidy foreground mask
	cv::GaussianBlur(fgMask, fgMask, cv::Size(1, 1), 0, 0);
	int erosionSize = 5;
	cv::Mat element = cv::getStructuringElement( cv::MORPH_ELLIPSE,
		cv::Size(2*erosionSize+1, 2*erosionSize+1),
		cv::Point( erosionSize, erosionSize ));
	cv::dilate(fgMask, fgMask, element);
	cv::erode(fgMask, fgMask, element);
	cv::erode(fgMask, fgMask, element);
	cv::dilate(fgMask, fgMask, element);
	cv::Mat background;
	bgmodel.getBackgroundImage(background);

	// subtract background from original image
	cv::Mat foreground;
	//cv::not
	cv::threshold(fgMask, fgMask, 128, 255, cv::THRESH_BINARY);
	image.copyTo(foreground, fgMask);

	// edge information
	int lowThreshold = 100;
	int ratio = 3;
	int kernelSize = 3;
	cv::Mat imageCanny;
	cv::Canny(foreground, imageCanny, lowThreshold, lowThreshold*ratio, kernelSize);

	// weight map and weighted-gradient image
	// apply Gaussian filter (size = 9 and sigma = 1.5) to edge information from foreground image
	// create Gaussian filter
	// weight map
	cv::Mat weightMap;
	cv::GaussianBlur(imageCanny, weightMap, cv::Size(9, 9), 1.5, 1.5);
	// gradient image
	cv::Mat imageGray;
	cv::cvtColor(image, imageGray, CV_BGR2GRAY);
	cv::Mat imageGradient;
	cv::Mat imageGradientX;
	cv::Mat imageGradientY;
	cv::Mat imageAbsGradientX;
	cv::Mat imageAbsGradientY;
	cv::Sobel(imageGray, imageGradientX, CV_16S, 1, 0, 3, 1, 0, cv::BORDER_DEFAULT);
	cv::Sobel(imageGray, imageGradientY, CV_16S, 0, 1, 3, 1, 0, cv::BORDER_DEFAULT);
	cv::convertScaleAbs(imageGradientX, imageAbsGradientX);
	cv::convertScaleAbs(imageGradientY, imageAbsGradientY);
	cv::addWeighted(imageAbsGradientX, 0.5, imageAbsGradientY, 0.5, 0, imageGradient);
	// weighted-gradient image
	cv::Mat weightedGradient;
	cv::Mat colourWeightMap;
	weightedGradient = imageGradient.mul(weightMap);

	// contours
	vector< vector<cv::Point> > contours;
	vector<cv::Vec4i> hierarchy;
	cv::findContours(weightedGradient, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
	//cv::findContours(fgMask, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
	
	// rotated rectangles for contour
	vector<cv::RotatedRect> minRect(contours.size());
	vector<cv::RotatedRect> minEllipse(contours.size());
	vector< vector<cv::Point> > contoursPoly(contours.size());
	vector<cv::Point2f> center(contours.size());
	vector<float> radius(contours.size());
	for (int i = 0; i < contours.size(); i++) {
		minRect[i] = cv::minAreaRect(cv::Mat(contours[i]));
		if (contours[i].size() > 5) {
			minEllipse[i] = fitEllipse(cv::Mat(contours[i]));
		}
		approxPolyDP(cv::Mat(contours[i]), contoursPoly[i], 3, true);
		minEnclosingCircle((cv::Mat)contoursPoly[i], center[i], radius[i]);
	}

	// draw contours
	cv::Mat imageContours = cv::Mat::zeros(imageCanny.size(), CV_8UC3);
	for (int i = 0; i < contours.size(); i++) {
		if (abs(PI*pow(radius[i],2) - contourArea(contours[i], false))/(PI*pow(radius[i],2)) < 0.55 && radius[i] > 10) { //40) {
			cv::Scalar colour = cv::Scalar(rng.uniform(0, 255), rng.uniform(0, 255), rng.uniform(0, 255));
			// contour
			if (drawContour)
				drawContours(imageContours, contours, i, colour, 2, 8, hierarchy, 0, cv::Point());
			// rotated rectangle
			if (drawRectangle) {
				cv::Point2f rectPoints[4];
				minRect[i].points(rectPoints);
				for (int j = 0; j < 4; j++) {
					//line(imageContours, rectPoints[j], rectPoints[(j+1)%4], colour, 1, 8);
				}
			}
			// ellipse
			if (drawEllipse)
				ellipse(imageContours, minEllipse[i], colour, 2, 8);
			// circle
			if (drawCircle)
				circle(imageContours, center[i], (int)radius[i], colour, 2, 8, 0);
			// image centre
			cv::Point2f imageCentre(imageContours.size().width/2, imageContours.size().height/2);
			// line from contour to centre of image
			if (drawLines)
				line(imageContours, minRect[i].center, imageCentre, colour, 1, 8);
			// find angle of contour
			double angle;
			if (minRect[i].center.x <= imageCentre.x && minRect[i].center.y < imageCentre.y) {
				// top left quad
				angle = atan((imageCentre.x - minRect[i].center.x)/(imageCentre.y - minRect[i].center.y));
			}
			else if (minRect[i].center.x <= imageCentre.x) {
				// bottom left quad
				angle = PI - atan((imageCentre.x - minRect[i].center.x)/(minRect[i].center.y - imageCentre.y));
			}
			else if (minRect[i].center.x > imageCentre.x && minRect[i].center.y > imageCentre.y) {
				// bottom right quad
				angle = PI + atan((minRect[i].center.x - imageCentre.x)/(minRect[i].center.y - imageCentre.y));
			}
			else {
				// top right quad
				angle = 2*PI - atan((minRect[i].center.x - imageContours.size().width/2)/(imageContours.size().height/2 - minRect[i].center.y));
			}
			angle = angle * 180/PI;
			/*
			// extract rotated ROI
			// http://answers.opencv.org/question/497/extract-a-rotatedrect-area/
			// get angle and size from bounding box
			angle = minRect[i].angle;
			cv::Size rectSize = minRect[i].size;
			// thanks to http://felix.abecassis.me/2011/10/opencv-rotation-deskewing
			if (angle < -45) {
				angle += 90;
				swap(rectSize.width, rectSize.height);
			}
			// rotation matrix
			cv::Mat rotationMatrix = cv::getRotationMatrix2D(minRect[i].center, angle, 1);
			cv::Mat rotationMatrixInverse = cv::getRotationMatrix2D(minRect[i].center, -angle, 1);
			// perform affine transformation
			cv::Mat rotated;
			cv::warpAffine(image, rotated, rotationMatrix, image.size(), cv::INTER_CUBIC);
			// crop the image
			cv::Mat cropped;
			try {
				cv::getRectSubPix(rotated, rectSize, minRect[i].center, cropped);
				cv::imshow("Cropped " +i, cropped);
			}
			catch (cv::Exception e) {
			}
			*/
			/*
			// rotate contour
			cv::Mat contourMat(3, contours[i].size(), CV_64FC1);
			double* row0 = contourMat.ptr<double>(0);
			double* row1 = contourMat.ptr<double>(1);
			double* row2 = contourMat.ptr<double>(2);
			for (int j = 0; j < (int) contours[i].size(); j++) {
				row0[j] = (double) (contours[i])[j].x;
				row1[j] = (double) (contours[i])[j].y;
				row2[j] = 1;
			}
			cv::Mat uprightContour = rotationMatrix * contourMat;
			cv::imshow("upright " + i, uprightContour);
			// find bounding box
			try {
				cv::Rect boundRect = cv::boundingRect(uprightContour);
			}
			catch (cv::Exception e) {
			}*/
			//rectangle(imageContours, boundRect[i].tl(), boundRect[i].br(), colour, 2, 8, 0);
	
			// save object
			ObjectInfo object(minRect[i], contours[i]);
			objects.push_back(object);
			cout << imageNum;
			if (storeContourArea)
				cout << "," << cv::contourArea(contours[i], false);
			if (storeRectangleCenter)
				cout << "," << minRect[i].center.x << "," << minRect[i].center.y;
			if (storeRectangleAngle)
				cout << "," << minRect[i].angle;
			if (storeRectangleSize)
				cout << "," << minRect[i].size.width << "," << minRect[i].size.height; 
			if (storeCircleCenter)
				cout << "," << center[i].x << "," << center[i].y;
			if (storeCircleRadius)
				cout << "," << (int)radius[i];
			cout << endl;
		}
	}

	/*cv::imshow("Original", image);
	cv::imshow("Hue", imageHSVSlices[0]);
	cv::imshow("Saturation", imageHSVSlices[1]);
	//cv::imshow("Value", imageHSVSlices[2]);*/
	cv::imshow("fgMask", fgMask);
	cv::imshow("Foreground", foreground);/*
	cv::imshow("Canny", imageCanny);
	cv::imshow("WeightMap", weightMap);
	cv::imshow("Gradient Image", imageGradient);
	cv::imshow("Weighted-Gradient Image", weightedGradient);*/
	cv::imshow("Contours", imageContours);
	cvWaitKey(5);
	
	return objects;
}

static void trackObjects(vector<ObjectInfo> detectedObjects) {
	// convert format of detected objects
	const vector<cv::Mat > observations;
	// lock the tracking class as we are updating the Kalman filters
	// calculate the time since the last prediction
	const double timeDiff = (static_cast<double>(cv::getTickCount()) - pointTracker.updateLastPredictionTime()) / cv::getTickFrequency();
	// perform prediction
	pointTracker.predict(timeDiff);
	// set last prediction time
	//setLastPredictionTime(static_cast<double>(cv::getTickCount())); // updateLastPredictionTime gets and sets time
	// perform update
	pointTracker.update(observations);
	// unlock the tracking class
}

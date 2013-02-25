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
#define BODYSIZE 40

using namespace cv;
using namespace std;

// methods
//static vector<ObjectInfo> detectObjects(cv::Mat image);
static vector<cv::Mat> detectObjects(cv::Mat image);
//static void trackObjects(vector<ObjectInfo> detectedObjects);
static void trackObjects(vector<cv::Mat> detectedObjects);
static double euclideanDistance(cv::Point p, cv::Point q);
static float getContourRadius(vector<cv::Point> contour);
static bool isBody(vector<cv::Point> contour);
static bool isHead(vector<cv::Point> contour, vector<cv::Point> bodyContour);
static void predictObjects(cv::Mat image);

// constants
const int history = 200;
const int varThreshold = 48;
cv::RNG rng(12345);
const bool drawContour = true;
const bool drawRectangle = true;
const bool drawEllipse = false;
const bool drawCircle = true;
const bool drawLines = false;
const bool storeContourArea = false;
const bool storeRectangleCenter = true;
const bool storeRectangleAngle = false;
const bool storeRectangleSize = false;
const bool storeCircleCenter = false;
const bool storeCircleRadius = true;
const cv::Scalar colourRed = cv::Scalar(0, 0, 255);
const cv::Scalar colourWhite = cv::Scalar(255, 255, 255);

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

	// read args
	if (argc > 1)
		persons = atoi(argv[1]);

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
		/*if (i > 200)
			i = 1050; // 999; // 1050;*/
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
		//vector<ObjectInfo> detectedObjects = detectObjects(image);
		vector<cv::Mat> detectedObjects = detectObjects(image);
		// homography
		//detectedObjects = ho
		// track objects
		//objectTracker->update(detectedObjects);
		trackObjects(detectedObjects);
		predictObjects(image);
		// translate coordinates
	}

	return 0;
}

//static vector<ObjectInfo> detectObjects(cv::Mat image) {
static vector<cv::Mat> detectObjects(cv::Mat image) {
	vector<ObjectInfo> objects;
	vector<cv::Mat> points;

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
	//cv::imshow("back", background);

	// subtract background from original image
	cv::Mat foreground;
	//cv::not
	cv::threshold(fgMask, fgMask, 128, 255, cv::THRESH_BINARY);
	image.copyTo(foreground, fgMask);
	cv::imshow("fg", fgMask);
	cv::imshow("fore", foreground);

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

	// object (body) contours
	vector< vector<cv::Point> > objectContours;
	vector<cv::Vec4i> objectHierarchy;
	cv::findContours(fgMask, objectContours, objectHierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));

	// bodies and heads
	// store index of detected body contours and position of head
	vector<int> bodies;
	vector<cv::Point2f> headCenter;
	vector<float> headRadius;

	// detect big bodies
	for (int i = 0; i < objectContours.size(); i++) {
		// if contour is too big
		if (getContourRadius(objectContours[i]) > BODYSIZE*2) {
			// TODO cut down to size
			// TODO consider just slicing it
			// process contour by eroding it
			cv::Mat largeContour = cv::Mat::zeros(imageCanny.size(), CV_8UC3);
			drawContours(largeContour, objectContours, i, colourRed, CV_FILLED, 8, objectHierarchy, 0, cv::Point());
			// erode until large contour becomes 2+
			vector< vector<cv::Point> > largeContours;
			vector<cv::Vec4i> largeHierarchy;
			do {
				cv::erode(largeContour, largeContour, element);
				cv::Canny(largeContour, largeContour, lowThreshold, lowThreshold*ratio, kernelSize);
				cv::findContours(largeContour, largeContours, largeHierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
			} while (largeContours.size() == 1); // || (largeContours.size() == 1 && getContourRadius(largeContours[0]) >= BODYSIZE)); // TODO potential infinite bug here
			for (int j = 0; j < largeContours.size(); j++) {
				objectContours.push_back(largeContours[j]);
			}
		}
	}
	
	cv::Mat bodiesHeads = cv::Mat::zeros(image.size(), CV_8UC3);
	// detect bodies
	for (int i = 0; i < objectContours.size(); i++) {
		if (isBody(objectContours[i])) {
			// predict head position
			cv::Point2f defaultHeadCenter;
			// body bounding box
			cv::RotatedRect minBodyRect;
			minBodyRect = cv::minAreaRect(cv::Mat(objectContours[i]));
			// body bounding circle radius
			float headOffset = getContourRadius(objectContours[i]); //*0.7;
			// image centre
			cv::Point2f imageCentre(image.size().width/2, image.size().height/2);
			// find gradient
			float m = (minBodyRect.center.y - imageCentre.y)/(minBodyRect.center.x - imageCentre.x);
			// find angle
			double angle;
			if (minBodyRect.center.x <= imageCentre.x && minBodyRect.center.y < imageCentre.y) {
				// top left quad
				angle = atan((imageCentre.x - minBodyRect.center.x)/(imageCentre.y - minBodyRect.center.y));
			}
			else if (minBodyRect.center.x <= imageCentre.x) {
				// bottom left quad
				angle = PI - atan((imageCentre.x - minBodyRect.center.x)/(minBodyRect.center.y - imageCentre.y));
			}
			else if (minBodyRect.center.x > imageCentre.x && minBodyRect.center.y > imageCentre.y) {
				// bottom right quad
				angle = PI + atan((minBodyRect.center.x - imageCentre.x)/(minBodyRect.center.y - imageCentre.y));
			}
			else {
				// top right quad
				angle = 2*PI - atan((minBodyRect.center.x - imageCentre.x)/(imageCentre.y - minBodyRect.center.y));
			}
			do {
				headOffset *= 0.7;
				defaultHeadCenter = cv::Point2f(minBodyRect.center.x - headOffset * sin(angle), minBodyRect.center.y - headOffset * cos(angle));
			} while (cv::pointPolygonTest(objectContours[i], defaultHeadCenter, true) <= 0 && headOffset >= 1);
			// store body and head if body big enough for head
			if (headOffset >= 1) {
				// store body
				bodies.push_back(i);
				//angle = angle * 180/PI;
				headCenter.push_back(defaultHeadCenter);
				headRadius.push_back(0); // default head size
				// get detailed contours of body
				cv::Mat bodyMask = cv::Mat::zeros(image.size(), CV_8UC1);
				drawContours(bodyMask, objectContours, i, colourWhite, CV_FILLED, 8, objectHierarchy, 0, cv::Point());
				//cv::floodFill(bodyMask, cv::Point2i(0, 0), cv::Scalar(1));
				cv::Mat body;
				image.copyTo(body, bodyMask);
				//cv::imshow("B", body);
				// body edges
				cv::Mat bodyCanny;
				cv::Canny(body, bodyCanny, lowThreshold, lowThreshold*ratio, kernelSize);
				// weight map
				cv::Mat bodyWeightMap;
				cv::GaussianBlur(bodyCanny, bodyWeightMap, cv::Size(9, 9), 1.5, 1.5);
				// gradient image
				cv::Mat bodyGray;
				cv::cvtColor(body, bodyGray, CV_BGR2GRAY);
				cv::Mat bodyGradient;
				cv::Mat bodyGradientX;
				cv::Mat bodyGradientY;
				cv::Mat bodyAbsGradientX;
				cv::Mat bodyAbsGradientY;
				cv::Sobel(bodyGray, bodyGradientX, CV_16S, 1, 0, 3, 1, 0, cv::BORDER_DEFAULT);
				cv::Sobel(bodyGray, bodyGradientY, CV_16S, 0, 1, 3, 1, 0, cv::BORDER_DEFAULT);
				cv::convertScaleAbs(bodyGradientX, bodyAbsGradientX);
				cv::convertScaleAbs(bodyGradientY, bodyAbsGradientY);
				cv::addWeighted(bodyAbsGradientX, 0.5, bodyAbsGradientY, 0.5, 0, bodyGradient);
				// weighted-gradient image
				cv::Mat bodyWeightedGradient;
				bodyWeightedGradient = bodyGradient.mul(bodyWeightMap);
				// body contours
				vector< vector<cv::Point> > bodyContours;
				vector<cv::Vec4i> bodyHierarchy;
				cv::findContours(bodyWeightedGradient, bodyContours, bodyHierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
				// detect head
				for (int j = 0; j < bodyContours.size(); j++) {
					// process contour by eroding it
					cv::Mat aContour = cv::Mat::zeros(image.size(), CV_8UC3);
					drawContours(aContour, bodyContours, j, colourWhite, CV_FILLED, 8, bodyHierarchy, 0, cv::Point());
					drawContours(bodiesHeads, bodyContours, j, colourWhite, 2, 8, bodyHierarchy, 0, cv::Point());
					cv::erode(aContour, aContour, element);
					//cv::erode(aContour, aContour, element);
					//cv::dilate(aContour, aContour, element);
					cv::Canny(aContour, aContour, lowThreshold, lowThreshold*ratio, kernelSize);
					vector< vector<cv::Point> > subContours;
					vector<cv::Vec4i> subHierarchy;
					cv::findContours(aContour, subContours, subHierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
					//
					for (int k = 0; k < subContours.size(); k++) {
						//cv::drawContours(imageContours, subContours, k, cv::Scalar(0, 255, 0), 2, 8, subHierarchy, 0, cv::Point());
						if (isHead(subContours[k], objectContours[i])) {
							vector<cv::Point> contourPoly;
							cv::Point2f center;
							float radius;
							if (subContours.size() > 1) {
								approxPolyDP(cv::Mat(subContours[k]), contourPoly, 3, true);
							}
							else {
								approxPolyDP(cv::Mat(bodyContours[j]), contourPoly, 3, true);
							}
							minEnclosingCircle((cv::Mat)contourPoly, center, radius);
							float distanceOld = euclideanDistance(headCenter[headCenter.size() - 1], defaultHeadCenter);
							float distanceNew = euclideanDistance(center, defaultHeadCenter);
							if (headRadius[headRadius.size() - 1] == 0 || (distanceOld > 0 && distanceNew < distanceOld)) {
								// store first detected head or store if it is a better detection
								headCenter[headCenter.size() - 1] = center;
								headRadius[headRadius.size() - 1] = radius;
							}
						}
					}
				}
				if (headRadius[headRadius.size() - 1] == 0) {
					headRadius[headRadius.size() - 1] = 10;
				}
			}
		}
	}

	// draw bodies and heads
	//cv::Mat bodiesHeads = cv::Mat::zeros(image.size(), CV_8UC3);
	for (int i = 0; i < bodies.size(); i++) {
		// draw body
		cv::Scalar colour = cv::Scalar(rng.uniform(0, 255), rng.uniform(0, 255), rng.uniform(0, 255));
		drawContours(foreground, objectContours, bodies[i], colour, 2, 8, objectHierarchy, 0, cv::Point());
		circle(foreground, headCenter[i], (int)headRadius[i], colour, 2, 8, 0);
		// body bounding box
		cv::RotatedRect bodyRect;
		bodyRect = cv::minAreaRect(cv::Mat(objectContours[bodies[i]]));
		// output
		cout << imageNum;
		cout << "," << headCenter[i].x << "," << headCenter[i].y << "," << headRadius[i]; // head info
		cout << "," << bodyRect.center.x << "," << bodyRect.center.y;
		cout << "," << cv::contourArea(objectContours[bodies[i]]);
		cout << endl;
		// output points
		cv::Mat point(2, 1, CV_32FC1);
		point.at<float>(0) = headCenter[i].x;
		point.at<float>(1) = headCenter[i].y;
		points.push_back(point);
	}

	//cv::imshow("Original", image);
	//cv::imshow("Hue", imageHSVSlices[0]);
	//cv::imshow("Saturation", imageHSVSlices[1]);
	//cv::imshow("Value", imageHSVSlices[2]);
	cv::imshow("fgMask", fgMask);
	cv::imshow("Foreground", foreground);
	cv::imshow("Canny", imageCanny);
	cv::imshow("WeightMap", weightMap);
	cv::imshow("Gradient Image", imageGradient);
	cv::imshow("Weighted-Gradient Image", weightedGradient);
	//cv::imshow("Contours", imageContours);
	cv::imshow("Body & Head", bodiesHeads);
	cvWaitKey(5);
	
	return points;
	//return objects;
}

static double euclideanDistance(cv::Point p, cv::Point q) {
	cv::Point diff = p - q;
	return cv::sqrt(diff.x*diff.x + diff.y*diff.y);
}

static float getContourRadius(vector<cv::Point> contour) {
	// get radius
	vector<cv::Point> contourPoly;
	cv::Point2f center;
	float radius;
	approxPolyDP(cv::Mat(contour), contourPoly, 3, true);
	minEnclosingCircle((cv::Mat)contourPoly, center, radius);
	return radius;
}

static bool isBody(vector<cv::Point> contour) {
	// min radius based on prior knowledge
	float radius = getContourRadius(contour);
	return BODYSIZE < radius && radius < BODYSIZE*2;
}

static bool isHead(vector<cv::Point> contour, vector<cv::Point> bodyContour) {
	cv::RotatedRect minRect;
	minRect = cv::minAreaRect(cv::Mat(contour));
	// is it within body contour?
	if (cv::pointPolygonTest(bodyContour, minRect.center, true) > 0) {
		vector<cv::Point> contourPoly;
		cv::Point2f center;
		float radius;
		approxPolyDP(cv::Mat(contour), contourPoly, 3, true);
		minEnclosingCircle((cv::Mat)contourPoly, center, radius);
		// compare contour area with circle area
		if (abs(PI*pow(radius,2) - cv::contourArea(contour, false))/(PI*pow(radius,2)) < 0.55 && radius > 8 && radius < 20) {
			// compare contour area with rectangle area
			//cout << "==== " << abs(PI*pow(radius,2) - minRect.size.height*minRect.size.width)/(PI*pow(radius,2)) << endl;
			if (abs(PI*pow(radius,2) - minRect.size.height*minRect.size.width)/(PI*pow(radius,2)) < 0.3) {
			//if (abs(minRect.size.height*minRect.size.width - cv::contourArea(contour, false))/(minRect.size.height*minRect.size.width) < 0.4) {
				return true;
			}
		}
	}
	return false;
}

//static void trackObjects(vector<ObjectInfo> detectedObjects) {
static void trackObjects(vector<cv::Mat> detectedObjects) {
	// convert format of detected objects
	const vector<cv::Mat> observations;
	/*observations.resize(detectedObjects.size());
	for (int i = 0; i < detectedObjects.size(); i++) {
		cv::Mat observation(2, 1, CV_32FC1);
		observation.at<float>(0) = detectedObjects[i].x;
		observation.at<float>(1) = detectedObjects[i].y;
		observations.push_back(observation);
	}*/
	// lock the tracking class as we are updating the Kalman filters
	// calculate the time since the last prediction
	const double timeDiff = (static_cast<double>(cv::getTickCount()) - pointTracker.updateLastPredictionTime()) / cv::getTickFrequency();
	// perform prediction
	pointTracker.predict(timeDiff);
	// set last prediction time
	//setLastPredictionTime(static_cast<double>(cv::getTickCount())); // updateLastPredictionTime gets and sets time
	// perform update
	//pointTracker.update(observations);
	pointTracker.update(detectedObjects);
	// unlock the tracking class
}

static void predictObjects(cv::Mat image) {
	// 
	const double start = static_cast<double>(cv::getTickCount());
	// lock
	// calculate time since last prediction
	const double timeDiff = (static_cast<double>(cv::getTickCount()) - pointTracker.updateLastPredictionTime()) / cv::getTickFrequency();
	// perform prediction
	const vector<cv::Mat> predictedStates = pointTracker.predict(timeDiff);
	for (int i = 0; i < predictedStates.size(); i++) {
		circle(image, cv::Point(predictedStates[i].at<float>(0), predictedStates[i].at<float>(1)), 5, cv::Scalar(255, 0, 0), 2, 8, 0);
	}
	cv::imshow("Tracking", image);
	// set last prediction time
	// already done
	// unlock
}

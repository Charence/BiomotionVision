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

using namespace std;

// methods
static void addImage(const char* filename);

// constants
const int history = 200;
const int varThreshold = 48;
cv::RNG rng(12345);

// global vars
static double learningRate = 0.001;
static cv::BackgroundSubtractorMOG2 bgmodel;
// contourstorage

int main(int argc, const char** argv) {
	int persons = 2;
	bgmodel.set("history", history);
	bgmodel.set("varThreshold", varThreshold);
	bgmodel.set("detectShadows", true);

	const char* filepath = "/home/charence/Workspace/biomotion-vision/images/set2/%d/10/frame%04d.jpg";
	// is it my mac?
	//const char* filepath = "/Users/charence/Workspace/biomotion-vision/images/set2/%d/10/frame%04d.jpg";
	// is it on doc?
	//const char* filepath = "/media/Charence500/Data/20121221/10/%d/frame%04d.jpg";

	int start = 0;
	int end = 2485;
	switch(persons) {
		case 1: end = 2485; break;
		case 2: end = 3622; break;
		case 3: end = 4489; break;
	}

	// process sequence
	for (int i = start; i <= end; i++) {
		char filename [128];
		sprintf(filename, filepath, persons, i);
		learningRate = (i > 200) ? 0.00001 : 0.01;
		addImage(filename);
	}

	// signal end of sequence
	// loop through canvases and add " - done"

	return 0;
}

static void addImage(const char* filename) {
	cout << "In: " << filename << endl;

	// load image
	cv::Mat image = cv::imread(filename);
	if (image.empty()) {
		throw runtime_error("Could not load image");
	}

	// convert to HSV
	cv::Mat imageHSV;
	cv::cvtColor(image, imageHSV, CV_BGR2HSV);
	vector<cv::Mat> imageHSVSlices;
	cv::split(imageHSV, imageHSVSlices);
	//cv::threshold(imageHSVSlices[0], imageHSVSlices[0], 160, 200, cv::THRESH_BINARY);

	// background subtraction
	cv::Mat fgMask;
	bgmodel(image, fgMask, learningRate);
	cv::GaussianBlur(fgMask, fgMask, cv::Size(1, 1), 0, 0);
	int erosionSize = 5;
	cv::Mat element = cv::getStructuringElement( cv::MORPH_ELLIPSE,
		cv::Size(2*erosionSize+1, 2*erosionSize+1),
		cv::Point( erosionSize, erosionSize ));
	cv::dilate(fgMask, fgMask, element);
	cv::erode(fgMask, fgMask, element);
	cv::Mat background;
	bgmodel.getBackgroundImage(background);

	// subtract background from original image
	cv::Mat foreground;
	//cv::not
	cv::threshold(fgMask, fgMask, 128, 255, cv::THRESH_BINARY);
	image.copyTo(foreground, fgMask);

	// contours
	int lowThreshold = 100;
	int ratio = 3;
	int kernelSize = 3;
	cv::Mat imageCanny;
	vector< vector<cv::Point> > contours;
	vector<cv::Vec4i> hierarchy;
	cv::Canny(foreground, imageCanny, lowThreshold, lowThreshold*ratio, kernelSize);
	cv::findContours(imageCanny, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
	
	// draw contours
	cv::Mat imageContours = cv::Mat::zeros(imageCanny.size(), CV_8UC3);
	for (int i = 0; i < contours.size(); i++) {
		cv::Scalar colour = cv::Scalar(rng.uniform(0, 255), rng.uniform(0, 255), rng.uniform(0, 255));
		drawContours(imageContours, contours, i, colour, 2, 8, hierarchy, 0, cv::Point());
	}

	/*cv::imshow("Original", image);
	cv::imshow("Hue", imageHSVSlices[0]);
	cv::imshow("Saturation", imageHSVSlices[1]);
	//cv::imshow("Value", imageHSVSlices[2]);
	cv::imshow("fgMask", fgMask);
	cv::imshow("Foreground", foreground);*/
	cv::imshow("Contours", imageContours);
	cvWaitKey(5);
}

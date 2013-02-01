#include "object_info.hpp"

using namespace std;

ObjectInfo::ObjectInfo( cv::RotatedRect boundingBox, vector<cv::Point> contour ) {
	ObjectInfo( boundingBox, contour, 0 );
}

ObjectInfo::ObjectInfo( cv::RotatedRect boundingBox, vector<cv::Point> contour, double velocity ) {
	this->boundingBox = boundingBox;
	this->contour     = contour;
	this->velocity    = velocity;
}

cv::Point2f ObjectInfo::getCentre() { 
	return boundingBox.center; 
}

int ObjectInfo::getX() { 
	return boundingBox.center.x; 
}

int ObjectInfo::getY() { 
	return boundingBox.center.y; 
}

float ObjectInfo::getAngle() {
	return boundingBox.angle; 
}

cv::Size2f ObjectInfo::getSize() { 
	return boundingBox.size; 
}

//cv::CvBox2D ObjectInfo::getBox() { return boundingBox.box; }

vector<cv::Point> ObjectInfo::getContour() { 
	return contour; 
}

double ObjectInfo::getVelocity() { 
	return velocity; 
}

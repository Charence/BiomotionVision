#include <vector>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/video/tracking.hpp>

using namespace std;

class ObjectInfo {
	protected:
		cv::RotatedRect boundingBox;
		vector<cv::Point> contour;
		double velocity;
	public:
		ObjectInfo( cv::RotatedRect boundingBox, vector<cv::Point> contour );
		ObjectInfo( cv::RotatedRect boundingBox, vector<cv::Point> contour, double velocity );
		cv::Point2f getCentre();
		int getX();
		int getY();
		float getAngle();
		cv::Size2f getSize();
		//cv::CvBox2D getBox();
		vector<cv::Point> getContour();
		double getVelocity();
};

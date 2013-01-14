import static com.googlecode.javacv.cpp.opencv_core.*;
import static com.googlecode.javacv.cpp.opencv_imgproc.*;
import static com.googlecode.javacv.cpp.opencv_highgui.*;

public class Smoother {
	public static void smooth(String filename) {
		IplImage image = cvLoadImage(filename);
		if (image != null) {
			cvSmooth(image, image, CV_GAUSSIAN, 3);
			cvSaveImage(filename, image);
			cvReleaseImage(image);
		}
	}
}

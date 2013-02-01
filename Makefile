CXX = g++ -Wall -Wextra -g3 -c
LD = g++

CPPFLAGS = -I./include -I/usr/local/include/opencv
LDFLAGS = -L/usr/local/lib -lopencv_core -lopencv_imgproc -lopencv_calib3d -lopencv_highgui -lopencv_video


#OBJS = kalman_filter.o point_tracker.o main.o
#OBJS = object_info.o object_tracker.o main.o
OBJS = object_info.o kalman_filter.o point_tracker.o main.o
#OBJS = main.o

all: detector

clean:
	rm -rf $(OBJS) detector

kalman_filter.o: src/kalman_filter.cpp include/kalman_filter.h
	$(CXX) $(CPPFLAGS) src/kalman_filter.cpp -o kalman_filter.o

point_tracker.o: src/point_tracker.cpp include/point_tracker.h include/kalman_filter.h
	$(CXX) $(CPPFLAGS) src/point_tracker.cpp -o point_tracker.o

object_info.o: src/object_info.cpp
	$(CXX) $(CPPFLAGS) src/object_info.cpp -o object_info.o

object_tracker.o: src/object_tracker.cpp
	$(CXX) $(CPPFLAGS) src/object_tracker.cpp -o object_tracker.o

main.o: src/main.cpp
	$(CXX) $(CPPFLAGS) src/main.cpp -o main.o


detector: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o detector

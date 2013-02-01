/**
 * From Stephen McKeague
 */
#ifndef POINT_TRACKER_H
#define POINT_TRACKER_H


#include <vector>
#include <map>

#include <opencv2/core/core.hpp>
#include <opencv2/video/tracking.hpp>

#include "kalman_filter.h"


class PointTracker: KalmanFilter {
 

 public:
  

  // Basic definitions
  PointTracker();

  void setArguments( const float entropy_thresh, const float dist_thresh );

  cv::Mat calcProcessNoise( const float dt );

  // Prediction step
  std::vector< cv::Mat > predict( const float dt );
  
  // Update step
  void update( const std::vector< cv::Mat > &observations );
  

 private:
  
  std::vector< cv::Mat > returnStates();
  
  void createNewFilters( const std::vector< cv::Mat > &observations );


  int dynam_params;

  int measure_params;

  cv::Mat error_cov_post;

  cv::Mat init_transition_mat;

  cv::Mat measurement_mat;

  cv::Mat init_process_noise_cov;

  cv::Mat measurement_noise_cov;

  float dist_thresh;

  
};



#endif

/**
 * From Stephen McKeague
 */
#ifndef KALMAN_FILTER_H
#define KALMAN_FILTER_H



#include <vector>
#include <map>
#include <string>

#include <opencv2/core/core.hpp>
#include <opencv2/video/tracking.hpp>



class KalmanFilter
{

  
 public:
  

  KalmanFilter( const float entropy_thresh );
  
  virtual std::vector< cv::Mat > predict( const float dt ) = 0;
  
  virtual void update( const std::vector< cv::Mat > &observations ) = 0;

  std::string createKey();

  // Remove unused trackers
  void clearFilters();
  
  // Generates a message with the estimation of each people#
  unsigned int getNumFilters();


 protected:


  virtual void createNewFilters( const std::vector< cv::Mat > &observations ) = 0; 

  std::map< std::string, cv::KalmanFilter > filters;

  float entropy_thresh;

  unsigned int filter_count;

  typedef std::map< std::string, cv::KalmanFilter >::iterator kf_list_ite;

  typedef std::vector< cv::Mat >::const_iterator mat_vect_ite;


};



#endif

/**
 * From Stephen McKeague
 */
#include <iostream>
#include <cmath>
#include <sstream>
#include <iomanip>

#include "kalman_filter.h"



KalmanFilter::KalmanFilter( const float entropy_thresh ) : entropy_thresh( entropy_thresh ), filter_count( 0 ) {}


std::string KalmanFilter::createKey()
{
  std::stringstream key_stream;
  key_stream << std::setw( 4 ) << std::setfill( '0' );

  key_stream << "filter_";
  key_stream << filter_count++;

  return key_stream.str();
}


void KalmanFilter::clearFilters()
{
  // Iterate over all filters
  for( kf_list_ite it = filters.begin(); it != filters.end(); )
    {
      // Calculate the entroy of the normal distribution
      //      const cv::Mat position_cov = it->second.errorCovPre( cv::Range( 0, 3 ), cv::Range( 0, 3 ) );
      
      const float entropy = 0.5 * std::log( std::pow( 2.0 * M_PI * M_E, 3 ) * cv::determinant( it->second.errorCovPre ) ); //det of position_cov
      
      std::cout << it->first << std::endl;
      //      std::cout << it->second.errorCovPre( cv::Range( 0, 3 ), cv::Range( 0, 3 ) ) << std::endl;
      //      std::cout << std::pow( 2.0 * M_PI * M_E, 3 ) * cv::determinant( positionCov ) << std::endl;
      std::cout << entropy << std::endl << std::endl;

      if( entropy > entropy_thresh )
        {
	  std::cout << "Filter with id: " << it->first << " has been deleted" << std::endl;
          filters.erase( it++ );
        }
      else 
	it++;
    
    }

}


unsigned int KalmanFilter::getNumFilters()
{

  return filters.size();
}

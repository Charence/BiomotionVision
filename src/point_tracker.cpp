/**
 * From Stephen McKeague
 */
#include <iostream>
#include <string>
#include <limits>

#include "point_tracker.h"



PointTracker::PointTracker( ) : KalmanFilter( 12.0f ), dynam_params( 4 ), measure_params( 2 ), error_cov_post( 4, 4, CV_32FC1 ), init_transition_mat( 4, 4, CV_32FC1 ), measurement_mat( 2, 4, CV_32FC1 ), init_process_noise_cov( 4, 4, CV_32FC1 ), measurement_noise_cov( 2, 2, CV_32FC1 ), dist_thresh( 3.0f )
{

  // Initial covariance for new trackers
  // For background model initial position noise (11, 22, 33) = 0.01, initial velocity noise (44, 55, 66) = 2.5f
  cv::setIdentity( error_cov_post, cv::Scalar( 0.05 ) );
  error_cov_post.at< float >( 2, 2 ) = 0.5f;
  error_cov_post.at< float >( 3, 3 ) = 0.5f;

  // Initial transition matrix
  init_transition_mat.at< float >( 0, 0 ) = 1.0f;
  init_transition_mat.at< float >( 0, 1 ) = 0.0f;
  init_transition_mat.at< float >( 0, 2 ) = 1.0f;
  init_transition_mat.at< float >( 0, 3 ) = 0.0f;

  init_transition_mat.at< float >( 1, 0 ) = 0.0f;
  init_transition_mat.at< float >( 1, 1 ) = 1.0f;
  init_transition_mat.at< float >( 1, 2 ) = 0.0f;
  init_transition_mat.at< float >( 1, 3 ) = 1.0f;

  init_transition_mat.at< float >( 2, 0 ) = 0.0f;
  init_transition_mat.at< float >( 2, 1 ) = 0.0f;
  init_transition_mat.at< float >( 2, 2 ) = 1.0f;
  init_transition_mat.at< float >( 2, 3 ) = 0.0f;

  init_transition_mat.at< float >( 3, 0 ) = 0.0f;
  init_transition_mat.at< float >( 3, 1 ) = 0.0f;
  init_transition_mat.at< float >( 3, 2 ) = 0.0f;
  init_transition_mat.at< float >( 3, 3 ) = 1.0f;

  cv::setIdentity( measurement_mat );

  //!!!: with a low process noise the trackers take ages following the person
  //this is because the system relies too much on the linear motion assumption which is obviously untrue
  // For background model, position process noise (11, 22, 33) = 1 and velocity process noise (44, 55, 66) = 5
  cv::setIdentity( init_process_noise_cov, cv::Scalar( 2.5 ) );
  init_process_noise_cov.at< float >( 2, 2 ) = 25.0f;
  init_process_noise_cov.at< float >( 3, 3 ) = 25.0f;

  //For background model, measurment noise = 0.01
  cv::setIdentity( measurement_noise_cov, cv::Scalar( 0.05 ) );

}


void PointTracker::setArguments( const float entropy_thresh, const float dist_thresh )
{
  
  this->entropy_thresh = entropy_thresh;
  this->dist_thresh = dist_thresh;

}


std::vector< cv::Mat > PointTracker::predict( const float dt )
{
  // Iterate over all filters
  for( kf_list_ite it = filters.begin(); it != filters.end(); it++ )
    {
      // Adapt init_transition matrix with the elapsed time
      it->second.transitionMatrix.at< float >( 0, 2 ) = dt;
      it->second.transitionMatrix.at< float >( 1, 4 ) = dt;

      it->second.processNoiseCov = calcProcessNoise( dt );
      
      // Update kalman filter
      it->second.predict();

      it->second.statePost = it->second.statePre;
      it->second.errorCovPost = it->second.errorCovPre;
    }

  clearFilters();

  return returnStates();
}


//!!!:  This should probably be taken out if we are using a constant motion assumption to model random motion.
//  We really should give velocity a big noise and forget about real world assumptions because the model is broken by design anyway 
cv::Mat PointTracker::calcProcessNoise( const float dt )
{
  cv::Mat noise_mul( 4, 1, CV_32FC1 );
  noise_mul.at< float >( 0 ) = dt * dt / 2;
  noise_mul.at< float >( 1 ) = dt * dt / 2;
  noise_mul.at< float >( 2 ) = dt;
  noise_mul.at< float >( 3 ) = dt;

  cv::Mat noise_cov( 4, 4, CV_32FC1 );
  noise_cov = noise_mul * noise_mul.t();

  //per element multiply our random acceleration model by the initial covariance
  noise_cov = noise_cov.mul( init_process_noise_cov );
  
  return noise_cov;
}

std::vector< cv::Mat > PointTracker::returnStates()
{
  std::vector< cv::Mat > states;
  states.resize( filters.size() );

  std::size_t idx = 0;
  for( kf_list_ite it = filters.begin(); it != filters.end(); it++ )
    {
      const cv::Mat &state = it->second.statePost;

      states.at( idx ) = state.rowRange(0, 1);
      idx++;
    }

  return states;
}


void PointTracker::update( const std::vector< cv::Mat > &observations )
{
  std::vector< cv::Mat > unassigned_observations;    //will hold observations for which no appropriate filter was found 
  std::map< std::string, cv::KalmanFilter > unassigned_filters;

  unassigned_filters.insert( filters.begin(), filters.end() );  //initially no filter has been assigned

  // Iterate over all observations updating the filter that lies closet to the observation
  for( mat_vect_ite it1 = observations.begin(); it1 != observations.end(); it1++ ) 
    {
      kf_list_ite closest_filter;
      float min_dist = std::numeric_limits< float >::infinity();
    
      for( kf_list_ite it2 = unassigned_filters.begin(); it2 != unassigned_filters.end(); it2++ )
	{
	  const cv::Mat filter_mean = it2->second.statePost.rowRange(0, 2);
	  const float dist = cv::norm( *it1, filter_mean );  //RMS between matrix observation values

	  if( dist < min_dist )
	    {
	      closest_filter = it2;
	      min_dist = dist;
	    }
	}

      // If found, correct the filter and remove it from the unassigned filter list
      if( min_dist < dist_thresh )
	{
	  closest_filter->second.correct( *it1 );

	  unassigned_filters.erase( closest_filter );
	}
      else
	// If not filter found near observation, put on the unassigned list for a filter to be created
	unassigned_observations.push_back( *it1 );
    }
  
  // Call the creation of new filters
  if( unassigned_observations.size() > 0 )
    createNewFilters( unassigned_observations );

}


// Create new filters from the corresponding observations
void PointTracker::createNewFilters( const std::vector< cv::Mat > &observations )
{
  // Create one kalman filter for each observation
  for(mat_vect_ite it1 = observations.begin(); it1 != observations.end(); it1++)
    {
      const std::string key = createKey();
      
      //create new kalman filter entry
      std::pair< std::string, cv::KalmanFilter > new_filter_entry( key, cv::KalmanFilter( dynam_params, measure_params ) );

      //set initial state
      new_filter_entry.second.statePost = cv::Mat::zeros( dynam_params, 1, CV_32FC1 );
      new_filter_entry.second.statePost.at< float >( 0 ) = it1->at< float >( 0 );
      new_filter_entry.second.statePost.at< float >( 1 ) = it1->at< float >( 1 );
      
      new_filter_entry.second.errorCovPost = error_cov_post;
      
      new_filter_entry.second.transitionMatrix = init_transition_mat;
      new_filter_entry.second.measurementMatrix = measurement_mat;
      new_filter_entry.second.processNoiseCov = init_process_noise_cov;
      new_filter_entry.second.measurementNoiseCov = measurement_noise_cov;

      filters.insert( new_filter_entry );
      
      std::cout << "New filter created with id " << key << std::endl;
    }

}

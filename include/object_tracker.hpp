#include <vector>

#include "object_info.hpp"

using namespace std;

class ObjectTracker {
	protected:
		// tracks
	public:
		ObjectTracker();
		void update(vector<ObjectInfo> detectedObjects);
		vector<ObjectInfo> predict();
};

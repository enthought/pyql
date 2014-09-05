#include <ql/time/date.hpp>

#ifdef WIN32
// using a custom settings.hpp that exposes the Setting class with dllimport
// This is required to make sure the Singleton is properly shared between the 
// Cython pyd's.
#include <settings.hpp>
#else
#include <ql/settings.hpp>
#endif


using namespace QuantLib;

namespace QuantLib {
    void set_evaluation_date(Date& evaluation_date) {
        Settings::instance().evaluationDate() = evaluation_date;
    }

    Date get_evaluation_date(){
        return Settings::instance().evaluationDate();
    }
}

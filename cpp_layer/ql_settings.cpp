#include <ql/time/date.hpp>

// FIXME: add a conditional include for Windows arch, otherwise use 
// ql/settings.hpp
#include <settings.hpp>

using namespace QuantLib;

namespace QuantLib {
    void set_evaluation_date(Date& evaluation_date) {
        Settings::instance().evaluationDate() = evaluation_date;
    }

    Date get_evaluation_date(){
        return Settings::instance().evaluationDate();
    }
}

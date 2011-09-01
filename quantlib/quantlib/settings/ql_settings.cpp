#include <ql/time/date.hpp>
#include <ql/settings.hpp>
using namespace QuantLib;

namespace QL {
    void set_evaluation_date(Date& evaluation_date) {
        Settings::instance().evaluationDate() = evaluation_date;
    }

    Date get_evaluation_date(){
        return Settings::instance().evaluationDate();
    }
}

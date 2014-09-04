/* Very simple interface to expose the Settings instance object to Cython.
 *
 * This prevents from creating one interface for each of the classes used in
 * the Settings instance (DateProxy, boost::optional<bool>, etc.)
 */

#include <ql/time/date.hpp>
#include <settings.hpp>

namespace QuantLib {
    QuantLib::Date get_evaluation_date();
    void set_evaluation_date(QuantLib::Date& evaluation_date);
}

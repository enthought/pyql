/*
 * Cython does not support the << operator.
 * 
 */

#include <iostream>
#include <sstream>
#include <ql/time/businessdayconvention.hpp>

using namespace QuantLib;

namespace QL {
    std::string repr(int b) {
      BusinessDayConvention bd = static_cast<BusinessDayConvention>(b);
      std::ostringstream s;
      s << bd;
      return s.str();
    }
}

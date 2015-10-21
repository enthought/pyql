#include <ql/math/array.hpp>

/*
 * setter for QuantLib Array
 *
 */ 

using namespace QuantLib;

namespace PyQL {

    void set_item(Array& a, int key, double value) {
    a[key] = value;
    }
}

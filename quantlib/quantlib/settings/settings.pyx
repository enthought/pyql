# distutils: language = c++
# distutils: libraries = QuantLib
from cython.operator cimport dereference as deref
from libcpp cimport bool as cbool

cimport quantlib.time._date as qldate
cimport quantlib.time.date as date

cdef extern from "quantlib/settings/ql_settings.hpp" namespace "QL":
    qldate.Date get_evaluation_date()
    void set_evaluation_date(qldate.Date& date)

cdef extern from 'ql/version.hpp':

    char* QL_VERSION
    int QL_HEX_VERSION
    char* QL_LIB_VERSION

__quantlib_version__ = QL_VERSION
__quantlib_lib_version__ = QL_LIB_VERSION
__quantlib_hex_version__ = QL_HEX_VERSION

cdef class Settings:

    def __init__(self):
        pass

    property evaluation_date:
        def __get__(self):
            cdef qldate.Date evaluation_date = get_evaluation_date()
            return date.date_from_qldate_ref(evaluation_date)

        def __set__(self, date.Date evaluation_date):
            cdef qldate.Date* date_ref = <qldate.Date*>evaluation_date._thisptr 
            set_evaluation_date(deref(date_ref)) 

    property version:
        def __get__(self):
            return QL_VERSION


# distutils: language = c++
# distutils: libraries = QuantLib
from cython.operator cimport dereference as deref

cimport quantlib.time._date as qldate
cimport quantlib.time.date as date

cdef extern from "quantlib/settings/ql_settings.hpp" namespace "QL":
    qldate.Date get_evaluation_date()
    void set_evaluation_date(qldate.Date& date)

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


from quantlib.handle cimport shared_ptr
from quantlib._observable cimport Observable
from quantlib.time._date cimport Date
from libcpp cimport bool
from .handle cimport optional

cdef extern from "ql/settings.hpp" namespace "QuantLib" nogil:
    cdef cppclass Settings:
        cppclass DateProxy:
            DateProxy()
            DateProxy& operator=(const Date&)
            DateProxy& assign_date "operator="(const Date&)
        DateProxy evaluationDate()
        shared_ptr[Observable] evaluationDate1 "evaluationDate" ()
        void anchorEvaluationDate()
        void resetEvaluationDate()
        bool& includeReferenceDateEvents()
        bool& enforcesTodaysHistoricFixings()
        optional[bool]& includeTodaysCashFlows()
        @staticmethod
        Settings& instance()

    cdef cppclass SavedSettings:
        pass

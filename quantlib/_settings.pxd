from quantlib.time._date cimport Date
from libcpp cimport bool
from handle cimport optional

cdef extern from "ql/settings.hpp" namespace "QuantLib":
    cdef cppclass Settings:
        cppclass DateProxy:
            DateProxy()
            DateProxy& operator=(const Date&)
            DateProxy& assign_date "operator="(const Date&)
        DateProxy evaluationDate()
        void anchorEvaluationDate()
        void resetEvaluationDate()
        bool& includeReferenceDateEvents()
        bool& enforcesTodaysHistoricFixings()
        optional[bool]& includeTodaysCashFlows()
        @staticmethod
        Settings& instance()

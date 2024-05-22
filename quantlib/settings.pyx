from cython.operator cimport dereference as deref
from libcpp cimport bool

from quantlib.handle cimport optional, shared_ptr, nullopt
from quantlib.time._date cimport Date as QlDate
from quantlib.time.date cimport Date, date_from_qldate
from quantlib.observable cimport Observable
from quantlib._observable cimport Observable as QlObservable

cimport quantlib._settings as _settings

cdef extern from 'ql/version.hpp':

    char* QL_VERSION
    int QL_HEX_VERSION

cdef extern from 'ql/config.hpp':
    bool QL_HIGH_RESOLUTION_DATE

cdef extern from 'settings.hpp':
    cdef void SET_VALUE(bool&, bool)
    cdef void SET_VALUE(optional[bool]&, optional[bool])

__quantlib_version__ = QL_VERSION
__quantlib_hex_version__ = QL_HEX_VERSION

cdef class DateProxy(Observable):
    cdef shared_ptr[QlObservable] as_observable(self):
        return _settings.Settings.instance().evaluationDate1()

cdef class Settings:

    cdef _settings.SavedSettings* backup

    property evaluation_date:
        """Property to set/get the evaluation date. """
        def __get__(self):
            return date_from_qldate(<QlDate>_settings.Settings.instance().evaluationDate())

        def __set__(self, Date evaluation_date not None):
            _settings.Settings.instance().evaluationDate().assign_date(evaluation_date._thisptr)

    @property
    def observable_evaluation_date(self):
        cdef DateProxy instance = DateProxy.__new__(DateProxy)
        return instance

    property version:
        """Returns the QuantLib C++ version (QL_VERSION) used by this wrapper."""
        def __get__(self):
            return QL_VERSION.decode('utf-8')

    def anchor_evaluation_date(self):
        _settings.Settings.instance().anchorEvaluationDate()

    def reset_evaluation_date(self):
        _settings.Settings.instance().resetEvaluationDate()

    @property
    def include_reference_date_events(self):
        return _settings.Settings.instance().includeReferenceDateEvents()

    @include_reference_date_events.setter
    def include_reference_date_events(self, bool val):
        SET_VALUE(_settings.Settings.instance().includeReferenceDateEvents(),
                  val)

    @property
    def enforces_todays_historic_fixings(self):
        return _settings.Settings.instance().enforcesTodaysHistoricFixings()

    @enforces_todays_historic_fixings.setter
    def enforces_todays_historic_fixings(self, bool val):
        SET_VALUE(_settings.Settings.instance().enforcesTodaysHistoricFixings(),
                  val)
    @property
    def include_todays_cashflows(self):
        cdef optional[bool] flag = _settings.Settings.instance().includeTodaysCashFlows()
        if not flag:
            return None
        else:
            return flag.value()

    @include_todays_cashflows.setter
    def include_todays_cashflows(self, val):
        cdef optional[bool] flag = nullopt
        if val is not None:
            flag = optional[bool](<bool>val)
        SET_VALUE(_settings.Settings.instance().includeTodaysCashFlows(),
                  flag)

    @classmethod
    def instance(cls):
        """ Returns an instance of the global Settings object.

        Utility method to mimic the behaviour of the C++ singleton.

        """

        return cls()

    def __enter__(self):
        self.backup = new _settings.SavedSettings()
        return self

    def __exit__(self, exception_type, exception_value, traceback):
        del self.backup

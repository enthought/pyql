""" Asian option on a single asset """
from quantlib.types cimport Real, Size
from libcpp.vector cimport vector

from quantlib.handle cimport shared_ptr, static_pointer_cast
cimport quantlib.time._date as _date
from quantlib.time.date cimport Date
from quantlib.instruments.payoffs cimport StrikedTypePayoff

from .option cimport OneAssetOption
from .exercise cimport Exercise
from . cimport _payoffs
from .._instrument cimport Instrument as _Instrument
from ._asian_options cimport (
    ContinuousAveragingAsianOption as _ContinuousAveragingAsianOption,
    DiscreteAveragingAsianOption as _DiscreteAveragingAsianOption,
)
cdef class ContinuousAveragingAsianOption(OneAssetOption):
    """Continuous-averaging Asian option

    Parameters
    ----------
    average_type: Enum (Arithmetic or Geometric)
    payoff : StrikedTypePayoff
    exercise : Exercise
    """
    def __init__(self,
                 AverageType average_type,
                 StrikedTypePayoff payoff not None,
                 Exercise exercise not None
                 ):

        self._thisptr = shared_ptr[_Instrument](
            new _ContinuousAveragingAsianOption(
                                        average_type,
                                        static_pointer_cast[_payoffs.StrikedTypePayoff](payoff._thisptr),
                                        exercise._thisptr)
        )



cdef class DiscreteAveragingAsianOption(OneAssetOption):
    """Discrete-averaging Asian option

    Parameters
    ----------
    average_type: Enum (Arithmetic or Geometric)
    payoff : StrikedTypePayoff
    exercise : Exercise
    fixing_dates : list of dates
    running_accum : float, optional
    past_fixings : float, optional
    all_past_fixings: list of float, optional
    """
    def __init__(self,
                 AverageType average_type,
                 StrikedTypePayoff payoff not None,
                 Exercise exercise not None,
                 list fixing_dates not None,
                 running_accum=None,
                 past_fixings=None,
                 all_past_fixings=None,
                 ):

        cdef vector[Real] _all_past_fixings
        # convert the list of PyQL dates into a vector of QL dates
        cdef vector[_date.Date] _fixing_dates
        for date in fixing_dates:
            _fixing_dates.push_back((<Date?>date)._thisptr)

        if (running_accum is not None) and (past_fixings is not None):
            self._thisptr = shared_ptr[_Instrument](
                new _DiscreteAveragingAsianOption(
                                         average_type,
                                         <Real>running_accum,
                                         <Size>past_fixings,
                                         _fixing_dates,
                                         static_pointer_cast[_payoffs.StrikedTypePayoff](payoff._thisptr),
                                         exercise._thisptr)
            )
        elif all_past_fixings is not None:
            for fixing in all_past_fixings:
                _all_past_fixings.push_back(<Real?>fixing)

            self._thisptr = shared_ptr[_Instrument](
                new _DiscreteAveragingAsianOption(
                                         average_type,
                                         _fixing_dates,
                                         static_pointer_cast[_payoffs.StrikedTypePayoff](payoff._thisptr),
                                         exercise._thisptr,
                                         all_past_fixings)
            )

        else:
            raise ValueError("running accum and past fixings or all_pf's must be non Null")

include '../../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, Handle, static_pointer_cast
from quantlib._defines cimport QL_NULL_REAL
cimport quantlib.quotes._simplequote as _sq
from . cimport _sensitivityanalysis as _sa
cimport quantlib._instrument as _it
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from quantlib.quotes.simplequote cimport SimpleQuote
from quantlib.instrument cimport Instrument

cpdef enum SensitivityAnalysis:
    OneSide
    Centered

def parallel_analysis(list quotes not None, list instruments not None,
                      vector[Real] quantities=[],
                      Real shift=0.0001, SensitivityAnalysis type=Centered,
                      Real reference_npv=QL_NULL_REAL):
    """
    Parallel shift PV01 sensitivity analysis for a SimpleQuote vector

    Returns a pair of first and second derivative values. Second derivative
    is not available if type is OneSide.

    Empty quantities vector is considered as unit vector. The same if the
    vector is just one single element equal to one.

    Parameters
    ----------
    quotes : list[SimpleQuote]
    instrument : list[Instrument]
    quantities : list[Real]
    shift : Real
    type : SensitivityAnalysis
    """
    cdef vector[Handle[_sq.SimpleQuote]] _quotes
    cdef vector[shared_ptr[_it.Instrument]] _instruments
    cdef shared_ptr[_sq.SimpleQuote] q_ptr
    cdef Instrument inst
    cdef SimpleQuote q

    for q in quotes:
        q_ptr = static_pointer_cast[_sq.SimpleQuote](q._thisptr)
        _quotes.push_back(Handle[_sq.SimpleQuote](q_ptr))

    for inst in instruments:
        _instruments.push_back(inst._thisptr)

    return _sa.parallelAnalysis(_quotes,
                                _instruments,
                                quantities,
                                shift,
                                <_sa.SensitivityAnalysis>(type),
                                reference_npv)


def bucket_analysis(list quotes not None, list instruments not None,
                    vector[Real] quantities=[], Real shift=0.0001,
                    SensitivityAnalysis type=Centered):

    """
    Parameters
    ----------
    1) quotes : list[SimpleQuote] or list[list[SimpleQuote]]
        list or list of list of quotes to be tweaked by a certain shift,
        usually passed from ratehelpers
    2) instruments : List of instruments
        list of instruments to be analyzed.
    3) quantity : Quantity of instrument
        A multiplier for the resulting buckets, Usually 1 or lower.
    4) shift : Amount of shift for analysis.
        Tends to be 0.0001 (1 bp). Can be larger as well as positive or negative.
    5) type : Sensitivity Analysis Type
        Will be either OneSide or Centered
    """

    #C++ Inputs
    cdef vector[vector[Handle[_sq.SimpleQuote]]] _Quotes
    cdef vector[shared_ptr[_it.Instrument]] _instruments

    #intermediary temps
    cdef vector[Handle[_sq.SimpleQuote]] _quotes
    cdef shared_ptr[_sq.SimpleQuote] q_ptr
    cdef Handle[_sq.SimpleQuote] quote_handle
    cdef list quotes_list
    cdef SimpleQuote q
    cdef Instrument inst

    for inst in instruments:
        _instruments.push_back(inst._thisptr)

    if isinstance(quotes[0], list):
        for quotes_list in quotes:
            _Quotes.push_back(vector[Handle[_sq.SimpleQuote]]())
            for q in quotes_list:
                q_ptr = static_pointer_cast[_sq.SimpleQuote](q._thisptr)
                _Quotes.back().push_back(Handle[_sq.SimpleQuote](q_ptr))
        return _sa.bucketAnalysis(_Quotes, _instruments, quantities, shift,
                                  <_sa.SensitivityAnalysis>(type))
    elif isinstance(quotes[0], SimpleQuote):
        for q in quotes:
            q_ptr = static_pointer_cast[_sq.SimpleQuote](q._thisptr)
            _quotes.push_back(Handle[_sq.SimpleQuote](q_ptr))
        return _sa.bucketAnalysis1(_quotes, _instruments, quantities, shift,
                                   <_sa.SensitivityAnalysis>(type))
    else:
        raise RuntimeError("quotes need to be either a list or list of lists of SimpleQuote")

include '../../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, Handle, static_pointer_cast
from quantlib.defines cimport QL_NULL_REAL
cimport quantlib._quote as _qt
cimport _sensitivityanalysis as _sa
cimport quantlib.instruments._instrument as _it
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from quantlib.quotes cimport SimpleQuote, Quote
from quantlib.instruments.instrument cimport Instrument

cpdef enum SensitivityAnalysis:
    OneSide
    Centered


def parallel_analysis(list quotes, list instruments, vector[Real] quantities=[],
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
    cdef vector[Handle[_qt.SimpleQuote]] _quotes
    cdef vector[shared_ptr[_it.Instrument]] _instruments
    cdef shared_ptr[_qt.SimpleQuote] q_ptr
    cdef Instrument inst
    cdef SimpleQuote q

    for q in quotes:
        q_ptr = static_pointer_cast[_qt.SimpleQuote](q._thisptr)
        _quotes.push_back(Handle[_qt.SimpleQuote](q_ptr))

    for inst in instruments:
        _instruments.push_back(inst._thisptr)

    return _sa.parallelAnalysis(_quotes,
                                _instruments,
                                quantities,
                                shift,
                                <_sa.SensitivityAnalysis>(type),
                                reference_npv)


def bucket_analysis(list quotes, list instruments,
                    vector[Real] quantities=[], Real shift=0.0001,
                    SensitivityAnalysis type=Centered):

    """
    Parameters
    ----------
    1) quotes : list[list[Quantlib::SimpleQuote]]
        list of list of quotes to be tweaked by a certain shift, usually passed from ratehelpers
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
    cdef vector[vector[Handle[_qt.SimpleQuote]]] vvh_quotes
    cdef vector[shared_ptr[_it.Instrument]] vsp_instruments

    #intermediary temps
    cdef vector[Handle[_qt.SimpleQuote]] sqh_vector
    cdef shared_ptr[_qt.SimpleQuote] q_ptr
    cdef Handle[_qt.SimpleQuote] sq_handle
    cdef list qlsq_out
    cdef SimpleQuote qlsq_in
    cdef Instrument inst

    #C++ Output
    cdef pair[vector[vector[Real]], vector[vector[Real]]] ps


    for inst in instruments:
        vsp_instruments.push_back(inst._thisptr)

    for qlsq_out in quotes:
        for qlsq_in in qlsq_out:

            #be sure to pass shared_ptr pointing to same SimpleQuotes as were created outside of bucketAnalysis
            q_ptr = static_pointer_cast[_qt.SimpleQuote](qlsq_in._thisptr)
            sq_handle = Handle[_qt.SimpleQuote](q_ptr)
            sqh_vector.push_back(sq_handle)

        vvh_quotes.push_back(sqh_vector)

    ps = _sa.bucketAnalysis(vvh_quotes,
                            vsp_instruments,
                            quantities,
                            shift,
                            type)

    return ps

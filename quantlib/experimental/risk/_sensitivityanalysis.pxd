include '../../types.pxi'

from quantlib.handle cimport shared_ptr, Handle
from quantlib.instruments._instrument cimport Instrument
from quantlib._quote cimport SimpleQuote, Quote
from libcpp.vector cimport vector
from libcpp.pair cimport pair


cdef extern from 'ql/experimental/risk/sensitivityanalysis.hpp' namespace 'QuantLib':
    cdef enum SensitivityAnalysis:
        OneSided
        Centered

cdef extern from 'ql/experimental/risk/sensitivityanalysis.hpp' namespace 'QuantLib':
    pair[vector[vector[Real]], vector[vector[Real]]] bucketAnalysis(
        vector[vector[Handle[SimpleQuote]]]& quotes,
        vector[shared_ptr[Instrument]]& instr,
        vector[Real]& quant,
        Real shift,
        SensitivityAnalysis type) except +
    # rename the function otherwise cython can't distinguish between the two
    pair[vector[Real], vector[Real]] bucketAnalysis1 "bucketAnalysis"(
        vector[Handle[SimpleQuote]]& quotes,
	vector[shared_ptr[Instrument]]& instr,
	vector[Real]& quant,
	Real shift,
	SensitivityAnalysis type) except +

    pair[Real, Real] parallelAnalysis(
        const vector[Handle[SimpleQuote]]&,
        const vector[shared_ptr[Instrument]]&,
        vector[Real]& quantities,
        Real shift, # =0.0001,
        SensitivityAnalysis type, #= Centered,
        Real reference_npv)# = Null<Real>()

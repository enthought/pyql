include '../../types.pxi'

from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr, Handle

cimport quantlib._quote as _qt
cimport quantlib.instruments._bonds as _bd
cimport _sensitivityanalysis as _sa
cimport quantlib.instruments._instrument as _it
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from quantlib.quotes cimport SimpleQuote, Quote
from quantlib.instruments.instrument cimport Instrument
cimport quantlib.instruments.bonds as _bo


cdef public enum SensitivityAnalysis:
    OneSide
    Centered
 

def bucketAnalysis(quotes_vvsq, instruments,
                    quantity, shift, type):

    """ 
		Inputs: 
		1. list(list[Quantlib::SimpleQuote))
		2. List[Quantlib::Instrument]
		3. List[decimal]
		4. decimal
		5. Quantlib::SensitivityAnalysis
		
    """
    #C++ Inputs
    #final inputs
    cdef vector[vector[Handle[_qt.SimpleQuote]]]* vvh_quotes = new vector[vector[Handle[_qt.SimpleQuote]]]()
    cdef vector[shared_ptr[_it.Instrument]]* vsp_instruments = new vector[shared_ptr[_it.Instrument]]()
    cdef vector[Real]* rates = new vector[Real]()
   
    #intermediary temps
    cdef vector[Handle[_qt.SimpleQuote]] sqh_vector
    cdef shared_ptr[_qt.SimpleQuote]* q_ptr
    cdef Handle[_qt.SimpleQuote]* sq_handle
    cdef shared_ptr[_it.Instrument] instrument_sp
	
    #C++ Output
    cdef pair[vector[vector[Real]],vector[vector[Real]]] ps
	
	
    for rate in quantity:
        rates.push_back(rate)
	
    for qlinstrument in instruments:
        instrument_sp = deref((<Instrument>qlinstrument)._thisptr)
        vsp_instruments.push_back(instrument_sp)

    for qlsq_out in quotes_vvsq:
        for qlsq_in in qlsq_out:

            #be sure to pass shared_ptr pointing to same SimpleQuotes as were created outside of bucketAnalysis
            q_ptr = <shared_ptr[_qt.SimpleQuote]*>(<SimpleQuote>qlsq_in)._thisptr
            sq_handle = new Handle[_qt.SimpleQuote](deref(q_ptr))
            sqh_vector.push_back(deref(sq_handle))
			
        vvh_quotes.push_back(sqh_vector)
   	
    #TODO: Will pair<vector<vector<Real>>,vector<vector<Real>>> be implicitly converted to python equivalent? 
    ps = _sa.bucketAnalysis(deref(vvh_quotes),
                            deref(vsp_instruments),
			    deref(rates),
                            shift,
                            type)
    
    return ps


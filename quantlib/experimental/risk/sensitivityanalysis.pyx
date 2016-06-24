include '../../types.pxi'

from cython.operator cimport dereference as deref
from quantlib.handle cimport shared_ptr, Handle

cimport quantlib._quote as _qt
cimport _sensitivityanalysis as _sa
cimport quantlib.instruments._instrument as _it
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from quantlib.quotes cimport SimpleQuote, Quote
from quantlib.instruments.instrument cimport Instrument

cdef public enum SensitivityAnalysis:
    OneSide
    Centered
 
def bucket_analysis(quotes_vvsq, instruments,
                    vector[Real] quantity, shift, sa_type):

    """ Parameters :
    ----------
    1) quotes_vvsq : list[list[Quantlib::SimpleQuote]]
        list of list of quotes to be tweaked by a certain shift, usually passed from ratehelpers
    2) instruments : List of instruments
        list of instruments to be analyzed.Bond and option in unit test. 
    3) quantity : Quantity of instrument   
        A multiplier for the resulting buckets, Usually 1 or lower.  
    4) shift : Amount of shift for analysis. 
        Tends to be 0.0001 (1 bp). Can be larger as well as positive or negative. 
    5) sa_type : Sensitivity Analysis Type
        Will be either OneSided or Centered 
    """

    #C++ Inputs
    cdef vector[vector[Handle[_qt.SimpleQuote]]] vvh_quotes
    cdef vector[shared_ptr[_it.Instrument]] vsp_instruments
   
    #intermediary temps
    cdef vector[Handle[_qt.SimpleQuote]] sqh_vector
    cdef shared_ptr[_qt.SimpleQuote]* q_ptr
    cdef Handle[_qt.SimpleQuote]* sq_handle
    cdef shared_ptr[_it.Instrument] instrument_sp
	
    #C++ Output
    cdef pair[vector[vector[Real]],vector[vector[Real]]] ps
	
	
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

    ps = _sa.bucketAnalysis(vvh_quotes,
                            vsp_instruments,
                            quantity,
                            shift,
                            sa_type)
    
    return ps


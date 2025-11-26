cimport quantlib.termstructures.yields._forward_spreaded_term_structure as _fsts

from quantlib.handle cimport HandleYieldTermStructure
from ..yield_term_structure cimport YieldTermStructure
from quantlib.quote cimport Quote

cdef class ForwardSpreadedTermStructure(YieldTermStructure):
    """Term structure with an added spread on the instantaneous forward rate.

    This term structure remains linked to the original structure; any changes
    in the latter will be reflected in this structure.

    Parameters
    ----------
    yts : :class:`~quantlib.termstructures.yield_term_structure.HandleYieldTermStructure`
        The handle to the original yield term structure.
    spread : :class:`~quantlib.quote.Quote`
        The spread to be added to the forward rate.
    """
    def __init__(self, HandleYieldTermStructure yts not None, Quote spread not None):

        self._thisptr.reset(
            new _fsts.ForwardSpreadedTermStructure(
                yts.handle(),
                spread.handle()
            )
        )

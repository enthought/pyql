cimport quantlib.termstructures.yields._implied_term_structure as _its
from quantlib.handle cimport HandleYieldTermStructure
from quantlib.time.date cimport Date

cdef class ImpliedTermStructure(YieldTermStructure):
    """Implied term structure at a given date in the future.

    The given date will be the implied reference date.

    This term structure will remain linked to the original structure; any
    changes in the latter will be reflected in this structure as well.

    Parameters
    ----------
    h : :class:`~quantlib.termstructures.yield_term_structure.HandleYieldTermStructure`
        The handle to the original yield term structure.
    reference_date : :class:`~quantlib.time.date.Date`
        The new reference date for the implied curve.
    """
    def __init__(self, HandleYieldTermStructure h not None,
                 Date reference_date not None):

        self._thisptr.reset(
            new _its.ImpliedTermStructure(h.handle(), reference_date._thisptr)
        )

from quantlib.pricingengines.engine cimport PricingEngine
from . cimport _fdblackscholesvanillaengine as _fdbs

cdef class FdBlackScholesVanillaEngine(PricingEngine):
    pass

cpdef enum CashDividendModel:
    Spot = _fdbs.Spot
    Escrowed = _fdbs.Escrowed

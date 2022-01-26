from . cimport _swaption
from ._swaption cimport Settlement
from .option cimport Option

cpdef enum SettlementType:
    Physical = _swaption.Physical
    Cash = _swaption.Cash

cpdef enum SettlementMethod:
    PhysicalOTC = _swaption.PhysicalOTC
    CollateralizedCashPrice = _swaption.CollateralizedCashPrice
    ParYieldCurve = _swaption.ParYieldCurve

cdef class Swaption(Option):
    pass

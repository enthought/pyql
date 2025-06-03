from quantlib.quote cimport Quote
from quantlib.handle cimport HandleSwaptionVolatilityStructure

cdef class SpreadedSwaptionVolatility(SwaptionVolatilityStructure):
    def __init__(self, HandleSwaptionVolatilityStructure vs not None,
                 Quote spread not None):

        self._thisptr.reset(
            new _ssv.SpreadedSwaptionVolatility(
                vs.handle(), spread.handle()
            )
        )

from cython.operator cimport dereference as deref
from quantlib._defines cimport QL_NULL_REAL
from quantlib.instruments.swap cimport Swap
from quantlib.handle cimport static_pointer_cast, shared_ptr
from quantlib.indexes.swap_index cimport SwapIndex
from quantlib.time.date cimport Period, Date
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.time._period cimport Days
cimport quantlib.indexes._swap_index as _si
cimport quantlib.instruments._instrument as _in
from quantlib.pricingengines.engine cimport PricingEngine
from quantlib.instruments._swaption cimport Swaption as _Swaption, Settlement
from quantlib.instruments.swaption cimport Swaption
from quantlib.instruments._vanillaswap cimport VanillaSwap
from quantlib.instruments.swap cimport SwapType

cdef class MakeSwaption:
    def __init__(self, SwapIndex swap_index,
                 option_tenor,
                 Rate strike=QL_NULL_REAL):
        if isinstance(option_tenor, Date):
            self._thisptr = new _make_swaption.MakeSwaption(
                static_pointer_cast[_si.SwapIndex](swap_index._thisptr),
                deref((<Date>option_tenor)._thisptr),
                strike)
        elif isinstance(option_tenor, Period):
            self._thisptr = new _make_swaption.MakeSwaption(
                static_pointer_cast[_si.SwapIndex](swap_index._thisptr),
                deref((<Period>option_tenor)._thisptr),
                strike)
        else:
            raise TypeError("'option_tenor' type needs to be either Date or Period")

    def __dealloc__(self):
        if self._thisptr is not NULL:
            del self._thisptr
            self._thisptr = NULL

    def __call__(self):
        cdef Swaption instance = Swaption.__new__(Swaption)
        cdef shared_ptr[_Swaption] temp = _make_swaption.get(deref(self._thisptr))
        instance._thisptr = static_pointer_cast[_in.Instrument](temp)
        return instance

    def with_settlement_type(self, Settlement.Type delivery):
        self._thisptr.withSettlementType(delivery)
        return self

    def with_settlement_method(self, Settlement.Method method):
        self._thisptr.withSettlementMethod(method)
        return self

    def with_option_convention(self, BusinessDayConvention bdc):
        self._thisptr.withOptionConvention(bdc)
        return self

    def with_exercise_date(self, Date exercise_date not None):
        self._thisptr.withExerciseDate(deref(exercise_date._thisptr))
        return self

    def with_underlying_type(self, SwapType swap_type):
        self._thisptr.withUnderlyingType(<VanillaSwap.Type>swap_type)
        return self

    def with_nominal(self, Real nominal):
        self._thisptr.withNominal(nominal)
        return self

    def with_pricing_engine(self, PricingEngine engine not None):
        self._thisptr.withPricingEngine(engine._thisptr)
        return self

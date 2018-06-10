include '../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time._businessdayconvention cimport BusinessDayConvention
from quantlib.indexes._swap_index cimport SwapIndex
from quantlib.instruments._swaption cimport Swaption, Settlement
from quantlib.instruments._vanillaswap cimport VanillaSwap
from quantlib.pricingengines._pricing_engine cimport PricingEngine

cdef extern from 'ql/instruments/makeswaption.hpp' namespace 'QuantLib':
    cdef cppclass MakeSwaption:
        MakeSwaption(const shared_ptr[SwapIndex]& swapIndex,
                     const Period& optionTenor,
                     Rate strike)# = Null<Rate>())

        MakeSwaption(const shared_ptr[SwapIndex]& swapIndex,
                     const Date& fixingDate,
                     Rate strike)# = Null<Rate>())

        Swaption operator()
        shared_ptr[Swaption] operator()

        MakeSwaption& withSettlementType(Settlement.Type delivery)
        MakeSwaption& withOptionConvention(BusinessDayConvention bdc)
        MakeSwaption& withExerciseDate(const Date&)
        MakeSwaption& withUnderlyingType(const VanillaSwap.Type type)
        MakeSwaption& withNominal(Real n)

        MakeSwaption& withPricingEngine(
            const shared_ptr[PricingEngine]& engine)

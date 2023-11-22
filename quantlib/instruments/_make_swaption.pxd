include '../types.pxi'

from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._period cimport Period
from quantlib.time.businessdayconvention cimport BusinessDayConvention
from quantlib.indexes._swap_index cimport SwapIndex
from quantlib.instruments._swaption cimport Swaption, Type, Method
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

        MakeSwaption& withSettlementType(Type delivery)
        MakeSwaption& withSettlementMethod(Method method)
        MakeSwaption& withOptionConvention(BusinessDayConvention bdc)
        MakeSwaption& withExerciseDate(const Date&)
        MakeSwaption& withUnderlyingType(const VanillaSwap.Type type)
        MakeSwaption& withNominal(Real n)

        MakeSwaption& withPricingEngine(
            const shared_ptr[PricingEngine]& engine)

    shared_ptr[Swaption] get "(QuantLib::ext::shared_ptr<QuantLib::Swaption>)" (MakeSwaption) except +

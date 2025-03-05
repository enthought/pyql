from libcpp cimport bool
from quantlib.types cimport Real, Spread
from quantlib.time._schedule cimport Schedule
from ._bond cimport Bond
from quantlib.handle cimport shared_ptr
from quantlib.time._date cimport Date
from quantlib.time._daycounter cimport DayCounter
from .._cashflow cimport Leg
from ._swap cimport Swap
from quantlib.indexes._ibor_index cimport IborIndex

cdef extern from "ql/instruments/assetswap.hpp" namespace "QuantLib" nogil:
    cdef cppclass AssetSwap(Swap):
       AssetSwap(bool payBondCoupon,
                 shared_ptr[Bond] bond,
                 Real bondCleanPrice,
                 const shared_ptr[IborIndex]& iborIndex,
                 Spread spread,
                 Schedule floatSchedule,
                 const DayCounter& floatingDayCounter,
                 bool parAssetSwap, # = true
                 Real gearing, # 1.0
                 Real nonParRepayment, # = Null<Real>(),
                 Date dealMaturity) # = Date()
       Spread fairSpread() except +
       Real floatingLegBPS() except +
       Real floatingLegNPV() except +
       Real fairCleanPrice() except +
       Real fairNonParRepayment() except +

       bool parSwap()
       Spread spread()
       Real cleanPrice()
       Real nonParRepayment()
       const shared_ptr[Bond]& bond()
       bool payBondCoupon()
       const Leg& bondLeg()
       const Leg& floatingLeg()

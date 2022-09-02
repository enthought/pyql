from quantlib.cashflows.ibor_coupon cimport IborLeg
from quantlib.time.schedule cimport Schedule
from quantlib.time.daycounter cimport DayCounter
from quantlib.time._daycounter cimport DayCounter as QlDayCounter
from quantlib.cashflows.fixed_rate_coupon cimport FixedRateLeg

cdef class FixedVsFloatingSwap(Swap):


    cdef inline _fixedvsfloatingswap.FixedVsFloatingSwap* get_ptr(self):
        return  <_fixedvsfloatingswap.FixedVsFloatingSwap*>self._thisptr.get()

    @property
    def fair_rate(self):
        return self.get_ptr().fairRate()

    @property
    def fair_spread(self):
        return self.get_ptr().fairSpread()

    @property
    def nominal(self):
        return self.get_ptr().nominal()

    @property
    def nominals(self):
        return self.get_ptr().nominals()

    @property
    def type(self):
        return self.get_ptr().type()

    @property
    def fixed_rate(self):
        return self.get_ptr().fixedRate()

    @property
    def fixed_schedule(self):
        cdef Schedule sched = Schedule.__new__(Schedule)
        sched._thisptr = self.get_ptr().fixedSchedule()
        return sched

    @property
    def fixed_day_count(self):
        cdef DayCounter dc = DayCounter.__new__(DayCounter)
        dc._thisptr = new QlDayCounter(self.get_ptr().fixedDayCount())
        return dc

    @property
    def floating_schedule(self):
        cdef Schedule sched = Schedule.__new__(Schedule)
        sched._thisptr = self.get_ptr().floatingSchedule()
        return sched

    @property
    def spread(self):
        return self.get_ptr().spread()

    @property
    def floating_day_count(self):
        cdef DayCounter dc = DayCounter.__new__(DayCounter)
        dc._thisptr = new QlDayCounter(self.get_ptr().floatingDayCount())
        return dc

    @property
    def fixed_leg(self):
        cdef FixedRateLeg leg = FixedRateLeg.__new__(FixedRateLeg)
        leg._thisptr = self.get_ptr().fixedLeg()
        return leg

    @property
    def fixed_leg_NPV(self):
        return self.get_ptr().fixedLegNPV()

    @property
    def fixed_leg_BPS(self):
        return self.get_ptr().fixedLegBPS()

    @property
    def floating_leg(self):
        cdef IborLeg leg = IborLeg.__new__(IborLeg)
        leg._thisptr = self.get_ptr().floatingLeg()
        return leg

    @property
    def floating_leg_NPV(self):
        return self.get_ptr().floatingLegNPV()


    @property
    def floating_leg_BPS(self):
        return self.get_ptr().floatingLegBPS()

import unittest
from quantlib.cashflows.ibor_coupon import IborCoupon
from quantlib.instruments.api import VanillaSwap, Swaption
from quantlib.instruments.swap import SwapType
from quantlib.time.api import (
    Date, today, Unadjusted, ModifiedFollowing, Annual, Semiannual,
    Thirty360, Days, Years, DateGeneration, Schedule, Actual365Fixed, Period)
from quantlib.time.daycounters.thirty360 import Convention
from quantlib.indexes.api import Euribor6M
from quantlib.termstructures.yields.api import YieldTermStructure
from quantlib.models.api import HullWhite
from quantlib.settings import Settings
from quantlib.pricingengines.api import DiscountingSwapEngine, TreeSwaptionEngine
from quantlib.instruments.exercise import BermudanExercise
from .utilities import flat_rate


class BermudanSwaptionTest(unittest.TestCase):
    def setUp(self):
        self.start_years = 1
        self.length = 5
        self.swap_type = SwapType.Payer
        self.nominal = 1000
        self.settlement_days = 2
        self.fixed_convention = Unadjusted
        self.floating_convention = ModifiedFollowing
        self.fixed_frequency = Annual
        self.floating_frequency = Semiannual
        self.fixed_day_count = Thirty360(Convention.BondBasis)
        self.term_structure = YieldTermStructure()
        self.index = Euribor6M(self.term_structure)
        self.calendar = self.index.fixing_calendar
        self.today = self.calendar.adjust(today())
        self.settlement = self.calendar.advance(self.today, self.settlement_days, Days)

    def make_swap(self, fixed_rate):
        start = self.calendar.advance(self.settlement, self.start_years, Years)
        maturity = self.calendar.advance(start, self.length, Years)
        fixed_schedule = Schedule.from_rule(start, maturity, Period(self.fixed_frequency), self.calendar,
                                            self.fixed_convention, self.fixed_convention, DateGeneration.Forward, False)
        float_schedule = Schedule.from_rule(start, maturity, Period(self.floating_frequency), self.calendar,
                                            self.floating_convention, self.floating_convention, DateGeneration.Forward, False)
        swap = VanillaSwap(self.swap_type, self.nominal, fixed_schedule, fixed_rate, self.fixed_day_count, float_schedule, self.index, 0.0, self.index.day_counter)
        swap.set_pricing_engine(DiscountingSwapEngine(self.term_structure))
        return swap

    def test_cached_values(self):
        """ Testing Bermudan swaption with HW model against cached values"""

        self.today = Date(15, 2, 2002)
        Settings().evaluation_date = self.today
        self.settlement = Date(19, 2, 2002)
        self.term_structure.link_to(flat_rate(0.04875825, Actual365Fixed(), self.settlement))
        atm_rate = self.make_swap(0.0).fair_rate
        itm_swap = self.make_swap(0.8 * atm_rate)
        atm_swap = self.make_swap(atm_rate)
        otm_swap = self.make_swap(1.2 * atm_rate)
        a = 0.048696
        sigma = 0.0058904
        model = HullWhite(self.term_structure, a, sigma)
        exercise_dates = []
        leg = atm_swap.fixed_leg
        for coupon in leg:
            exercise_dates.append(coupon.accrual_start_date)
        exercise = BermudanExercise(exercise_dates)
        tree_engine = TreeSwaptionEngine(model, 50)
        #fdm_engine = FdHullWhiteSwaptionEngine(model)
        if not IborCoupon.Settings.using_at_par_coupons():
            vals = (42.2402, 12.9032, 2.49758)
            vals_fdm = (42.2111, 12.8879, 2.44443)
        else:
            vals = (42.2460, 12.9069, 2.4985)
            vals_fdm = (42.2091, 12.8864, 2.4437)

        for ref_val, swap in zip(vals, (itm_swap, atm_swap, otm_swap)):
            swaption = Swaption(swap, exercise)
            swaption.set_pricing_engine(tree_engine)
            self.assertAlmostEqual(swaption.npv, ref_val, 3)

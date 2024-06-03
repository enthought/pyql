import unittest

from quantlib.indexes.swap.usd_libor_swap import UsdLiborSwapIsdaFixAm
from quantlib.instruments.make_swaption import MakeSwaption
from quantlib.pricingengines.api import BlackSwaptionEngine
from quantlib.instruments.swap import Swap
from quantlib.instruments.swaption import Settlement
from quantlib.pricingengines.api import BlackSwaptionEngine
from quantlib.termstructures.yields.api import FlatForward, HandleYieldTermStructure
from quantlib.time.api import (ModifiedFollowing, Period, Years,
                               Actual365Fixed, UnitedStates, Date)
from quantlib.settings import Settings

class TestQuantLibSwaption(unittest.TestCase):

    def setUp(self):
        Settings().evaluation_date = Date(27, 4, 2018)
        self.yc = HandleYieldTermStructure(FlatForward(forward=0.03, settlement_days=2,
                              daycounter=Actual365Fixed(),
                              calendar=UnitedStates()))
        self.index = UsdLiborSwapIsdaFixAm(Period(10, Years), self.yc)
        self.factory = (MakeSwaption(self.index, Period(2, Years), strike=0.0206).
                        with_underlying_type(Swap.Receiver).
                        with_settlement_type(Settlement.Cash).
                        with_settlement_method(Settlement.ParYieldCurve))

    def test_make_swaption(self):
        swaption = self.factory()
        self.assertEqual(swaption.settlement_type, Settlement.Cash)
        self.assertEqual(swaption.settlement_method, Settlement.ParYieldCurve)
        swap = swaption.underlying_swap()
        self.assertEqual(swap.type, Swap.Receiver)
        self.assertEqual(swaption.type, Swap.Receiver)
        exercise_date = self.index.fixing_calendar.advance(
            Settings().evaluation_date,
            period=Period(2, Years),
            convention=ModifiedFollowing)
        self.assertEqual(swap.start_date, self.index.value_date(exercise_date))
        self.assertEqual(exercise_date, swaption.exercise.last_date)

    def test_pricing_engine(self):
        swaption = self.factory()
        pe = BlackSwaptionEngine(self.yc, 0.3)
        swaption.set_pricing_engine(pe)
        self.assertAlmostEqual(swaption.npv, 0.008420333)
        self.assertAlmostEqual(swaption.atm_forward, 0.030234093)
        self.assertAlmostEqual(swaption.vega, 0.0739748)
        self.assertAlmostEqual(swaption.annuity, 8.0781391)

if __name__ == '__main__':
    unittest.main()

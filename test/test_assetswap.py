import unittest

from quantlib.time.api import Date, Period, Annual, TARGET, Unadjusted, Schedule, DateGeneration, Actual365Fixed, Semiannual, ActualActual, Following
from quantlib.instruments.api import FixedRateBond, AssetSwap
from quantlib.pricingengines.api import DiscountingBondEngine, DiscountingSwapEngine
from quantlib.termstructures.yields.api import HandleYieldTermStructure
from quantlib.indexes.api import Euribor
from .utilities import flat_rate

class TestMarketASWSpread(unittest.TestCase):
    def setUp(self):
        self.term_structure = HandleYieldTermStructure()
        self.today = Date(24, 4, 2007)
        self.ibor_index = Euribor(Period(Semiannual), self.term_structure)
        self.term_structure.link_to(flat_rate(0.05, Actual365Fixed(), self.today))
        self.spread = 0.0
        self.face_amount = 100.0
        self.settlement_days = 2

    def test_market_vs_par_asset_swap(self):
        """Testing relationship between market asset swap and par asset swap..."""

        pay_fixed_rate = True
        par_asset_swap = True
        mkt_asset_swap = False
        fixed_bond_schedule1 = Schedule.from_rule(Date(4, 1, 2005),
                                                  Date(4, 1, 2037),
                                                  Period(Annual),
                                                  TARGET(),
                                                  Unadjusted, Unadjusted,
                                                  DateGeneration.Backward, False)
        fixed_bond1 = FixedRateBond(self.settlement_days, self.face_amount, fixed_bond_schedule1,
                                    [0.04], ActualActual(ActualActual.ISDA), Following,
                                    100.0, Date(4, 1, 2005))
        bond_engine = DiscountingBondEngine(self.term_structure)
        swap_engine = DiscountingSwapEngine(self.term_structure)
        fixed_bond1.set_pricing_engine(bond_engine)
        fixed_bond_mkt_price1 = 89.22 # market price observed on June 7th 2007
        fixed_bond_mkt_full_price1 = fixed_bond_mkt_price1 + fixed_bond1.accrued_amount()
        fixed_bond_par_asset_swap1 = AssetSwap(pay_fixed_rate,
                                               fixed_bond1, fixed_bond_mkt_price1,
                                               self.ibor_index,
                                               self.spread,
                                               floating_day_counter=self.ibor_index.day_counter,
                                               par_asset_swap=True)
        fixed_bond_par_asset_swap1.set_pricing_engine(swap_engine)
        fixed_bond_par_asset_swap_spread1 = fixed_bond_par_asset_swap1.fair_spread
        fixed_bond_mkt_asset_swap1 = AssetSwap(pay_fixed_rate,
                                               fixed_bond1,
                                               fixed_bond_mkt_price1,
                                               self.ibor_index,
                                               self.spread,
                                               floating_day_counter=self.ibor_index.day_counter,
                                               par_asset_swap=False)
        fixed_bond_mkt_asset_swap1.set_pricing_engine(swap_engine)
        fixed_bond_mkt_asset_swap_spread1 = fixed_bond_mkt_asset_swap1.fair_spread

        self.assertAlmostEqual(fixed_bond_mkt_asset_swap_spread1,
                               100 * fixed_bond_par_asset_swap_spread1 / fixed_bond_mkt_full_price1)

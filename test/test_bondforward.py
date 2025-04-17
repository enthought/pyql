import unittest
from quantlib.settings import Settings
from quantlib.time.api import ActualActual, Annual, Date, DateGeneration, Period, Schedule, Following, TARGET, Actual365Fixed
from quantlib.instruments.api import BondForward, FixedRateBond
from quantlib.termstructures.yield_term_structure import HandleYieldTermStructure
from quantlib.pricingengines.api import DiscountingBondEngine
from quantlib.position import Position
from .utilities import flat_rate

def build_bond(issue, maturity, cpn):
    sch = Schedule.from_rule(issue, maturity, Period(Annual), TARGET(), Following, Following, DateGeneration.Backward, False)
    return FixedRateBond(2, 100_000, sch, [cpn], ActualActual(ActualActual.ISDA))

def build_bond_forward(underlying, handle: HandleYieldTermStructure, deliver: Date, pos_type: Position):
    value_date = handle.current_link.reference_date
    return BondForward(value_date, deliver, pos_type, 0.0, 2, ActualActual(ActualActual.ISDA),
                       TARGET(), Following, underlying, handle, handle)


class TestBondForward(unittest.TestCase):

    def setUp(self):
        today = Date(7, 3, 2022)
        Settings().evaluation_date = today
        self.curve_handle = HandleYieldTermStructure(flat_rate(0.0004977, Actual365Fixed(), reference_date=today))

    def test_futures_replication(self):
        """Testing futures prices replication"""

        issue = Date(15, 8, 2015)
        maturity = Date(15, 8, 2046)
        cpn = 0.025

        bnd = build_bond(issue, maturity, cpn)
        pricer = DiscountingBondEngine(self.curve_handle)
        bnd.set_pricing_engine(pricer)

        delivery = Date(10, 3, 2022)
        conversion_factor = 0.76871
        bnd_fwd = build_bond_forward(bnd, self.curve_handle, delivery, Position.Long)

        futures_price = bnd_fwd.clean_forward_price / conversion_factor
        expected_futures_price = 207.47
        self.assertAlmostEqual(futures_price, expected_futures_price, 2)

    def test_clean_forward_price_replication(self):
        """Testing clean forward price replication"""

        issue = Date(15, 8, 2015)
        maturity = Date(15, 8, 2046)
        cpn = 0.025

        bnd = build_bond(issue, maturity, cpn)
        pricer = DiscountingBondEngine(self.curve_handle)
        bnd.set_pricing_engine(pricer)

        delivery = Date(10, 3, 2022)
        bnd_fwd = build_bond_forward(bnd, self.curve_handle, delivery, Position.Long)

        fwd_clean_price = bnd_fwd.clean_forward_price
        expected_fwd_clean_price = bnd_fwd.forward_value - bnd.accrued_amount(delivery)

        self.assertAlmostEqual(fwd_clean_price, expected_fwd_clean_price)

from itertools import product
from quantlib.cashflows.rateaveraging import RateAveraging
from quantlib.indexes.api import Eonia
from quantlib.instruments.api import MakeOIS
from quantlib.settings import Settings
from quantlib.time.api import Date, Days, Weeks, Months, Years, Following, Actual360
from quantlib.termstructures.yields.api import HandleYieldTermStructure

from .utilities import flat_rate
import math
import unittest

deposit_data = [
    (0, 1, Days, 1.1),
    (2, 1, Weeks, 1.4),
    ( 2, 2, Weeks, 1.50 ),
    ( 2, 1, Months, 1.70 ),
    ( 2, 2, Months, 1.90 ),
    ( 2, 3, Months, 2.05 ),
    ( 2, 4, Months, 2.08 ),
    ( 2, 5, Months, 2.11 ),
    ( 2, 6, Months, 2.13 )]

eonia_swap_data = [
        ( 2,  1, Weeks, 1.245 ),
        ( 2,  2, Weeks, 1.269 ),
        ( 2,  3, Weeks, 1.277 ),
        ( 2,  1, Months, 1.281 ),
        ( 2,  2, Months, 1.18 ),
        ( 2,  3, Months, 1.143 ),
        ( 2,  4, Months, 1.125 ),
        ( 2,  5, Months, 1.116 ),
        ( 2,  6, Months, 1.111 ),
        ( 2,  7, Months, 1.109 ),
        ( 2,  8, Months, 1.111 ),
        ( 2,  9, Months, 1.117 ),
        ( 2, 10, Months, 1.129 ),
        ( 2, 11, Months, 1.141 ),
        ( 2, 12, Months, 1.153 ),
        ( 2, 15, Months, 1.218 ),
        ( 2, 18, Months, 1.308 ),
        ( 2, 21, Months, 1.407 ),
        ( 2,  2,  Years, 1.510 ),
        ( 2,  3,  Years, 1.916 ),
        ( 2,  4,  Years, 2.254 ),
        ( 2,  5,  Years, 2.523 ),
        ( 2,  6,  Years, 2.746 ),
        ( 2,  7,  Years, 2.934 ),
        ( 2,  8,  Years, 3.092 ),
        ( 2,  9,  Years, 3.231 ),
        ( 2, 10,  Years, 3.380 ),
        ( 2, 11,  Years, 3.457 ),
        ( 2, 12,  Years, 3.544 ),
        ( 2, 15,  Years, 3.702 ),
        ( 2, 20,  Years, 3.703 ),
        ( 2, 25,  Years, 3.541 ),
        ( 2, 30,  Years, 3.369 ),
]


class TestOvernightIndexedSwap(unittest.TestCase):

    def setUp(self):
        self.today = Date(5, 2, 2009)
        self.settlement_days = 2
        self.nominal = 100
        self.settings = Settings().__enter__()
        self.settings.evaluation_date = self.today
        self.eonia_term_structure = HandleYieldTermStructure()
        self.eonia_index = Eonia(self.eonia_term_structure)
        self.calendar = self.eonia_index.fixing_calendar
        self.settlement = self.calendar.advance(self.today, self.settlement_days, Following)
        self.eonia_term_structure.link_to(flat_rate(0.05))

    def make_swap(self, length, fixed_rate, spread, telescopic_value_dates, effective_date=None, payment_lag=0, averaging_method=RateAveraging.Compound):
        return (MakeOIS(length, self.eonia_index, fixed_rate, 0 * Days).
                with_effective_date(self.settlement if effective_date is None else effective_date).
                with_overnight_leg_spread(spread).
                with_nominal(self.nominal).
                with_payment_lag(payment_lag).
                with_discounting_term_structure(self.eonia_term_structure).
                with_telescopic_value_dates(telescopic_value_dates).
                with_averaging_method(averaging_method))()


    def test_fair_rate(self):
        lengths = [1 * Years, 2 * Years, 5 * Years, 10 * Years, 20 * Years]
        spreads = [-0.001, -.01, 0.0, 0.01, 0.001]
        for length, spread in product(lengths, spreads):
            with self.subTest(length=length, spread=spread):
                swap = self.make_swap(length, 0.0, spread, False)
                swap2 = self.make_swap(length, 0.0, spread, True)
                self.assertAlmostEqual(swap.fair_rate, swap2.fair_rate)

                swap = self.make_swap(length, swap.fair_rate, spread, False)
                self.assertAlmostEqual(swap.npv, 0.0)
                swap = self.make_swap(length, swap.fair_rate, spread, True)
                self.assertAlmostEqual(swap.npv, 0.0)

    def test_fair_spread(self):
        lengths = [1 * Years, 2 * Years, 5 * Years, 10 * Years, 20 * Years]
        rates = [0.04, 0.05, 0.06, 0.07]
        for length, rate in product(lengths, rates):
            with self.subTest(length=length, rate=rate):
                swap = self.make_swap(length, rate, 0.0, False)
                swap2 = self.make_swap(length, rate, 0.0, True)
                fair_spread = swap.fair_spread
                fair_spread2 = swap.fair_spread
                self.assertAlmostEqual(swap.fair_spread, swap2.fair_spread)
                swap = self.make_swap(length, rate, fair_spread, False)
                self.assertAlmostEqual(swap.npv, 0.0)
                swap = self.make_swap(length, rate, fair_spread, True)
                self.assertAlmostEqual(swap.npv, 0.0)

    def test_cached_value(self):
        flat = 0.05
        self.eonia_term_structure.link_to(flat_rate(flat, Actual360(), reference_date=self.settlement))
        fixed_rate = math.exp(flat) - 1
        swap = self.make_swap(1 * Years, fixed_rate, 0.0, False)
        swap2 = self.make_swap(1 * Years, fixed_rate, 0.0, True)
        cached_npv = 0.001730450147
        self.assertAlmostEqual(swap.npv, cached_npv)
        self.assertAlmostEqual(swap2.npv, cached_npv)

    def tearUp(self):
        self.settings.__exit__(None, None, None)

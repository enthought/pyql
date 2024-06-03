"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import unittest
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure, ForwardSpreadedTermStructure,
    DiscountCurve, ImpliedTermStructure
)
from quantlib.termstructures.yield_term_structure import HandleYieldTermStructure
from quantlib.quotes import SimpleQuote

from quantlib.settings import Settings
from quantlib.time.calendars.target import TARGET
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.daycounters.simple import Actual360, Actual365Fixed
from quantlib.time.date import today, Days

from quantlib.compounding import Simple
from quantlib.time.api import Date, Actual360
from quantlib.market.market import libor_market, IborMarket


class YieldTermStructureTestCase(unittest.TestCase):

    def test_default_constructor(self):

        term_structure = HandleYieldTermStructure()

        with self.assertRaises(ValueError):
            term_structure.current_link.discount(Settings().evaluation_date)

    def test_relinkable_structures(self):

        discounting_term_structure = HandleYieldTermStructure()

        settlement_days = 3
        flat_term_structure = FlatForward(settlement_days=settlement_days,
            forward=0.044, calendar=NullCalendar(), daycounter=Actual360())

        discounting_term_structure.link_to(flat_term_structure)

        evaluation_date = Settings().evaluation_date +100
        self.assertEqual(
            flat_term_structure.discount(evaluation_date),
            discounting_term_structure.current_link.discount(evaluation_date)
        )


        another_flat_term_structure = FlatForward(settlement_days=10,
            forward=0.067, calendar=NullCalendar(), daycounter=Actual365Fixed())

        discounting_term_structure.link_to(another_flat_term_structure)

        self.assertEqual(
            another_flat_term_structure.discount(evaluation_date),
            discounting_term_structure.current_link.discount(evaluation_date)
        )

        self.assertNotEqual(
            flat_term_structure.discount(evaluation_date),
            discounting_term_structure.current_link.discount(evaluation_date)
        )

class FlatForwardTestCase(unittest.TestCase):

    def setUp(self):

        self.calendar = TARGET()
        self.settlement_days = 2
        self.adjusted_today = self.calendar.adjust(today())
        Settings().evaluation_date = self.adjusted_today
        self.settlement_date = self.calendar.advance(
            today(), self.settlement_days, Days
        )

    def test_reference_evaluation_data_changed(self):
        """Testing term structure against evaluation date change... """

        quote = SimpleQuote()
        term_structure = FlatForward(settlement_days=self.settlement_days,
            forward=quote, calendar=NullCalendar(), daycounter=Actual360())

        quote.value = 0.03

        expected = []
        for days in [10, 30, 60, 120, 360, 720]:
            expected.append(
                term_structure.discount(self.adjusted_today + days)
            )

        Settings().evaluation_date = self.adjusted_today + 30

        calculated = []
        for days in [10, 30, 60, 120, 360, 720]:
            calculated.append(
                term_structure.discount(self.adjusted_today+ 30 + days)
            )

        for i, val in enumerate(expected):
            self.assertAlmostEqual(val, calculated[i])

class ForwardSpreadedTestCase(unittest.TestCase):

    def test_forward_spreaded_ts(self):
        m = libor_market('USD(NY)')
        eval_date = Date(20, 9, 2004)

        quotes = [('DEP', '1W', SimpleQuote(0.0382)),
                    ('DEP', '1M', SimpleQuote(0.0372)),
                    ('DEP', '3M', SimpleQuote(0.0363)),
                    ('DEP', '6M', SimpleQuote(0.0353)),
                    ('DEP', '9M', SimpleQuote(0.0348)),
                    ('DEP', '1Y', SimpleQuote(0.0345))]

        m.set_quotes(eval_date, quotes)
        ts = m.bootstrap_term_structure()

        discount_ts = m._discount_term_structure
        forecast_ts = m._forecast_term_structure
        discount_spd = 0.05
        forecast_spd = 0.08

        fwd_spd_dts = ForwardSpreadedTermStructure(discount_ts, SimpleQuote(discount_spd))
        fwd_spd_fts = ForwardSpreadedTermStructure(forecast_ts, SimpleQuote(forecast_spd))

        df_rate = round(float(discount_ts.current_link.forward_rate(Date(1, 1, 2005), Date(30, 1, 2005), Actual360(), Simple).rate), 2)
        dz_rate = round(float(discount_ts.current_link.zero_rate(Date(1, 1, 2005), Actual360(), Simple).rate), 2)

        fdf_rate = round(float(fwd_spd_dts.forward_rate(Date(1 ,1 , 2005), Date(30 ,1 ,2005), Actual360(), Simple).rate), 2)
        fdz_rate = round(float(fwd_spd_dts.zero_rate(Date(1, 1, 2005), Actual360(), Simple).rate), 2)

        ff_rate = round(float(forecast_ts.current_link.forward_rate(Date(1, 1, 2005), Date(30, 1, 2005), Actual360(), Simple).rate), 2)
        fz_rate = round(float(forecast_ts.current_link.zero_rate(Date(1, 1, 2005), Actual360(), Simple).rate), 2)

        ffc_rate= round(float(fwd_spd_fts.forward_rate(Date(1, 1, 2005), Date(30, 1, 2005), Actual360(), Simple).rate), 2)
        ffz_rate= round(float(fwd_spd_fts.zero_rate(Date(1, 1, 2005), Actual360() ,Simple).rate), 2)

        df_diff= fdf_rate - df_rate
        dz_diff= fdz_rate - dz_rate
        ff_diff = ffc_rate - ff_rate
        fz_diff = ffz_rate - fz_rate

        self.assertAlmostEqual(df_diff, discount_spd)
        self.assertAlmostEqual(dz_diff, discount_spd)
        self.assertAlmostEqual(ff_diff, forecast_spd)
        self.assertAlmostEqual(fz_diff, forecast_spd)

class ImpliedTermStructureTestCase(unittest.TestCase):
    def test_implied_ts(self):
        dates = [Date.from_string('2017-09-11'),
                 Date.from_string('2017-12-11'),
                 Date.from_string('2018-03-11')]
        dfs = [1.0, 0.8, 0.7]
        dc = DiscountCurve(dates, dfs, Actual365Fixed())
        dc_implied = ImpliedTermStructure(HandleYieldTermStructure(dc), Date.from_string('2017-11-11'))
        for d in dates[1:]:
            self.assertEqual(dc_implied.discount(d),
                             dc.discount(d) / dc.discount(Date.from_string('2017-11-11')))


if __name__ == '__main__':
    unittest.main()

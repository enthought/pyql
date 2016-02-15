"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from .unittest_tools import unittest

import datetime
import numpy as np

from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure)

from quantlib.quotes import SimpleQuote

from quantlib.settings import Settings
from quantlib.time.calendar import TARGET
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.daycounter import Actual360, Actual365Fixed
from quantlib.time.date import today, Days

from quantlib.compounding import Simple
from quantlib.time.api import Date
from quantlib.market.market import libor_market
from quantlib.termstructures.yields.forward_spreaded_term_structure import \
    ForwardSpreadedTermStructure

from quantlib.util.rates import make_rate_helper

from quantlib.termstructures.yields.api import PiecewiseYieldCurve
from quantlib.time.api import ActualActual, ISDA
from quantlib.util.converter import pydate_to_qldate


def QLDateTodate(dt):
    """
    Converts a QL Date to a datetime
    """

    return datetime.datetime(dt.year, dt.month, dt.day)


def dateToDate(dt):
    return Date(dt.day, dt.month, dt.year)


def zero_curve(ts, dtObs):
    dtMax = ts.max_date

    calendar = TARGET()
    days = range(10, 365 * 10, 100)
    dtMat = [min(dtMax, calendar.advance(dateToDate(dtObs), d, Days))
             for d in days]

    df = np.array([ts.discount(dt, extrapolate=True) for dt in dtMat])
    dtP = [QLDateTodate(dt) for dt in dtMat]
    dtToday = QLDateTodate(dtObs)
    dt = np.array([(d - dtToday).days / 365.0 for d in dtP])
    zc = -np.log(df) / dt
    return (dtMat, zc)


class SimpleQuoteTestCase(unittest.TestCase):

    def test_using_simple_quote(self):

        quote = SimpleQuote(10)

        self.assertEquals(10, quote.value)

        quote.value = 15

        self.assertEquals(15, quote.value)
        self.assertTrue(quote.is_valid)

    def test_empty_constructor(self):

        quote = SimpleQuote()

        self.assertTrue(quote.is_valid)
        self.assertEquals(0.0, quote.value)


class YieldTermStructureTestCase(unittest.TestCase):

    def test_default_constructor(self):

        term_structure = YieldTermStructure()

        with self.assertRaises(ValueError):
            term_structure.discount(Settings().evaluation_date)

    def test_relinkable_structures(self):

        discounting_term_structure = YieldTermStructure(relinkable=True)

        settlement_days = 3
        flat_term_structure = FlatForward(settlement_days=settlement_days,
            forward=0.044, calendar=NullCalendar(), daycounter=Actual360())

        discounting_term_structure.link_to(flat_term_structure)

        evaluation_date = Settings().evaluation_date +100
        self.assertEquals(
            flat_term_structure.discount(evaluation_date),
            discounting_term_structure.discount(evaluation_date)
        )

        another_flat_term_structure = FlatForward(settlement_days=10,
            forward=0.067, calendar=NullCalendar(), daycounter=Actual365Fixed())

        discounting_term_structure.link_to(another_flat_term_structure)

        self.assertEquals(
            another_flat_term_structure.discount(evaluation_date),
            discounting_term_structure.discount(evaluation_date)
        )

        self.assertNotEquals(
            flat_term_structure.discount(evaluation_date),
            discounting_term_structure.discount(evaluation_date)
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


    def test_accessors(self):
        """ testing accessors """

        rates_data = [('Libor1M',.01),
                  ('Libor3M', .015),
                  ('Libor6M', .017),
                  ('Swap1Y', .02),
                  ('Swap2Y', .03),
                  ('Swap3Y', .04),
                  ('Swap5Y', .05),
                  ('Swap7Y', .06),
                  ('Swap10Y', .07),
                  ('Swap20Y', .08)]

        settlement_date = pydate_to_qldate('01-Dec-2013')
        rate_helpers = []
        for label, rate in rates_data:
            h = make_rate_helper(label, rate, settlement_date)
            rate_helpers.append(h)

            ts_day_counter = ActualActual(ISDA)
            tolerance = 1.0e-15

        ts = PiecewiseYieldCurve(
            'discount', 'loglinear', settlement_date, rate_helpers,
            ts_day_counter, tolerance)

        self.assertEqual(ts.day_counter.name(), b"Actual/Actual (ISDA)")
        self.assertAlmostEqual(ts.time_from_reference(Date(1, 12, 2016)), 3.0,
                               delta=0.001)
        self.assertEqual(ts.reference_date, datetime.date(2013, 12, 1))


    def test_reference_evaluation_data_changed(self):
        """Testing term structure against evaluation date change... """

        quote = SimpleQuote()
        term_structure = FlatForward(settlement_days=self.settlement_days,
                                     forward=quote, calendar=NullCalendar(),
                                     daycounter=Actual360())

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
                term_structure.discount(self.adjusted_today + 30 + days)
            )

        for i, val in enumerate(expected):
            self.assertAlmostEquals(val, calculated[i])

            
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
        
        df_rate = round(float(discount_ts.forward_rate(Date(1, 1, 2005), Date(30, 1, 2005), Actual360(), Simple).rate), 2)
        dz_rate = round(float(discount_ts.zero_rate(Date(1, 1, 2005), Actual360(), Simple).rate), 2)
         
        fdf_rate = round(float(fwd_spd_dts.forward_rate(Date(1 ,1 , 2005), Date(30 ,1 ,2005), Actual360(), Simple).rate), 2)
        fdz_rate = round(float(fwd_spd_dts.zero_rate(Date(1, 1, 2005), Actual360(), Simple).rate), 2)
        
        ff_rate = round(float(forecast_ts.forward_rate(Date(1, 1, 2005), Date(30, 1, 2005), Actual360(), Simple).rate), 2)
        fz_rate = round(float(forecast_ts.zero_rate(Date(1, 1, 2005), Actual360(), Simple).rate), 2)
        
        ffc_rate= round(float(fwd_spd_fts.forward_rate(Date(1, 1, 2005), Date(30, 1, 2005), Actual360(), Simple).rate), 2)
        ffz_rate= round(float(fwd_spd_fts.zero_rate(Date(1, 1, 2005), Actual360() ,Simple).rate), 2)
        
        df_diff= fdf_rate - df_rate
        dz_diff= fdz_rate - dz_rate
        ff_diff = ffc_rate - ff_rate
        fz_diff = ffz_rate - fz_rate

        self.assertAlmostEquals(df_diff, discount_spd)
        self.assertAlmostEquals(dz_diff, discount_spd)
        self.assertAlmostEquals(ff_diff, forecast_spd)
        self.assertAlmostEquals(fz_diff, forecast_spd)

if __name__ == '__main__':
    unittest.main()

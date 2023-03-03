"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import unittest

from quantlib.indexes.inflation.australia import AUCPI
from quantlib.time.date import Monthly, Months, Period, Date
from quantlib.time.api import ( UnitedKingdom, ModifiedFollowing, ActualActual,
                                Schedule, Actual365Fixed, Unadjusted )
from quantlib.time.dategeneration import DateGeneration
from quantlib.instruments.bonds import CPIBond, InterpolationType
from quantlib.pricingengines.bond import DiscountingBondEngine
from quantlib.settings import Settings
from quantlib.termstructures.inflation_term_structure import \
    ZeroInflationTermStructure
from quantlib.termstructures.yields.api import FlatForward
from quantlib.indexes.inflation.ukrpi import UKRPI
from quantlib.indexes.inflation_index import InterpolationType
from quantlib.termstructures.inflation.api import \
    ZeroCouponInflationSwapHelper, PiecewiseZeroInflationCurve, Interpolator
from quantlib.quotes import SimpleQuote
from quantlib.cashflows.cpi_coupon_pricer import CPICouponPricer
from quantlib.cashflows.inflation_coupon_pricer import set_coupon_pricer

class TestInflationIndex(unittest.TestCase):

    def test_zero_index(self):
        aucpi = AUCPI(Monthly, True, True)
        self.assertEqual(aucpi.name, "Australia CPI")
        self.assertEqual(aucpi.frequency, Monthly)
        self.assertEqual(aucpi.availability_lag, Period(2, Months))

class TestCPIBond(unittest.TestCase):
    def setUp(self):
        self.calendar = UnitedKingdom()
        today = Date(25, 11, 2009)
        evaluation_date = self.calendar.adjust(today)
        Settings().evaluation_date = evaluation_date
        day_counter = ActualActual()

        rpi_schedule = Schedule.from_rule(Date(20, 7, 2007),
                                          Date(20, 11, 2009),
                                          Period(1, Months),
                                          self.calendar,
                                          ModifiedFollowing)
        self.cpi_ts = ZeroInflationTermStructure()
        self.yts = FlatForward(evaluation_date, 0.05, day_counter)
        self.ii = UKRPI(False, self.cpi_ts)
        fix_data = [206.1, 207.3, 208.0, 208.9, 209.7, 210.9,
                    209.8, 211.4, 212.1, 214.0, 215.1, 216.8,
                    216.5, 217.2, 218.4, 217.7, 216,
                    212.9, 210.1, 211.4, 211.3, 211.5,
                    212.8, 213.4, 213.4, 213.4, 214.4]

        for date, data in zip(rpi_schedule, fix_data):
            self.ii.add_fixing(date, data)

        dates = [Date(25, 11, 2010),
                 Date(25, 11, 2011),
                 Date(26, 11, 2012),
                 Date(25, 11, 2013),
                 Date(25, 11, 2014),
                 Date(25, 11, 2015),
                 Date(25, 11, 2016),
                 Date(25, 11, 2017),
                 Date(25, 11, 2018),
                 Date(25, 11, 2019),
                 Date(25, 11, 2021),
                 Date(25, 11, 2024),
                 Date(26, 11, 2029),
                 Date(27, 11, 2034),
                 Date(25, 11, 2039),
                 Date(25, 11, 2049),
                 Date(25, 11, 2059)]

        rates = [3.0495,
                 2.93,
                 2.9795,
                 3.029,
                 3.1425,
                 3.211,
                 3.2675,
                 3.3625,
                 3.405,
                 3.48,
                 3.576,
                 3.649,
                 3.751,
                 3.77225,
                 3.77,
                 3.734,
                 3.714]

        observation_lag = Period('2M')
        self.helpers = [ZeroCouponInflationSwapHelper(
            SimpleQuote(r / 100),
            observation_lag,
            maturity, self.calendar, ModifiedFollowing, day_counter, self.ii, InterpolationType.AsIndex, self.yts) \
                        for maturity, r in zip(dates, rates)]
        base_zero_rate = rates[0] / 100

        self.cpi_ts.link_to(
            PiecewiseZeroInflationCurve(Interpolator.Linear,
                                        evaluation_date, self.calendar, day_counter,
                                        observation_lag, self.ii.frequency,
                                        base_zero_rate, self.helpers))

    def test_clean_price(self):
        notional = 1000000.0;
        fixed_rates = [0.1]
        fixed_day_count = Actual365Fixed()
        fixed_calendar = self.calendar
        fixed_index = self.ii
        contractObservationLag = Period(3, Months);
        observationInterpolation = InterpolationType.Flat;
        settlement_days = 3
        growth_only = True

        baseCPI = 206.1

        fixed_schedule = Schedule.from_rule(Date(2, 10, 2007),
                                            Date(2, 10, 2052),
                                            Period(6, Months),
                                            fixed_calendar,
                                            Unadjusted,
                                            DateGeneration.Backward)

        cpi_bond = CPIBond(settlement_days, notional, growth_only,
                           baseCPI, contractObservationLag, fixed_index,
                           observationInterpolation, fixed_schedule,
                           fixed_rates, fixed_day_count, ModifiedFollowing)

        engine = DiscountingBondEngine(self.yts)
        cpi_bond.set_pricing_engine(engine)
        set_coupon_pricer(cpi_bond.cashflows, CPICouponPricer(self.yts))
        storedPrice = 383.01816406
        calculated = cpi_bond.clean_price
        self.assertAlmostEqual(storedPrice, calculated)

if __name__ == '__main__':
    unittest.main()

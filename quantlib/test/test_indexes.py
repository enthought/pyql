"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from .unittest_tools import unittest

from quantlib.currency.api import USDCurrency, EURCurrency
from quantlib.index import Index
from quantlib.indexes.interest_rate_index import InterestRateIndex
from quantlib.indexes.api import (
    Libor, SwapIndex, IborIndex, Euribor6M, USDLibor,
    UsdLiborSwapIsdaFixAm, IndexManager)
from quantlib.settings import Settings
from quantlib.time.api import (Days, Months, Years, Period, TARGET, Actual360,
                               today, Actual365Fixed, UnitedStates, Thirty360)
from quantlib.time.api import Following, ModifiedFollowing
from quantlib.time.calendars.united_states import GOVERNMENTBOND
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure)
from quantlib.time.api import Date, January


class TestIndex(unittest.TestCase):

    def test_create_index(self):

        with self.assertRaises(ValueError):
            Index()


class TestIRIndex(unittest.TestCase):

    def test_create_index(self):

        with self.assertRaises(ValueError):
            InterestRateIndex()

class TestIbor(unittest.TestCase):
    def test_create_ibor_index(self):
        euribor6m = IborIndex("Euribor", Period(6, Months), 2, EURCurrency(), TARGET(),
                              ModifiedFollowing, True, Actual360())
        default_euribor6m = Euribor6M()
        for attribute in ["business_day_convention", "end_of_month",
                           "fixing_calendar", "tenor", "fixing_days",
                           "day_counter", "family_name", "name"]:
            self.assertEqual(getattr(euribor6m, attribute),
                             getattr(default_euribor6m, attribute))

class TestLibor(unittest.TestCase):

    def test_create_libor_index(self):

        settings = Settings.instance()

        # Market information
        calendar = TARGET()

        # must be a business day
        eval_date = calendar.adjust(today())
        settings.evaluation_date = eval_date

        settlement_days = 2
        settlement_date = calendar.advance(eval_date, settlement_days, Days)
        # must be a business day
        settlement_date = calendar.adjust(settlement_date)

        term_structure = YieldTermStructure(relinkable=True)
        term_structure.link_to(FlatForward(settlement_date, 0.05,
                                           Actual365Fixed()))

        index = Libor('USD Libor', Period(6, Months), settlement_days,
                      USDCurrency(), calendar, Actual360(),
                      term_structure)

        t = index.tenor
        self.assertEqual(t.length, 6)
        self.assertEqual(t.units, 2)
        self.assertEqual('USD Libor6M Actual/360', index.name)


class TestEuribor(unittest.TestCase):

    def test_creation(self):

        settlement_date = Date(1, January, 2014)
        term_structure = YieldTermStructure()
        term_structure.link_to(FlatForward(settlement_date, 0.05,
                                           Actual365Fixed()))
        # Makes sure the constructor does not segfault anymore ;-)
        index = Euribor6M(term_structure)

        self.assertEqual(index.name, 'Euribor6M Actual/360')


    def test_empty_constructor(self):

        euribor_6m_index = Euribor6M()
        self.assertEqual(euribor_6m_index.name, 'Euribor6M Actual/360')

class TestUSDLibor(unittest.TestCase):

    def test_creation(self):

        settlement_date = Date(1, January, 2014)
        term_structure = YieldTermStructure()
        term_structure.link_to(FlatForward(settlement_date, 0.05,
                                           Actual365Fixed()))
        index = USDLibor(Period(3, Months), term_structure)

        self.assertEqual(index.name, 'USDLibor3M Actual/360')


    def test_empty_constructor(self):

        usdlibor_6m_index = USDLibor(Period(6, Months))
        self.assertEqual(usdlibor_6m_index.name, 'USDLibor6M Actual/360')

class SwapIndexTestCase(unittest.TestCase):

    def test_create_swap_index(self):

        term_structure = YieldTermStructure()
        term_structure.link_to(FlatForward(forward=0.05,
                                           daycounter=Actual365Fixed(),
                                           settlement_days=2,
                                           calendar=UnitedStates()))

        ibor_index = USDLibor(Period(3, Months), term_structure)

        index = SwapIndex(
            'UsdLiborSwapIsdaFixAm', Period(10, Years), 2, USDCurrency(),
            UnitedStates(GOVERNMENTBOND),
            Period(6, Months), ModifiedFollowing,
            Thirty360(), ibor_index)
        index2 = UsdLiborSwapIsdaFixAm(Period(10, Years), term_structure)
        for attr in ['name', 'family_name', 'fixing_calendar', 'tenor',
                'day_counter', 'currency']:
            self.assertEqual(getattr(index, attr), getattr(index2, attr))

class IndexManagerTestCase(unittest.TestCase):
    settlement_date = Date(1, January, 2014)
    term_structure = YieldTermStructure()
    term_structure.link_to(FlatForward(settlement_date, 0.05,
                                           Actual365Fixed()))
    index = USDLibor(Period(3, Months), term_structure)
    index.add_fixing(Date(5, 2, 2018), 1.79345)
    index.add_fixing(Date(2, 2, 2018), 1.78902)

    def test_index_manager_methods(self):
        self.assertIn(self.index.name.upper(), IndexManager.histories())
        ts = IndexManager.get_history(self.index.name.upper())
        self.assertEqual(ts[Date(5, 2, 2018)], 1.79345)
        self.assertEqual(ts[Date(2, 2, 2018)], 1.78902)
        IndexManager.clear_histories()
        self.assertFalse(IndexManager.get_history(self.index.name.upper()))

if __name__ == '__main__':
    unittest.main()

"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from .unittest_tools import unittest

from quantlib.currency import USDCurrency
from quantlib.index import Index
from quantlib.indexes import (InterestRateIndex, Libor, SwapIndex, Euribor6M)
from quantlib.settings import Settings
from quantlib.time import (Date, Days, January, Months, Period, TARGET, Actual360,
                               today, Actual365Fixed, Following)
from quantlib.termstructures.yields import (
    FlatForward, YieldTermStructure)


class TestIndex(unittest.TestCase):

    def test_create_index(self):

        with self.assertRaises(ValueError):
            Index()


class TestIRIndex(unittest.TestCase):

    def test_create_index(self):

        with self.assertRaises(ValueError):
            InterestRateIndex()


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
        term_structure = YieldTermStructure(relinkable=True)
        term_structure.link_to(FlatForward(settlement_date, 0.05,
                                          Actual365Fixed()))
        # Makes sure the constructor does not segfault anymore ;-)
        index = Euribor6M(term_structure)

        self.assertEqual(index.name, 'Euribor6M Actual/360')


    def test_empty_constructor(self):

        euribor_6m_index = Euribor6M()
        self.assertEqual(euribor_6m_index.name, 'Euribor6M Actual/360')


class SwapIndexTestCase(unittest.TestCase):

    def test_create_swap_index(self):

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

        ibor_index = Libor('USD Libor', Period(6, Months), settlement_days,
                        USDCurrency(), calendar, Actual360(),
                           term_structure)

        index = SwapIndex(
            'family name', Period(3, Months), 10, USDCurrency(), TARGET(),
            Period(12, Months), Following, Actual360(), ibor_index)

        self.assertIsNotNone(index)


if __name__ == '__main__':
    unittest.main()

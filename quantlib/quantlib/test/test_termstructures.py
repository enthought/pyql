import unittest

from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure
)
from quantlib.quotes import SimpleQuote

from quantlib.settings import Settings
from quantlib.time.calendar import TARGET
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.daycounter import Actual360, Actual365Fixed
from quantlib.time.date import today, Days


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

    def test_relinkable_structures(self):

        discounting_term_structure = YieldTermStructure(relinkable=True)

        settlement_days = 3
        flat_term_structure = FlatForward(
            settlement_days = settlement_days,
            forward         = 0.044,
            calendar        = NullCalendar(),
            daycounter      = Actual360()
        )

        discounting_term_structure.link_to(flat_term_structure)

        evaluation_date = Settings().evaluation_date +100
        self.assertEquals(
            flat_term_structure.discount(evaluation_date),
            discounting_term_structure.discount(evaluation_date)
        )


        another_flat_term_structure = FlatForward(
                    settlement_days = 10,
                    forward         = 0.067,
                    calendar        = NullCalendar(),
                    daycounter      = Actual365Fixed()
                )

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

    def test_reference_evaluation_data_changed(self):
        """Testing term structure against evaluation date change... """

        quote = SimpleQuote()
        term_structure = FlatForward(
            settlement_days = self.settlement_days,
            quote           = quote,
            calendar        = NullCalendar(),
            daycounter      = Actual360()
        )

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
            self.assertAlmostEquals(val, calculated[i])


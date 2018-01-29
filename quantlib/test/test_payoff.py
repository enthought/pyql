from .unittest_tools import unittest

from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import OptionType, Call

class PayoffTestCase(unittest.TestCase):

    def test_plain_vaniila_payoff(self):

        payoff = PlainVanillaPayoff(OptionType.Call, 10.0)

        self.assertEqual(payoff.type, Call)
        self.assertEqual(payoff.strike, 10.0)

        payoff = PlainVanillaPayoff(OptionType['Call'], 10.0)

        self.assertEqual(payoff.type, Call)
        self.assertEqual(payoff.strike, 10.0)

import unittest

from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import OptionType

class PayoffTestCase(unittest.TestCase):

    def test_plain_vaniila_payoff(self):

        payoff = PlainVanillaPayoff(OptionType.Call, 10.0)

        self.assertEqual(payoff.option_type, OptionType.Call)
        self.assertEqual(payoff.strike, 10.0)
        self.assertEqual(payoff(30.), 20.)
        payoff = PlainVanillaPayoff(OptionType['Call'], 10.0)
        self.assertEqual(payoff.option_type, OptionType.Call)
        self.assertEqual(payoff.strike, 10.0)

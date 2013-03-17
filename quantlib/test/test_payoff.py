from .unittest_tools import unittest

from quantlib.instruments.payoffs import PlainVanillaPayoff, PAYOFF_TO_STR, Call


class PayoffTestCase(unittest.TestCase):

    def test_plain_vaniila_payoff(self):

        payoff = PlainVanillaPayoff('call', 10.0)

        self.assertEquals(PAYOFF_TO_STR[payoff.type], 'Call')
        self.assertEquals(payoff.strike, 10.0)


        payoff = PlainVanillaPayoff(Call, 10.0)

        self.assertEquals(payoff.type, Call)
        self.assertEquals(payoff.strike, 10.0)

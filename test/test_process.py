import unittest
from quantlib.models.equity.bates_model import (BatesModel, BatesDoubleExpModel)
from quantlib.processes.heston_process import HestonProcess
from quantlib.processes.bates_process import BatesProcess

from quantlib.settings import Settings
from quantlib.time.api import (
    today, NullCalendar, ActualActual
)
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.quotes import SimpleQuote


def flat_rate(forward, daycounter):
    return FlatForward(
        forward = SimpleQuote(forward),
        settlement_days = 0,
        calendar = NullCalendar(),
        daycounter = daycounter
    )


class ProcessTestCase(unittest.TestCase):

    def setUp(self):
        settlement_date = today()

        settings = Settings()
        settings.evaluation_date = settlement_date

        daycounter = ActualActual()
        self.calendar = NullCalendar()

        i_rate = .1
        i_div = .04

        self.risk_free_ts = flat_rate(i_rate, daycounter)
        self.dividend_ts = flat_rate(i_div, daycounter)

        self.s0 = SimpleQuote(32.0)

        # Bates model

        self.v0 = 0.05
        self.kappa = 5.0
        self.theta = 0.05
        self.sigma = 1.0e-4
        self.rho = 0.0
        self.Lambda = .1
        self.nu = .01
        self.delta = .001

    def test_batest_process(self):
        pb = BatesProcess(self.risk_free_ts, self.dividend_ts, self.s0, self.v0,
                          self.kappa, self.theta, self.sigma, self.rho,
                          self.Lambda, self.nu, self.delta)

        self.assertIsNotNone(pb)

        mb = BatesModel(pb)

        self.assertIsNotNone(mb)

    def test_heston_process(self):

        ph = HestonProcess(self.risk_free_ts, self.dividend_ts, self.s0, self.v0,
                            self.kappa, self.theta, self.sigma, self.rho)
        self.assertIsNotNone(ph)

        # constructor with default arguments
        me = BatesDoubleExpModel(ph)
        self.assertIsNotNone(me)

        # specify the arguments
        me = BatesDoubleExpModel(ph, Lambda=0.234, nuUp=0.43, nuDown=0.54, p=.6)
        self.assertIsNotNone(me)

if __name__ == '__main__':
    unittest.main()


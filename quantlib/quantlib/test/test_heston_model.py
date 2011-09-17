import unittest

import numpy as np

from quantlib.models.equity.heston_model import HestonModelHelper, HestonModel
from quantlib.processes.heston_process import HestonProcess
from quantlib.pricingengines.vanilla import AnalyticHestonEngine
from quantlib.math.optimization import LevenbergMarquardt, EndCriteria
from quantlib.settings import Settings
from quantlib.time.api import today, Actual360, NullCalendar, Period, Months, Years
from quantlib.termstructures.yields.flat_forward import FlatForward, SimpleQuote


def flat_rate(forward, daycounter):
    return FlatForward(
        settlement_days = 0, 
        calendar        = NullCalendar(), 
        forward         = forward, 
        daycounter      = daycounter
    )

class HestonModelTestCase(unittest.TestCase):
    """Test cases are based on the test-suite/hestonmodel.cpp in QuantLib.

    """

    def setUp(self):

        self.settings = Settings()

    def test_black_calibration(self):

        todays_date = today()

        self.settings.evaluation_date = todays_date

        daycounter = Actual360()
        calendar = NullCalendar()

        risk_free_ts = flat_rate(0.04, daycounter)
        dividend_ts = flat_rate(0.50, daycounter)


        option_maturities = [
            Period(1, Months),
            Period(2, Months),
            Period(3, Months),
            Period(6, Months),
            Period(9, Months),
            Period(1, Years),
            Period(2, Years)
        ]

        options = []

        s0 = SimpleQuote(1.0)
        vol = SimpleQuote(0.1)

        volatility = vol.value

        for maturity in option_maturities:
            for moneyness in np.arange(-1.0, 2.0, 1.):
                tau = daycounter.yearFraction(
                    risk_free_ts.reference_date,
                    calendar.advance(
                        risk_free_ts.reference_date,
                        period=maturity)
                )
                forward_price = s0.value * dividend_ts.discount(tau) / \
                                risk_free_ts.discount(tau)
                strike_price = forward_price * np.exp(
                    -moneyness * volatility * np.sqrt(tau)
                )
                options.append(
                    HestonModelHelper(
                        maturity, calendar, s0.value, strike_price, vol, 
                        risk_free_ts, dividend_ts
                    )
                )


        for sigma in np.arange(0.1, 0.7, 0.2):
            v0    = 0.01
            kappa = 0.2
            theta = 0.02
            rho   = 0.75

            process = HestonProcess(
                risk_free_ts, dividend_ts, s0, v0, kappa, theta, sigma, rho
            )

            model = HestonModel(process)
            engine = AnalyticHestonEngine(model, 96)

            for option in options:
                option.set_pricing_engine(engine)

            optimisation_method = LevenbergMarquardt(1e-8, 1e-8, 1e-8)

            end_criteria = EndCriteria(400, 40, 1e-8, 1e-8, 1e-8)
            model.calibrate(options, optimisation_method, end_criteria)

            tolerance = 3.0e-3

            print v0, kappa, theta, rho
            print model.sigma
            self.assertTrue(model.sigma < tolerance) 



if __name__ == '__main__':
    unittest.main()

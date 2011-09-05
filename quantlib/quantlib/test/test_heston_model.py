import unittest

import numpy as np

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
                forward_price = s0.value * dividend_ts.discount(tau)
                strike_price = forward_price * np.exp(
                    -moneyness * volatility * np.sqrt(tau)
                )




        self.fail('Finish implementation')

if __name__ == '__main__':
    unittest.main()

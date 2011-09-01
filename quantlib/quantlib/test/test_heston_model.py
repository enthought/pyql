import unittest

from quantlib.settings import Settings
from quantlib.time.api import today, Actual360, NullCalendar, Period, Months
from quantlib.termstructures.yields.flat_forward import FlatForward, SimpleQuote

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

        risk_free_ts = FlatForward(forward=0.04, daycounter=daycounter)
        dividend_ts = FlatForward(forward=0.50, daycounter=daycounter)


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
            for moneyness in arange(-1.0, 2.0, 1.):
                tau = daycounter.yearFraction(
                    risk_free_ts.reference_date,
                    calendar.avance(
                        risk_free_ts.reference_date,
                        maturity)
                )




        self.fail('Finish implementation')

if __name__ == '__main__':
    unittest.main()

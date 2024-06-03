from quantlib.cashflows.rateaveraging import RateAveraging
from quantlib.math.interpolation import Linear
from quantlib.termstructures.yields.api import SofrFutureRateHelper, PiecewiseYieldCurve, BootstrapTrait, HandleYieldTermStructure
from quantlib.instruments.api import OvernightIndexFuture
from quantlib.time.date import Jan, Feb, Mar, Jun, Sep, Oct, Nov, Dec, October
from quantlib.time.api import Date, Monthly, Quarterly, Actual365Fixed
from quantlib.indexes.ibor.sofr import Sofr
from quantlib.settings import Settings

import unittest

class SofrFuture(unittest.TestCase):

    def setUp(self):
        self.today = Date(26, October, 2018)
        self.settings = Settings().__enter__()
        self.settings.evaluation_date = self.today

    def test_bootstrap(self):
        """ testing bootstrap over SOFR futures..."""

        sofr_quotes = [
            [Monthly, Oct, 2018, 97.8175],
            [Monthly, Nov, 2018, 97.770],
            [Monthly, Dec, 2018, 97.685],
            [Monthly, Jan, 2019, 97.595],
            [Monthly, Feb, 2019, 97.590],
            [Monthly, Mar, 2019, 97.525],
            [Quarterly, Mar, 2019, 97.440],
            [Quarterly, Jun, 2019, 97.295],
            [Quarterly, Sep, 2019, 97.220],
            [Quarterly, Dec, 2019, 97.170],
            [Quarterly, Mar, 2020, 97.160],
            [Quarterly, Jun, 2020, 97.165],
            [Quarterly, Sep, 2020, 97.175],
        ]
        index = Sofr()
        index.add_fixing(Date(1, October, 2018), 0.0222)
        index.add_fixing(Date(2, October, 2018), 0.022)
        index.add_fixing(Date(3, October, 2018), 0.022)
        index.add_fixing(Date(4, October, 2018), 0.0218)
        index.add_fixing(Date(5, October, 2018), 0.0216)
        index.add_fixing(Date(9, October, 2018), 0.0215)
        index.add_fixing(Date(10, October, 2018), 0.0215)
        index.add_fixing(Date(11, October, 2018), 0.0217)
        index.add_fixing(Date(12, October, 2018), 0.0218)
        index.add_fixing(Date(15, October, 2018), 0.0221)
        index.add_fixing(Date(16, October, 2018), 0.0218)
        index.add_fixing(Date(17, October, 2018), 0.0218)
        index.add_fixing(Date(18, October, 2018), 0.0219)
        index.add_fixing(Date(19, October, 2018), 0.0219)
        index.add_fixing(Date(22, October, 2018), 0.0218)
        index.add_fixing(Date(23, October, 2018), 0.0217)
        index.add_fixing(Date(24, October, 2018), 0.0218)
        index.add_fixing(Date(25, October, 2018), 0.0219)

        helpers = []
        for freq, month, year, price in sofr_quotes:
            helpers.append(
                SofrFutureRateHelper(price, month, year, freq, 0.0)
            )

        curve = PiecewiseYieldCurve[BootstrapTrait.Discount, Linear].from_reference_date(self.today, helpers, Actual365Fixed())
        sofr = Sofr(HandleYieldTermStructure(curve))
        sf = OvernightIndexFuture(sofr, Date(20, Mar, 2019), Date(19, Jun, 2019))
        expected_price = 97.44
        tolerance = 1e-9
        self.assertAlmostEqual(sf.npv, expected_price, 9)

    def tearDown(self):
        self.settings.__exit__(None, None, None)

import math
import unittest
from quantlib.time.api import Date
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.termstructures.volatility.sabr_interpolated_smilesection \
    import SabrInterpolatedSmileSection
from quantlib.termstructures.volatility.sabr import unsafe_sabr_volatility

import numpy as np

class SabrTestCase(unittest.TestCase):
    def setUp(self):
        option_date = Date(20, 9, 2017)
        Settings().evaluation_date = Date(4, 8, 2017)
        self.strikes = np.array([50, 55, 57.5, 60, 62.5, 65, 67.5, 70, 75, 80, 85, 90, 95, 100]) * 1e-4
        vol = np.array([28.5, 31.6, 33.7, 36.1, 38.7, 41.5, 44.1,
                        46.5, 50.8, 54.4, 57.3, 59.8, 61.8, 63.6]) * 1e-2
        vol_quotes = [SimpleQuote(q) for q in vol]
        self.forward = SimpleQuote(58.71e-4)
        atm_vol = (60-58.71)/1.5*33.7 + (58.71-57.5)/1.5*36.1
        self.sabr_smile = SabrInterpolatedSmileSection(option_date, self.forward, self.strikes, False,
                                                       SimpleQuote(0.4), vol_quotes, 0.1, 1, 0.1, 0.5,
                                                       is_beta_fixed=True)
    def test_params(self):
        alpha, rho, nu = self.sabr_smile.alpha, self.sabr_smile.rho, self.sabr_smile.nu
        self.assertTrue(alpha > 0)
        self.assertTrue(rho > -1 and rho < 1)
        self.assertTrue(nu > 0)

    def test_errors(self):
        self.assertTrue(self.sabr_smile.max_error > self.sabr_smile.rms_error)

    def test_sabr_formula(self):
        alpha, rho, nu = self.sabr_smile.alpha, self.sabr_smile.rho, self.sabr_smile.nu
        for K in self.strikes:
            self.assertEqual(self.sabr_smile.volatility(K),
                             unsafe_sabr_volatility(K,
                                                    self.forward.value,
                                                    self.sabr_smile.exercise_time,
                                                    alpha, 1., nu, rho))


if __name__ == "__main__":
    unittest.main()

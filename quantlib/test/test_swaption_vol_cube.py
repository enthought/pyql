import unittest
from quantlib.math.matrix import Matrix
from quantlib.time.api import (Period, Years, Months, UnitedStates,
                               Following, Actual365Fixed)
from quantlib.termstructures.yields.api import FlatForward
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.volatility.swaption.swaption_vol_matrix \
    import SwaptionVolatilityMatrix
from quantlib.termstructures.volatility.swaption.swaption_vol_cube1 \
    import SwaptionVolCube1
from quantlib.termstructures.volatility.swaption.spreaded_swaption_vol \
    import SpreadedSwaptionVolatility
from quantlib.indexes.api import EuriborSwapIsdaFixA
import numpy as np


class SwaptionVolatilityCubeTestCase(unittest.TestCase):
    def setUp(self):
        atm_option_tenors = [Period(1, Months), Period(6, Months)] + \
                            [Period(i, Years) for i in [1, 5, 10, 30]]
        atm_swap_tenors = [Period(1, Years), Period(5, Years),
                           Period(10, Years), Period(30, Years)]

        m = np.array([[.1300, .1560, .1390, .1220],
                      [.1440, .1580, .1460, .1260],
                      [.1600, .1590, .1470, .1290],
                      [.1640, .1470, .1370, .1220],
                      [.1400, .1300, .1250, .1100],
                      [.1130, .1090, .1070, .0930]])

        M = Matrix.from_ndarray(m)

        calendar = UnitedStates()
        self.atm_vol_matrix = SwaptionVolatilityMatrix(calendar,
                                                       Following,
                                                       atm_option_tenors,
                                                       atm_swap_tenors,
                                                       M,
                                                       Actual365Fixed())
        term_structure = FlatForward(forward=0.05, settlement_days=2, calendar=calendar,
            daycounter=Actual365Fixed())
        self.swap_index_base = EuriborSwapIsdaFixA(Period(2, Years),
                                                   term_structure)
        self.short_swap_index_base = EuriborSwapIsdaFixA(Period(1, Years),
                                                         term_structure)
        self.vega_weighted_smile_fit = False

        class Cube:
            def __init__(self):
                self.option_tenors = [Period(1, Years), Period(10, Years), Period(30, Years)]
                self.swap_tenors = [Period(2, Years), Period(10, Years), Period(30, Years)]
                self.strike_spreads = [-0.02, -0.005, 0, 0.005, 0.02]
                self.vol_spreads = np.array([[0.0599, 0.0049, 0.0000, -0.0001, 0.0127],
                                             [0.0729, 0.0086, 0.0000, -0.0024, 0.0098],
                                             [0.0738, 0.0102, 0.0000, -0.0039, 0.0065],
                                             [0.0465, 0.0063, 0.0000, -0.0032, -0.0010],
                                             [0.0558, 0.0084, 0.0000, -0.0050, -0.0057],
                                             [0.0576, 0.0083, 0.0000, -0.0043, -0.0014],
                                             [0.0437, 0.0059, 0.0000, -0.0030, -0.0006],
                                             [0.0533, 0.0078, 0.0000, -0.0045, -0.0046],
                                             [0.0545, 0.0079, 0.0000, -0.0042, -0.0020]])
                self.vol_spreads_handle = []
                for vs in self.vol_spreads:
                    self.vol_spreads_handle.append([SimpleQuote(v) for v in vs])
        self.cube = Cube()

    def test_sabr_vols(self):
        parameters_guess = []
        for i in range(len(self.cube.option_tenors) * len(self.cube.swap_tenors)):
            parameters_guess.append([SimpleQuote(0.2), SimpleQuote(0.5),
                                     SimpleQuote(0.4), SimpleQuote(0.)])
        is_parameter_fixed = [False] * 4
        vol_cube = SwaptionVolCube1(self.atm_vol_matrix,
                                    self.cube.option_tenors,
                                    self.cube.swap_tenors,
                                    self.cube.strike_spreads,
                                    self.cube.vol_spreads_handle,
                                    self.swap_index_base,
                                    self.short_swap_index_base,
                                    self.vega_weighted_smile_fit,
                                    parameters_guess,
                                    is_parameter_fixed,
                                    True)

        tolerance = 3e-4
        for t1 in self.atm_vol_matrix.option_tenors:
            for t2 in self.atm_vol_matrix.swap_tenors:
                strike = vol_cube.atm_strike(t1, t2)
                exp_vol = self.atm_vol_matrix.volatility(t1, t2, True)
                act_vol = vol_cube.volatility(t1, t2, strike, True)
                self.assertAlmostEqual(exp_vol, act_vol, delta=tolerance)

        for i, t1 in enumerate(vol_cube.option_tenors):
            for j, t2 in enumerate(vol_cube.swap_tenors):
                for k, s in enumerate(vol_cube.strike_spreads):
                    atm_strike = vol_cube.atm_strike(t1, t2)
                    atm_vol = self.atm_vol_matrix.volatility(t1, t2, True)
                    vol = vol_cube.volatility(t1, t2, atm_strike + s, True)
                    spread = vol - atm_vol
                    self.assertAlmostEqual(
                        self.cube.vol_spreads[i * len(vol_cube.swap_tenors) + j][k],
                        spread, delta=12e-4)

    def test_spreaded_cube(self):
        parameters_guess = []
        for i in range(len(self.cube.option_tenors) * len(self.cube.swap_tenors)):
            parameters_guess.append([SimpleQuote(0.2), SimpleQuote(0.5),
                                     SimpleQuote(0.4), SimpleQuote(0.)])
        is_parameter_fixed = [False] * 4
        spread = SimpleQuote(0.0001)
        vol_cube = SwaptionVolCube1(self.atm_vol_matrix,
                                    self.cube.option_tenors,
                                    self.cube.swap_tenors,
                                    self.cube.strike_spreads,
                                    self.cube.vol_spreads_handle,
                                    self.swap_index_base,
                                    self.short_swap_index_base,
                                    self.vega_weighted_smile_fit,
                                    parameters_guess,
                                    is_parameter_fixed,
                                    True)
        spreaded_vol_cube = SpreadedSwaptionVolatility(vol_cube,
                                                       spread)
        strikes = np.linspace(0.01, 0.99, 99)
        for t1 in self.cube.option_tenors:
            for t2 in self.cube.swap_tenors:
                smile_section_by_cube = vol_cube.smile_section(
                    t1, t2)
                smile_section_by_spreaded_cube = (spreaded_vol_cube.
                                                  smile_section(t1, t2))
                for k in strikes:
                    diff = spreaded_vol_cube.volatility(t1, t2, k) - \
                           vol_cube.volatility(t1, t2, k)
                    self.assertAlmostEqual(diff, spread.value)
                    diff = smile_section_by_spreaded_cube.volatility(k) - \
                           smile_section_by_cube.volatility(k)

                    self.assertAlmostEqual(diff, spread.value)

if __name__ == "__main__":
    unittest.main()

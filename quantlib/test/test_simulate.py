import numpy as np

import unittest
from quantlib.processes.heston_process import HestonProcess
from quantlib.processes.bates_process import BatesProcess
from quantlib.models.equity.heston_model import HestonModel
from quantlib.models.equity.bates_model import BatesModel

from quantlib.settings import Settings
from quantlib.time.api import (
    today, NullCalendar, ActualActual
)
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.quotes import SimpleQuote


from quantlib.sim.simulate import simulate_model
from quantlib.time_grid import TimeGrid

from quantlib.processes.heston_process import PARTIALTRUNCATION


def flat_rate(forward, daycounter):
    return FlatForward(
        forward=SimpleQuote(forward),
        settlement_days=0,
        calendar=NullCalendar(),
        daycounter=daycounter
    )


class SimTestCase(unittest.TestCase):
    """
    Test simulation execution
    """

    def setUp(self):

        self.settings = Settings()
        daycounter = ActualActual()
        interest_rate = .1
        dividend_yield = .04

        self.risk_free_ts = flat_rate(interest_rate, daycounter)
        self.dividend_ts = flat_rate(dividend_yield, daycounter)

        s0 = SimpleQuote(32.0)

        # Heston model

        v0 = 0.05
        kappa = 5.0
        theta = 0.05
        sigma = 1.0e-4
        rho = -0.5

        self.heston_process = HestonProcess(self.risk_free_ts,
                                            self.dividend_ts, s0, v0,
                                            kappa, theta, sigma, rho,
                                            PARTIALTRUNCATION)

        v0 = 0.05
        ival = {'v0': v0, 'kappa': 3.7, 'theta': v0,
                'sigma': 1.0, 'rho': -.6, 'lambda': .1,
                'nu': -.5, 'delta': 0.3}

        spot = SimpleQuote(1200)

        self.bates_process = BatesProcess(
            self.risk_free_ts, self.dividend_ts,
            spot, ival['v0'], ival['kappa'],
            ival['theta'], ival['sigma'], ival['rho'],
            ival['lambda'], ival['nu'], ival['delta'])

    def test_simulate_heston_1(self):

        settings = self.settings
        settlement_date = today()
        settings.evaluation_date = settlement_date

        # simulate Heston paths
        paths = 4
        steps = 10
        horizon = 1
        seed = 12345

        model = HestonModel(self.heston_process)
        grid = TimeGrid(horizon, steps)
        res = simulate_model(model, paths, grid, seed)

        time = list(grid) 
        time_expected = np.arange(0, 1.1, .1)
        simulations = res

        np.testing.assert_array_almost_equal(time, time_expected, decimal=4)

    def test_simulate_heston_2(self):

        s0 = SimpleQuote(100.0)
        v0    = 0.05
        kappa = 5.0
        theta = 0.05
        sigma = 1.0e-4
        rho   = 0.0

        process = HestonProcess(self.risk_free_ts,
                                self.dividend_ts, s0, v0,
                                kappa, theta, sigma, rho)

        model = HestonModel(process)

        nbPaths = 4
        nbSteps = 100
        horizon = 1
        seed = 12345
        grid = TimeGrid(horizon, nbSteps)
        res = simulate_model(model, nbPaths, grid, seed)
        self.assertAlmostEqual(res[-1, 0], 152.50, delta=.1)

    def test_simulate_bates(self):

        model = BatesModel(self.bates_process)

        paths = 4
        steps = 10
        horizon = 1
        seed = 12345
        grid = TimeGrid(horizon, steps)
        res = simulate_model(model, paths, grid, seed)

        time = list(grid)
        time_expected = np.arange(0, 1.1, .1)
        simulations = res

        np.testing.assert_array_almost_equal(time, time_expected, decimal=4)


if __name__ == '__main__':
    unittest.main()

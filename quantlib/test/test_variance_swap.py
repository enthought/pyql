import datetime
import unittest

import numpy as np

from quantlib.settings import Settings
from quantlib.instruments.option import EuropeanExercise, OptionType
from quantlib.instruments.variance_swap import VarianceSwap, SwapType
from quantlib.math.matrix import Matrix
from quantlib.pricingengines.forward.replicating_variance_swap_engine import ReplicatingVarianceSwapEngine
from quantlib.pricingengines.forward.mc_variance_swap_engine import MakeMCVarianceSwapEngine
from quantlib.pricingengines.forward.mc_variance_swap_engine import MCVarianceSwapEngine
from quantlib.processes.api import BlackScholesMertonProcess
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.termstructures.volatility.equityfx.black_variance_curve import BlackVarianceCurve
from quantlib.termstructures.volatility.equityfx.black_variance_surface import BlackVarianceSurface
from quantlib.time.api import Date, today, NullCalendar, Actual365Fixed

# Tests adapted from Quantlib test-suite/varianceswaps.cpp

class VarianceSwapTestCase(unittest.TestCase):

    def setUp(self):
        """"""
        self.today = today()
        self.settings = Settings()
        self.settings.evaluation_date = self.today
        self.dc = Actual365Fixed()
        self.spot = SimpleQuote(0.0)
        self.q_rate = SimpleQuote(0.0)
        self.q_ts = FlatForward(self.today, self.q_rate, self.dc)
        self.r_rate = SimpleQuote(0.0)
        self.r_ts = FlatForward(self.today, self.r_rate, self.dc)
        self.values = {
            'type' : SwapType.Long,
            'strike' : 0.04,
            'nominal' : 50000,
            's' : 100.0,
            'q' : 0.00,
            'r' : 0.05,
            't' : 0.246575,
            'v' : 0.20,
            'result' : 0.04189,
            'tol' : 1.0e-4,
        }
        self.spot.value = self.values['s']
        self.q_rate.value = self.values['q']
        self.r_rate.value = self.values['r']
        self.ex_date = self.today + int(self.values['t']*365+0.5)
        #self.factory = (MakeMCVarianceSwapEngine(stochProcess).
        #                                                with_steps_per_year(250).
        #                                                with_samples(1023).
        #                                                with_seed(42))

    def test_replicating_variance_swap(self):
        """
            data from "A Guide to Volatility and Variance Swaps",
            Derman, Kamal & Zou, 1999
            with maturity t corrected from 0.25 to 0.246575
            corresponding to Jan 1, 1999 to Apr 1, 1999
        """

        replicating_option_data = [
            {'type':OptionType.Put,  'strike':50,  'v':0.30},
            {'type':OptionType.Put,  'strike':55,  'v':0.29},
            {'type':OptionType.Put,  'strike':60,  'v':0.28},
            {'type':OptionType.Put,  'strike':65,  'v':0.27},
            {'type':OptionType.Put,  'strike':70,  'v':0.26},
            {'type':OptionType.Put,  'strike':75,  'v':0.25},
            {'type':OptionType.Put,  'strike':80,  'v':0.24},
            {'type':OptionType.Put,  'strike':85,  'v':0.23},
            {'type':OptionType.Put,  'strike':90,  'v':0.22},
            {'type':OptionType.Put,  'strike':95,  'v':0.21},
            {'type':OptionType.Put,  'strike':100, 'v':0.20},
            {'type':OptionType.Call, 'strike':100, 'v':0.20},
            {'type':OptionType.Call, 'strike':105, 'v':0.19},
            {'type':OptionType.Call, 'strike':110, 'v':0.18},
            {'type':OptionType.Call, 'strike':115, 'v':0.17},
            {'type':OptionType.Call, 'strike':120, 'v':0.16},
            {'type':OptionType.Call, 'strike':125, 'v':0.15},
            {'type':OptionType.Call, 'strike':130, 'v':0.14},
            {'type':OptionType.Call, 'strike':135, 'v':0.13},
        ]

        dates = [self.ex_date]

        call_strikes, put_strikes, call_vols, put_vols = [], [], [], []

        # Assumes ascending strikes and same min call and max put strikes
        for data in replicating_option_data:
            if data['type'] == OptionType.Call:
                call_strikes.append(data['strike'])
                call_vols.append(data['v'])
            elif data['type'] == OptionType.Put:
                put_strikes.append(data['strike'])
                put_vols.append(data['v'])
            else:
                raise ValueError("unknown option type")

        #vols = Matrix(len(replicating_option_data)-1, 1)
        vols = np.zeros((len(replicating_option_data)-1, 1))
        strikes = []
        for j, v in enumerate(put_vols):
            vols[j][0] = v
            strikes.append(put_strikes[j])

        for k in range(1,len(call_vols)):
            j = len(put_vols)-1
            vols[j+k][0] = call_vols[k]
            strikes.append(call_strikes[k])

        vols_mat = Matrix.from_ndarray(vols)

        vol_ts = BlackVarianceSurface(self.today, NullCalendar(), dates, strikes,
                                      vols_mat, self.dc)

        stoch_process = BlackScholesMertonProcess(self.spot, self.q_ts, self.r_ts,
                                                  vol_ts)

        engine = ReplicatingVarianceSwapEngine(stoch_process,
                                               call_strikes,
                                               put_strikes,
                                               5.0)

        variance_swap = VarianceSwap(self.values['type'],
                                     self.values['strike'],
                                     self.values['nominal'],
                                     self.today,
                                     self.ex_date,
                                     )

        variance_swap.set_pricing_engine(engine)

        calculated = variance_swap.variance
        expected = self.values['result']

        self.assertAlmostEqual(calculated, expected, delta=self.values['tol'])


    def test_mc_variance_swap(self):
        """ test mc variance engine vs expected result
        """

        vols = []
        dates = []

        interm_date = self.today + int(0.1*365+0.5)
        exercise = EuropeanExercise(self.ex_date)

        dates.append(interm_date)
        dates.append(self.ex_date)

        vols.append(0.1)
        vols.append(self.values['v'])

        # Exercising code using BlackVarianceCurve because BlackVarianceSurface
        # is unreliable. Result should be v*v for arbitrary t1 and v1
        # (as long as 0<=t1<t and 0<=v1<v)

        vol_ts = BlackVarianceCurve(self.today, dates, vols, self.dc, True)

        stoch_process = BlackScholesMertonProcess(self.spot, self.q_ts,
                                                  self.r_ts, vol_ts)

        engine = MCVarianceSwapEngine(stoch_process,
                                      time_steps_per_year=250,
                                      required_samples=1023,
                                      seed=42,
                                      )


        variance_swap = VarianceSwap(self.values['type'],
                                     self.values['strike'],
                                     self.values['nominal'],
                                     self.today,
                                     self.ex_date,
                                     )

        variance_swap.set_pricing_engine(engine)

        calculated = variance_swap.variance
        expected = 0.04
        tol = 3.0e-4
        error = abs(calculated-expected)
        self.assertTrue(error<tol)


if __name__ == "__main__":
    unittest.main()

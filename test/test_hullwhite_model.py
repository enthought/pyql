from __future__ import division
from __future__ import print_function

import unittest

from quantlib.models.shortrate.onefactormodels.hullwhite import HullWhite
from quantlib.settings import Settings

from quantlib.time.api import (Date, Years, Actual365Fixed,
                               Thirty360, Actual360, Period,
                               February, NullCalendar)

from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.indexes.ibor.euribor import Euribor6M
from quantlib.pricingengines.swaption.jamshidian_swaption_engine import JamshidianSwaptionEngine
from quantlib.quotes import SimpleQuote
from quantlib.models.shortrate.calibrationhelpers.swaption_helper \
    import SwaptionHelper

from quantlib.math.optimization import LevenbergMarquardt, EndCriteria

from .utilities import flat_rate

class HullWhiteModelTestCase(unittest.TestCase):

    def setUp(self):
        self.settings = Settings()

    def test_hull_white_creation(self):
        """
        Basic instantiation of a Hull-White model
        """
        today = Date(15, February, 2002)
        self.settings.evaluation_date = today
        yield_ts = flat_rate(0.04875825, Actual360())

        model = HullWhite(yield_ts, a=0.0001, sigma=.1)

        p = model.params()

        self.assertEqual(p[0], model.a)
        self.assertAlmostEqual(p[1], model.sigma)

    def test_hull_white_calibration(self):
        """
        Adapted from ShortRateModelTest::testCachedHullWhite()
        """

        today = Date(15, February, 2002)
        settlement = Date(19, February, 2002)
        self.settings.evaluation_date = today
        yield_ts = FlatForward(settlement,
                               forward=0.04875825,
                               settlement_days=0,
                               calendar=NullCalendar(),
                               daycounter=Actual365Fixed())

        model = HullWhite(yield_ts, a=0.05, sigma=.005)

        data = [[1, 5, 0.1148 ],
                [2, 4, 0.1108 ],
                [3, 3, 0.1070 ],
                [4, 2, 0.1021 ],
                [5, 1, 0.1000 ]]

        index = Euribor6M(yield_ts)

        engine = JamshidianSwaptionEngine(model)

        swaptions = []
        for start, length, volatility in data:
            vol = SimpleQuote(volatility)
            helper = SwaptionHelper(Period(start, Years),
                                    Period(length, Years),
                                    vol,
                                    index,
                                    Period(1, Years), Thirty360(),
                                    Actual360(), yield_ts)

            helper.set_pricing_engine(engine)
            swaptions.append(helper)

        # Set up the optimization problem
        om = LevenbergMarquardt(1.0e-8, 1.0e-8, 1.0e-8)
        endCriteria = EndCriteria(10000, 100, 1e-6, 1e-8, 1e-8)

        model.calibrate(swaptions, om, endCriteria)

        print('Hull White calibrated parameters:\na: %f sigma: %f' %
              (model.a, model.sigma))

        cached_a = 0.0464041
        cached_sigma = 0.00579912

        tolerance = 1.0e-5

        self.assertAlmostEqual(cached_a, model.a, delta=tolerance)
        self.assertAlmostEqual(cached_sigma, model.sigma, delta=tolerance)

if __name__ == '__main__':
    unittest.main()

""" Unittests for the CDS related classes. """

from .unittest_tools import  unittest

from quantlib.settings import Settings
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.api import FlatForward
from quantlib.termstructures.credit.api import (
    SpreadCdsHelper, PiecewiseDefaultCurve, FlatHazardRate)
from quantlib.time.api import TARGET, Date, Actual365Fixed, Years, \
        Following, Quarterly, TwentiethIMM, May, Period, Days
import math

def create_helper():

    calendar = TARGET()

    todays_date = Date(15, May, 2007)
    todays_date = calendar.adjust(todays_date)

    Settings.instance().evaluation_date = todays_date

    flat_rate = SimpleQuote(0.01)
    ts_curve = FlatForward(todays_date, flat_rate, Actual365Fixed())

    recovery_rate = 0.5
    quoted_spreads = 0.0150
    tenor = Period(5, Years)

    helper = SpreadCdsHelper(
            quoted_spreads, tenor, 0, calendar, Quarterly,
            Following, TwentiethIMM, Actual365Fixed(), recovery_rate, ts_curve
    )

    return todays_date, helper



class SpreadCdsHelperTestCase(unittest.TestCase):

    def test_create_helper(self):

        todays_date, helper = create_helper()

        self.assertIsNotNone(helper)
        self.assertEqual(helper.latest_date, Date(20, 6, 2012))

class PiecewiseDefaultCurveTestCase(unittest.TestCase):
    todays_date, helper = create_helper()
    d = todays_date + Period(3, Years)

    def test_create_piecewise(self):

        for trait in ['HazardRate', 'DefaultDensity', 'SurvivalProbability']:
            for interpolator in ['Linear', 'LogLinear', 'BackwardFlat']:
                curve = PiecewiseDefaultCurve(
                    trait,
                    interpolator,
                    reference_date=self.todays_date,
                    helpers=[self.helper],
                    daycounter=Actual365Fixed()
                )
                self.assertIsNotNone(curve)

    def test_piecewise_methods(self):

        for trait in ['HazardRate', 'DefaultDensity', 'SurvivalProbability']:
            for interpolator in ['Linear', 'LogLinear', 'BackwardFlat']:
                curve = PiecewiseDefaultCurve(
                    trait,
                    interpolator,
                    reference_date=self.todays_date,
                    helpers=[self.helper],
                    daycounter=Actual365Fixed()
                )

                if interpolator == "LogLinear" and trait in ["HazardRate",
                                                             "DefaultDensity"]:
                    with self.assertRaisesRegexp(RuntimeError,
                                                 'LogInterpolation primitive not implemented'):
                        curve.survival_probability(self.d)
                else:
                    self.assertEqual(curve.survival_probability(self.d),
                                     curve.survival_probability(curve.time_from_reference(self.d)))
                    self.assertEqual(curve.hazard_rate(self.d),
                                     curve.hazard_rate(curve.time_from_reference(self.d)))

class FlatHazardRateTestCase(unittest.TestCase):

    calendar = TARGET()

    todays_date = Date(15, May, 2007)
    todays_date = calendar.adjust(todays_date)

    d = todays_date + Period(3, Years)

    def test_create_flat_hazard(self):
        Settings.instance().evaluation_date = self.todays_date
        flat_curve = FlatHazardRate(2, self.calendar, 0.05, Actual365Fixed())
        flat_curve_from_reference_date = FlatHazardRate.from_reference_date(
            self.calendar.advance(self.todays_date, 2, Days), 0.05, Actual365Fixed())
        self.assertIsNotNone(flat_curve)
        self.assertIsNotNone(flat_curve_from_reference_date)
        self.assertEqual(flat_curve.time_from_reference(self.d),
                         flat_curve_from_reference_date.time_from_reference(self.d))
        self.assertAlmostEqual(flat_curve.hazard_rate(self.d), 0.05)
        self.assertAlmostEqual(flat_curve.survival_probability(self.d),
                               math.exp(-0.05*flat_curve.time_from_reference(self.d)))


if __name__ == '__main__':
    unittest.main()

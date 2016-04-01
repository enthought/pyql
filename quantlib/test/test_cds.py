""" Unittests for the CDS related classes. """

from .unittest_tools import  unittest

from quantlib.settings import Settings
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields import FlatForward
from quantlib.termstructures.credit import SpreadCdsHelper, PiecewiseDefaultCurve
from quantlib.time import TARGET, Date, Actual365Fixed, Months, \
        Following, Quarterly, TwentiethIMM, May, Period


def create_helper():

    calendar = TARGET()

    todays_date = Date(15, May, 2007)
    todays_date = calendar.adjust(todays_date)

    Settings.instance().evaluation_date = todays_date

    flat_rate = SimpleQuote(0.01)
    ts_curve = FlatForward(todays_date, flat_rate, Actual365Fixed())

    recovery_rate = 0.5
    quoted_spreads = 0.0150
    tenor = Period(3, Months)

    helper = SpreadCdsHelper(
            quoted_spreads, tenor, 0, calendar, Quarterly,
            Following, TwentiethIMM, Actual365Fixed(), recovery_rate, ts_curve
    )

    return todays_date, helper



class SpreadCdsHelperTestCase(unittest.TestCase):

    def test_create_helper(self):

        todays_date, helper = create_helper()

        self.assertIsNotNone(helper)

class PiecewiseDefaultCurveTestCase(unittest.TestCase):

    def test_create_piecewise(self):

        todays_date, helper = create_helper()

        for trait in ['HazardRate', 'DefaultDensity', 'SurvivalProbability']:
            for interpolator in ['Linear', 'LogLinear', 'BackwardFlat']:
                curve = PiecewiseDefaultCurve(
                    trait,
                    interpolator,
                    reference_date=todays_date,
                    helpers=[helper],
                    daycounter=Actual365Fixed()
                )

                self.assertIsNotNone(curve)


if __name__ == '__main__':
    unittest.main()

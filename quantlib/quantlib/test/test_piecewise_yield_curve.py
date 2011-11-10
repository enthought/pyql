import unittest

from quantlib.termstructures.yields.piecewise_yield_curve import \
    PiecewiseYieldCurve

class PiecewiseYieldCurveTestCase(unittest.TestCase):

    def test_creation(self):

        p = PiecewiseYieldCurve()

        self.fail('expose the term structure factory, implemente RateHelpers.')


if __name__ == '__main__':
    unittest.main()

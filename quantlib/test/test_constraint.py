from .unittest_tools import unittest

from quantlib.math.hestonhwcorrelationconstraint import (
    HestonHullWhiteCorrelationConstraint)

from quantlib.math.array import qlarray_from_pyarray


class TestConstraint(unittest.TestCase):

    def test_1(self):
        c = HestonHullWhiteCorrelationConstraint(-0.5)

        # Heston parameter p[3] is correlation

        p = qlarray_from_pyarray([1, 1, 1, 0.5, 1])

        res = c.test(p)

        self.assertEquals(res, True)

if __name__ == '__main__':
    unittest.main()

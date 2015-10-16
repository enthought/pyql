from .unittest_tools import unittest

from quantlib.math.hestonhwcorrelationconstraint import (
    HestonHullWhiteCorrelationConstraint)

from quantlib.math.array import qlarray_from_pyarray


class TestConstraint(unittest.TestCase):

    def test_1(self):
        c = HestonHullWhiteCorrelationConstraint(-0.5)

        # dummy Heston parameters p[3] is heston correlation

        p = qlarray_from_pyarray([1, 1, 1, 0.5, 1])
        print("p[3]: %f" % p[3])

        res = c.test(p)

        self.assertEquals(res, True)

if __name__ == '__main__':
    unittest.main()

import unittest

import numpy as np
from quantlib.math.randomnumbers.rngtraits import LowDiscrepancy
from quantlib.math.randomnumbers.sobol_rsg import SobolRsg, DirectionIntegers


class SobolRsgTestCase(unittest.TestCase):
    def test_skip(self):
        g1 = SobolRsg(10)
        g2 = SobolRsg(10)
        g2.skip_to(1000)
        i = 0
        while i <= 1000:
            s = next(g1)
            i += 1
        self.assertEqual(s, next(g2))

    def test_direction_integers(self):
        samples = 10000
        for di in DirectionIntegers:
            g = SobolRsg(10, direction_integers=di)
            X = np.empty((samples, 10))
            for i in range(samples):
                X[i] = next(g)
            C = np.corrcoef(X.T)
            self.assertAlmostEqual(
                np.linalg.norm(X.mean(axis=0) - 0.5 * np.ones(10)), 0., 2)
            self.assertAlmostEqual(np.linalg.norm(C - np.eye(10)), 0., 1)

class LowDiscrepancyTestCase(unittest.TestCase):
    def setUp(self):
        self.g = LowDiscrepancy(10, 0)

    def test_dimension(self):
        self.assertEqual(self.g.dimension, 10)

    def test_mean_variance(self):
        samples = 100000
        X = np.empty((samples, self.g.dimension))
        for i in range(samples):
            _, X[i] = next(self.g)
        C = np.cov(X.T)
        self.assertAlmostEqual(np.linalg.norm(X.mean(axis=0)), 0., 3)
        self.assertAlmostEqual(np.linalg.norm(C - np.eye(10)), 0., 2)

if __name__ == "__main__":
    unittest.main()

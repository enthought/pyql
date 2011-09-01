import unittest

from quantlib.index import Index
from quantlib.indexes.interest_rate_index import InterestRateIndex

class TestIndex(unittest.TestCase):

    def test_create_index(self):

        with self.assertRaises(ValueError):
            index = Index()

class TestIRIndex(unittest.TestCase):

    def test_create_index(self):

        with self.assertRaises(ValueError):
            index = InterestRateIndex()


if __name__ == '__main__':
    unittest.main()

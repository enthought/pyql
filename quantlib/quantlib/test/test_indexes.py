"""
 Copyright (C) 2011, Enthought Inc
 Copyright (C) 2011, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

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

class TestLibor(unittest.TestCase):

    # TODO
    def test_create_index(self):
        index = 2
        
if __name__ == '__main__':
    unittest.main()

"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from .unittest_tools import unittest

from quantlib.indexes.inflation_index import AUCPI
from quantlib.time.date import Monthly, Months, Period

class TestInflationIndex(unittest.TestCase):

    def test_zero_index(self):

        aucpi = AUCPI(Monthly, True, True)

        self.assertEqual(aucpi.name, "Australia CPI")

        self.assertEqual(aucpi.frequency, Monthly)

        self.assertEqual(aucpi.availabilityLag, Period(2, Months))


if __name__ == '__main__':
    unittest.main()

"""
 Copyright (C) 2016, Enthought Inc
 Copyright (C) 2016, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from .unittest_tools import unittest

from quantlib.indexes import Region, CustomRegion, USRegion


class TestRegion(unittest.TestCase):

    def test_custom_region(self):
        re = CustomRegion('Africa', 'AF')
        self.assertEqual(re.name, 'Africa')

    def test_from_name(self):
        re_1 = Region.from_name('US')
        re_2 = USRegion()
        self.assertEqual(re_1.name, re_2.name)
        self.assertIsInstance(re_1, USRegion)

if __name__ == '__main__':
    unittest.main()

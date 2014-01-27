from .unittest_tools import unittest

from quantlib.time.calendar import (
    Following, Preceding)

from quantlib.time.businessdayconvention import BusinessDayConvention


class TestBusinessDayConvention(unittest.TestCase):

    def test_creation(self):

        b = BusinessDayConvention.from_name('Following')

        self.assertEquals(str(b), 'Following')
        self.assertEquals(b, Following)

        c = BusinessDayConvention(Preceding)
        self.assertEquals(c, Preceding)


if __name__ == '__main__':
    unittest.main()

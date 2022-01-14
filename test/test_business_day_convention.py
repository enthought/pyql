import unittest

from quantlib.time.businessdayconvention import (
    Following, Preceding)

from quantlib.time.businessdayconvention import BusinessDayConvention


class TestBusinessDayConvention(unittest.TestCase):

    def test_creation(self):

        b = BusinessDayConvention.from_name('Following')

        self.assertEqual(str(b), 'Following')
        self.assertEqual(b, Following)

        c = BusinessDayConvention(Preceding)
        self.assertEqual(c, Preceding)


if __name__ == '__main__':
    unittest.main()

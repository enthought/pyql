from .unittest_tools import unittest


from quantlib.math.array import Array, qlarray_from_pyarray


class TestMath(unittest.TestCase):

    def test_array_1(self):
        v = 3.14
        x = Array(10, v)

        self.assertEqual(x[4], v)
        self.assertEqual(x.size, 10)

    def test_array_2(self):
        v = 3.14
        x = Array(10, v)
        x[4] = 2*v
        self.assertEqual(x[4], 2*v)

    def test_array_out_of_bounds(self):
        v = 3.14
        x = Array(10, v)
        with self.assertRaises(ValueError):
            x[12] = 2*v

    def test_array_conversion(self):
        p = [1,2,3,4]
        x = qlarray_from_pyarray(p)
        self.assertEqual(x[2], p[2])


if __name__ == '__main__':
    unittest.main()

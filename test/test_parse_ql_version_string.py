import unittest

from quantlib.util.version import parse_ql_version_string


class TestParseQlVersionString(unittest.TestCase):

    def test_match_valid(self):

        version = parse_ql_version_string("1.2")
        self.assertEqual(version, (1, 2, None, None))
        version = parse_ql_version_string("1.2.3")
        self.assertEqual(version, (1, 2, 3, None))
        version = parse_ql_version_string("1.2.3-rc4")
        self.assertEqual(version, (1, 2, 3, 'rc4'))
        version = parse_ql_version_string("1.2-rc4")
        self.assertEqual(version, (1, 2, None, 'rc4'))

    def test_match_invalid(self):

        with self.assertRaises(ValueError):
            parse_ql_version_string("1")
        with self.assertRaises(ValueError):
            parse_ql_version_string("1-rc2")
        with self.assertRaises(ValueError):
            parse_ql_version_string("1.2.3.4.5")

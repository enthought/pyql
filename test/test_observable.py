import unittest
from quantlib.quotes import SimpleQuote
from quantlib.observable import Observer
from quantlib.settings import Settings
from quantlib.time.api import Date

class SimpleObserverTestCase(unittest.TestCase):
    def setUp(self):
        self.count = 0

    def test_quote_observability(self):
        self.count = 0
        q = SimpleQuote(0.1)

        def counter():
            self.count += 1

        obs = Observer(counter)
        obs.register_with(q)
        self.assertEqual(self.count, 0)
        q.value = 0.2
        self.assertEqual(self.count, 1)
        q.value = 0.3
        self.assertEqual(self.count, 2)
        obs.unregister_with(q)
        q.value = 0.4
        self.assertEqual(self.count, 2)

    def test_settings_observability(self):
        self.count = 0
        def counter():
            self.count += 1
        obs = Observer(counter)
        obs.register_with(Settings().observable_evaluation_date)

        self.assertEqual(self.count, 0)
        with Settings() as settings:
            settings.evaluation_date = Date(1, 1, 2018)
            self.assertEqual(self.count, 1)
        self.assertEqual(self.count, 2)

if __name__ == "__main__":
    unittest.main()

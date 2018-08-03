import unittest
from quantlib.quotes import SimpleQuote
from quantlib.observable import Observer


class SimpleObserverTestCase(unittest.TestCase):
    def setUp(self):
        self.count = 0

    def test_observability(self):
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

if __name__ == "__main__":
    unittest.main()

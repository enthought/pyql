import datetime
import unittest

from quantlib.time.date import today
from quantlib.settings import Settings

class SettingsTestCase(unittest.TestCase):

    def test_using_settings(self):

        settings = Settings()

        evaluation_date = today()

        # have to set the evaluation date before the test as it is a global
        # attribute for the whole library ... meaning that previous test_cases
        # might have set this to another date
        settings.evaluation_date = evaluation_date

        self.assertTrue(
            evaluation_date == settings.evaluation_date
        )

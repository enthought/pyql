import unittest

from quantlib.time.calendar_registry import (
   initialize_code_registry, calendar_from_name
)
from quantlib.time.calendars.target import TARGET
from quantlib.time.calendars.united_states import UnitedStates

class CalendarRegistryTestCase(unittest.TestCase):

    def test_basic_usage(self):
        registry = initialize_code_registry()
        calendar = registry.from_name('TARGET')
        self.assertIsInstance(calendar, TARGET)

    def test_calendar_from_name_function(self):
        calendar = calendar_from_name('USA-GVT-BONDS')
        self.assertIsInstance(calendar, UnitedStates)
        self.assertIn('US government bond market', calendar.name)

    def test_help(self):
         registry = initialize_code_registry()

         content = registry.help()

         self.assertIsNotNone(content)

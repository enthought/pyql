from quantlib.test.unittest_tools import unittest

from quantlib.time.calendar_registry import (
    CalendarRegistry, calendar_from_name
)
from quantlib.time.calendar import TARGET
from quantlib.time.calendars.united_states import UnitedStates

class CalendarRegistryTestCase(unittest.TestCase):
    
    def test_basic_usage(self):
        registry = CalendarRegistry()
        calendar = registry.from_name('TARGET')
        self.assertIsInstance(calendar, TARGET)
        
    def test_calendar_from_name_function(self):
        calendar = calendar_from_name('USA-GVT-BONDS')
        self.assertIsInstance(calendar, UnitedStates)
        self.assertIn('US government bond market', calendar.name)
        
        
    def test_help(self):
        
         registry = CalendarRegistry()
         registry._initialize()
         
         content = registry.help()
         
         print content
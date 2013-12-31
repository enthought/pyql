from .unittest_tools import unittest

from quantlib.instruments.swap import VanillaSwap, Payer

from quantlib.pricingengines.swap import DiscountingSwapEngine
from quantlib.time.calendar import (
    Unadjusted, ModifiedFollowing, Following
)

from quantlib.compounding import Compounded, Continuous
from quantlib.time.date import (
    Date, Days, Semiannual, January, August, Period, March, February,
    Jul, Annual, Years, Months)

from quantlib.time.api import Actual365Fixed, Thirty360, TARGET, Actual360
from quantlib.time.schedule import Schedule, Backward, Forward
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure)

from quantlib.indexes.euribor import Euribor6M

from quantlib.time.date import Date

from quantlib.currency import USDCurrency
from quantlib.indexes.libor import Libor


def makeSwap(settlement, length, fixedRate, floatingSpread,
             termStructure):

    swap_type = Payer
    nominal = 100.0
    fixedConvention = Unadjusted
    floatingConvention = ModifiedFollowing
    fixedFrequency = Annual
    floatingFrequency = Semiannual
    fixedDayCount = Thirty360()
    floatDayCount = Thirty360()
    calendar = TARGET()
    settlement_days = 2

    index = Libor('USD Libor', Period(6, Months), settlement_days,
                   USDCurrency(), calendar, Actual360(),
                  termStructure)

    maturity = calendar.advance(settlement, length, Years,
                                convention=floatingConvention)

    fixedSchedule = Schedule(settlement, maturity, Period(fixedFrequency),
                            calendar, fixedConvention, fixedConvention,
                            Forward, False)

    floatSchedule = Schedule(settlement, maturity,
                                   Period(floatingFrequency),
                                   calendar, floatingConvention,
                                   floatingConvention,
                                   Forward, False)

    swap = VanillaSwap(swap_type, nominal, fixedSchedule, fixedRate,
                       fixedDayCount,
                       floatSchedule, index, floatingSpread,
                       floatDayCount, fixedConvention)

    engine = DiscountingSwapEngine(termStructure,
                                   False,
                                   settlement, settlement)
    swap.set_pricing_engine(engine)

    return swap


class TestQuantLibSwap(unittest.TestCase):

    def test_swap_fair_rate(self):
        """
        Test that a swap with fixed coupon = fair rate has an NPV=0
        """

        today = Date(02, January, 2014)
        settings = Settings()
        settings.evaluation_date = today

        settlement = Date(06, January, 2014)

        termStructure = YieldTermStructure(relinkable=True)
        termStructure.link_to(FlatForward(settlement, 0.05, Actual365Fixed()))

        length = 5
        fixedRate = .05
        floatingSpread = 0.0

        swap = makeSwap(settlement, length, fixedRate, floatingSpread,
             termStructure)

        f = swap.fairRate

        swap = makeSwap(settlement, length, f, floatingSpread,
             termStructure)

        p = swap.net_present_value

        self.assertAlmostEquals(p, 0)

if __name__ == '__main__':
    unittest.main()

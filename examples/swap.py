""" Port of the swap example of QuantLib SWIG to PyQL.

Warning: this is work in progress and currently not working.
"""
from quantlib.indexes.api import Euribor6M
from quantlib.math.interpolation import LogLinear
from quantlib.instruments.api import VanillaSwap
from quantlib.pricingengines.swap import DiscountingSwapEngine
from quantlib.settings import Settings
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.api import DepositRateHelper, FraRateHelper
from quantlib.termstructures.yields.api import FuturesRateHelper, SwapRateHelper
from quantlib.termstructures.yields.api import HandleYieldTermStructure
from quantlib.termstructures.yields.api import (
    PiecewiseYieldCurve, BootstrapTrait )
from quantlib.time.api import Actual360, Date, November, TARGET, Weeks, Annual
from quantlib.time.api import Months, Years, Period, ModifiedFollowing
from quantlib.time.api import Unadjusted, Thirty360, Semiannual, Schedule
from quantlib.time.api import ActualActual, ISDA, DateGeneration
# global data
calendar = TARGET()
todaysDate = Date(6,November,2001);
Settings.instance().evaluation_date = todaysDate
settlementDate = Date(8,November,2001);

# market quotes
deposits = { (1,Weeks): 0.0382,
             (1,Months): 0.0372,
             (3,Months): 0.0363,
             (6,Months): 0.0353,
             (9,Months): 0.0348,
             (1,Years): 0.0345 }

FRAs = { (3,6): 0.037125,
         (6,9): 0.037125,
         (9,12): 0.037125 }

futures = { Date(19,12,2001): 96.2875,
            Date(20,3,2002): 96.7875,
            Date(19,6,2002): 96.9875,
            Date(18,9,2002): 96.6875,
            Date(18,12,2002): 96.4875,
            Date(19,3,2003): 96.3875,
            Date(18,6,2003): 96.2875,
            Date(17,9,2003): 96.0875 }

swaps = { (2,Years): 0.037125,
          (3,Years): 0.0398,
          (5,Years): 0.0443,
          (10,Years): 0.05165,
          (15,Years): 0.055175 }

# convert them to Quote objects
#for n,unit in deposits.keys():
#    deposits[(n,unit)] = SimpleQuote(deposits[(n,unit)])
for n,m in FRAs.keys():
    FRAs[(n,m)] = SimpleQuote(FRAs[(n,m)])
for d in futures.keys():
    futures[d] = SimpleQuote(futures[d])
for s in swaps.keys():
    swaps[s] = SimpleQuote(swaps[s])
#for n,unit in swaps.keys():
#    swaps[(n,unit)] = SimpleQuote(swaps[(n,unit)])

# build rate helpers

day_counter = Actual360()
settlementDays = 2
depositHelpers = [ DepositRateHelper(v,
                                     Period(n,unit), settlementDays,
                                     calendar, ModifiedFollowing,
                                     False, day_counter)
                   for (n, unit), v in deposits.items()]

day_counter = Actual360()
settlementDays = 2
fraHelpers = [ FraRateHelper(v,
                             n, m, settlementDays,
                             calendar, ModifiedFollowing,
                             False, day_counter)
               for (n, m), v in FRAs.items() ]

day_counter = Actual360()
months = 3
futuresHelpers = [ FuturesRateHelper(futures[d],
                                     d, months,
                                     calendar, ModifiedFollowing,
                                     True, day_counter)
                   for d in futures.keys() ]

settlementDays = 2
fixedLegFrequency = Annual
fixedLegTenor = Period(1,Years)
fixedLegAdjustment = Unadjusted
fixedLegDayCounter = Thirty360()
floatingLegFrequency = Semiannual
floatingLegTenor = Period(6,Months)
floatingLegAdjustment = ModifiedFollowing
swapHelpers = [ SwapRateHelper.from_tenor(swaps[(n,unit)],
                               Period(n,unit), calendar,
                               fixedLegFrequency, fixedLegAdjustment,
                               fixedLegDayCounter, Euribor6M())
                for n, unit in swaps.keys() ]

### Curve building

ts_daycounter = ActualActual(ISDA)

# term-structure construction
helpers = depositHelpers + swapHelpers
depoSwapCurve = PiecewiseYieldCurve[BootstrapTrait.Discount, LogLinear].from_reference_date(
    settlementDate, helpers, ts_daycounter
)

helpers = depositHelpers[:2] + futuresHelpers + swapHelpers[1:]
depoFuturesSwapCurve = PiecewiseYieldCurve[BootstrapTrait.Discount, LogLinear].from_reference_date(
    settlementDate, helpers, ts_daycounter
)

helpers = depositHelpers[:3] + fraHelpers + swapHelpers
depoFraSwapCurve = PiecewiseYieldCurve[BootstrapTrait.Discount, LogLinear].from_reference_date(
    settlementDate, helpers, ts_daycounter
)


# Term structures that will be used for pricing:
discountTermStructure = HandleYieldTermStructure()
forecastTermStructure = HandleYieldTermStructure()

### SWAPS TO BE PRICED


nominal = 1000000
length = 5
maturity = calendar.advance(settlementDate,length,Years)
payFixed = True

fixedLegFrequency = Annual
fixedLegAdjustment = Unadjusted
fixedLegDayCounter = Thirty360()
fixedRate = 0.04

floatingLegFrequency = Semiannual
spread = 0.0
fixingDays = 2
index = Euribor6M(forecastTermStructure)
floatingLegAdjustment = ModifiedFollowing
floatingLegDayCounter = index.day_counter

fixedSchedule = Schedule.from_rule(settlementDate, maturity,
                         fixedLegTenor, calendar,
                         fixedLegAdjustment, fixedLegAdjustment,
                         DateGeneration.Forward, False)
floatingSchedule = Schedule.from_rule(settlementDate, maturity,
                            floatingLegTenor, calendar,
                            floatingLegAdjustment, floatingLegAdjustment,
                            DateGeneration.Forward, False)
swapEngine = DiscountingSwapEngine(discountTermStructure)

spot = VanillaSwap(VanillaSwap.Payer, nominal,
                   fixedSchedule, fixedRate, fixedLegDayCounter,
                   floatingSchedule, index, spread,
                   floatingLegDayCounter)
spot.set_pricing_engine(swapEngine)

forwardStart = calendar.advance(settlementDate,1,Years)
forwardEnd = calendar.advance(forwardStart,length,Years)
fixedSchedule = Schedule.from_rule(forwardStart, forwardEnd,
                         fixedLegTenor, calendar,
                         fixedLegAdjustment, fixedLegAdjustment,
                         DateGeneration.Forward, False)
floatingSchedule = Schedule.from_rule(forwardStart, forwardEnd,
                            floatingLegTenor, calendar,
                            floatingLegAdjustment, floatingLegAdjustment,
                            DateGeneration.Forward, False)

forward = VanillaSwap(VanillaSwap.Payer, nominal,
                      fixedSchedule, fixedRate, fixedLegDayCounter,
                      floatingSchedule, index, spread,
                      floatingLegDayCounter)


forward.set_pricing_engine(swapEngine)

# price on the bootstrapped curves

def formatPrice(p, digits=2):
    format = '%%.%df' % digits
    return format % p

def formatRate(r, digits=2):
    format = '%%.%df %%%%' % digits
    if isinstance(r, SimpleQuote):
        r = r.value
    return format % (r * 100)

headers = ("term structure", "net present value",
           "fair spread", "fair fixed rate" )
separator = " | "

format = ''
width = 0
for h in headers[:-1]:
    format += '%%%ds' % len(h)
    format += separator
    width += len(h) + len(separator)
format += '%%%ds' % len(headers[-1])
width += len(headers[-1])

rule = "-" * width
dblrule = "=" * width
tab = " " * 8

def report(swap, name):
    print(format % (name, formatPrice(swap.npv,2),
                    formatRate(swap.fair_spread,4),
                    formatRate(swap.fair_rate,4)))

print(dblrule)
print("5-year market swap-rate = %s" % formatRate(swaps[(5,Years)]))
print(dblrule)

# price on two different term structures

print(tab + "5-years swap paying %s" % formatRate(fixedRate))
print(separator.join(headers))
print(rule)

discountTermStructure.link_to(depoFuturesSwapCurve)
forecastTermStructure.link_to(depoFuturesSwapCurve)
report(spot,'depo-fut-swap')

discountTermStructure.link_to(depoFraSwapCurve)
forecastTermStructure.link_to(depoFraSwapCurve)
report(spot,'depo-FRA-swap')

print(rule)

# price the 1-year forward swap

print(tab + "5-years, 1-year forward swap paying %s" % formatRate(fixedRate))
print(rule)

discountTermStructure.link_to(depoFuturesSwapCurve)
forecastTermStructure.link_to(depoFuturesSwapCurve)
report(forward,'depo-fut-swap')

discountTermStructure.link_to(depoFraSwapCurve)
forecastTermStructure.link_to(depoFraSwapCurve)
report(forward,'depo-FRA-swap')

# modify the 5-years swap rate and reprice

swaps[(5,Years)].value = 0.046

print(dblrule)
print("5-year market swap-rate = %s" % formatRate(swaps[(5,Years)]))
print(dblrule)

print(tab + "5-years swap paying %s" % formatRate(fixedRate))
print(separator.join(headers))
print(rule)

discountTermStructure.link_to(depoFuturesSwapCurve)
forecastTermStructure.link_to(depoFuturesSwapCurve)
report(spot,'depo-fut-swap')

discountTermStructure.link_to(depoFraSwapCurve)
forecastTermStructure.link_to(depoFraSwapCurve)
report(spot,'depo-FRA-swap')

print(rule)

print(tab + "5-years, 1-year forward swap paying %s" % formatRate(fixedRate))
print(rule)

discountTermStructure.link_to(depoFuturesSwapCurve)
forecastTermStructure.link_to(depoFuturesSwapCurve)
report(forward,'depo-fut-swap')

discountTermStructure.link_to(depoFraSwapCurve)
forecastTermStructure.link_to(depoFraSwapCurve)
report(forward,'depo-FRA-swap')

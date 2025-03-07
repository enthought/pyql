from tabulate import tabulate
from quantlib.time.api import (TARGET, Date, Weeks, Days, Months, Years,
                               Actual360, Actual365Fixed, Following, Annual, Unadjusted, Thirty360, Schedule, ModifiedFollowing, Semiannual, Period, DateGeneration)
from quantlib.time.daycounters.thirty360 import European
from quantlib.settings import Settings
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.rate_helpers import DepositRateHelper, FraRateHelper, SwapRateHelper
from quantlib.termstructures.yields.ois_rate_helper import OISRateHelper
from quantlib.termstructures.yields.piecewise_yield_curve import PiecewiseYieldCurve
from quantlib.termstructures.yields.bootstraptraits import Discount
from quantlib.termstructures.yields.api import HandleYieldTermStructure
from quantlib.math.interpolation import Cubic
from quantlib.indexes.ibor.eonia import Eonia
from quantlib.indexes.api import Euribor6M
from quantlib.instruments.swap import Swap
from quantlib.instruments.vanillaswap import VanillaSwap
from quantlib.pricingengines.swap import DiscountingSwapEngine

calendar = TARGET()
todays_date = Date(11, 12, 2012)
Settings().evaluation_date = todays_date

fixing_days = 2
settlement_date = calendar.advance(todays_date, fixing_days, Days)
settlement_date = calendar.adjust(settlement_date)

# deposits
dONRate = SimpleQuote(0.0004)
dTNRate = SimpleQuote(0.0004)
dSNRate = SimpleQuote(0.0004)

# OIS
ois1WRate = SimpleQuote(0.00070)
ois2WRate = SimpleQuote(0.00069)
ois3WRate = SimpleQuote(0.00078)
ois1MRate = SimpleQuote(0.00074)

# Dated OIS
oisDated1Rate = SimpleQuote( 0.000460)
oisDated2Rate = SimpleQuote( 0.000160)
oisDated3Rate = SimpleQuote(-0.000070)
oisDated4Rate = SimpleQuote(-0.000130)
oisDated5Rate = SimpleQuote(-0.000140)

# OIS
ois15MRate = SimpleQuote(0.00002)
ois18MRate = SimpleQuote(0.00008)
ois21MRate = SimpleQuote(0.00021)
ois2YRate = SimpleQuote(0.00036)
ois3YRate = SimpleQuote(0.00127)
ois4YRate = SimpleQuote(0.00274)
ois5YRate = SimpleQuote(0.00456)
ois6YRate = SimpleQuote(0.00647)
ois7YRate = SimpleQuote(0.00827)
ois8YRate = SimpleQuote(0.00996)
ois9YRate = SimpleQuote(0.01147)
ois10YRate = SimpleQuote(0.0128)
ois11YRate = SimpleQuote(0.01404)
ois12YRate = SimpleQuote(0.01516)
ois15YRate = SimpleQuote(0.01764)
ois20YRate = SimpleQuote(0.01939)
ois25YRate = SimpleQuote(0.02003)
ois30YRate = SimpleQuote(0.02038)


#/*********************
 # ***  RATE HELPERS ***
 # *********************/

# RateHelpers are built from the above quotes together with
# other instrument dependant infos.  Quotes are passed in
# relinkable handles which could be relinked to some other
# data source later.

# deposits
depositDayCounter = Actual360()

dON = DepositRateHelper(dONRate,
            1 * Days, 0,
            calendar, Following,
            False, depositDayCounter)
dTN = DepositRateHelper(dTNRate,
            1 * Days, 1,
            calendar, Following,
            False, depositDayCounter)
dSN = DepositRateHelper(dSNRate,
            1 * Days, 2,
            calendar, Following,
            False, depositDayCounter)

# OIS
eonia = Eonia()

ois1W = OISRateHelper(
            2, 1 * Weeks,
            ois1WRate, eonia)
ois2W = OISRateHelper(
            2, 2 * Weeks,
            ois2WRate, eonia)
ois3W = OISRateHelper(
            2, 3 * Weeks,
            ois3WRate, eonia)
ois1M = OISRateHelper(
            2, 1 * Months,
            ois1MRate, eonia)


# Dated OIS
oisDated1 = OISRateHelper.from_dates(
        Date(16, 1, 2013), Date(13, 2, 2013),
        oisDated1Rate, eonia)
oisDated2 = OISRateHelper.from_dates(
    Date(13, 2, 2013), Date(13, 3, 2013),
    oisDated2Rate, eonia)
oisDated3 = OISRateHelper.from_dates(
    Date(13, 3, 2013), Date(10, 4, 2013),
    oisDated3Rate, eonia)
oisDated4 = OISRateHelper.from_dates(
    Date(10, 4, 2013), Date(8, 5, 2013),
    oisDated4Rate, eonia)
oisDated5 = OISRateHelper.from_dates(
    Date(8, 5, 2013), Date(12, 6, 2013),
    oisDated5Rate, eonia)

# OIS
ois15M = OISRateHelper(2, 15*Months, ois15MRate, eonia)
ois18M = OISRateHelper(2, 18*Months, ois18MRate, eonia)
ois21M = OISRateHelper(2, 21*Months, ois21MRate, eonia)
ois2Y = OISRateHelper(2, 2*Years, ois2YRate, eonia)
ois3Y = OISRateHelper(2, 3*Years, ois3YRate, eonia)
ois4Y = OISRateHelper(2, 4*Years, ois4YRate, eonia)
ois5Y = OISRateHelper(2, 5*Years, ois5YRate, eonia)
ois6Y = OISRateHelper(2, 6*Years, ois6YRate, eonia)
ois7Y = OISRateHelper(2, 7*Years, ois7YRate, eonia)
ois8Y = OISRateHelper(2, 8*Years, ois8YRate, eonia)
ois9Y = OISRateHelper(2, 9*Years, ois9YRate, eonia)
ois10Y = OISRateHelper(2, 10*Years, ois10YRate, eonia)
ois11Y = OISRateHelper(2, 11*Years, ois11YRate, eonia)
ois12Y = OISRateHelper(2, 12*Years, ois12YRate, eonia)
ois15Y = OISRateHelper(2, 15*Years, ois15YRate, eonia)
ois20Y = OISRateHelper(2, 20*Years, ois20YRate, eonia)
ois25Y = OISRateHelper(2, 25*Years, ois25YRate, eonia)
ois30Y = OISRateHelper(2, 30*Years, ois30YRate, eonia)

# /*********************
# **  CURVE BUILDING **
# *********************/

# /*********************
# **   EONIA CURVE    **
# *********************/

termStructureDayCounter = Actual365Fixed()

# Eonia curve
eonia_instruments = [dON, dTN, dSN, ois1W, ois2W, ois3W, ois1M, oisDated1, oisDated2, oisDated3,
        oisDated4, oisDated5, ois15M, ois18M, ois21M, ois2Y, ois3Y, ois4Y, ois5Y, ois6Y,
        ois7Y, ois8Y, ois9Y, ois10Y, ois11Y, ois12Y, ois15Y, ois20Y, ois25Y, ois30Y]

eonia_term_structure = PiecewiseYieldCurve[Discount, Cubic].from_reference_date(todays_date, eonia_instruments,
                                                                                termStructureDayCounter)

eonia_term_structure.extrapolation = True


# Term structures that will be used for pricing:
# the one used for discounting cash flows
discountingTermStructure = HandleYieldTermStructure()
# the one used for forward rate forecasting
forecastingTermStructure = HandleYieldTermStructure()

discountingTermStructure.link_to(eonia_term_structure)


# /*********************
# **    EURIBOR 6M    **
# *********************/
euribor6M = Euribor6M()

# deposits
d6MRate = SimpleQuote(0.00312)

# FRAs
fra_rates = [0.002930, 0.002720, 0.002600, 0.002560, 0.002520, 0.002480, 0.002540, 0.002610,
             0.002670, 0.002790, 0.002910, 0.003030, 0.003180, 0.003350, 0.003520, 0.003710,
             0.003890, 0.004090]
fra_periods = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
#swaps
swap_rates = [0.00424, 0.00576, 0.00762, 0.00954, 0.011350, 0.014520, 0.015840,
              0.018090, 0.020370, 0.021870, 0.022340, 0.022560, 0.022950, 0.023480,
              0.024210, 0.02463 ]
swap_periods = [3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 25, 30, 35, 40, 50, 60]
swap_quotes = {p * Years: SimpleQuote(r) for r, p in zip(swap_rates, swap_periods)}

d6M = DepositRateHelper(
    d6MRate,
    6 * Months, 3,
    calendar, Following,
    False, depositDayCounter)

fras = [FraRateHelper.from_index(r, p, euribor6M) for r, p in zip(fra_rates, fra_periods)]

# setup swaps

swFixedLegFrequency = Annual
swFixedLegConvention = Unadjusted
swFixedLegDayCounter = Thirty360(European)

swFloatingLegIndex = Euribor6M()
swaps = [SwapRateHelper.from_tenor(r, p, calendar, swFixedLegFrequency,
                                   swFixedLegConvention, swFixedLegDayCounter,
                                   swFloatingLegIndex, discounting_curve=discountingTermStructure) for p, r in swap_quotes.items()]



# // Euribor 6M curve
euribor6MInstruments = [d6M] + fras + swaps
# // If needed, it's possible to change the tolerance; the default is 1.0e-12.
tolerance = 1.0e-15;

# // The tolerance is passed in an explicit bootstrap object. Depending on
# // the bootstrap algorithm, it's possible to pass other parameters.
euribor6MTermStructure = PiecewiseYieldCurve[Discount, Cubic].from_reference_date(
    settlement_date, euribor6MInstruments,
    termStructureDayCounter,
    accuracy=tolerance)
forecastingTermStructure.link_to(euribor6MTermStructure)


# /*********************
# * SWAPS TO BE PRICED *
# **********************/

# // constant nominal 1,000,000 Euro
nominal = 1000000.0
# // fixed leg
fixedLegFrequency = Annual
fixedLegConvention = Unadjusted
floatingLegConvention = ModifiedFollowing
fixedLegDayCounter = Thirty360(European)
fixedRate = 0.007
floatingLegDayCounter = Actual360()

# // floating leg
floatingLegFrequency = Semiannual
euriborIndex = Euribor6M(forecastingTermStructure)
spread = 0.0

lengthInYears = 5
swapType = Swap.Payer

maturity = settlement_date + lengthInYears*Years;
fixedSchedule = Schedule.from_rule(settlement_date, maturity,
                                   Period(fixedLegFrequency),
                                   calendar, fixedLegConvention,
                                   fixedLegConvention,
                                   DateGeneration.Forward, False)
floatSchedule = Schedule.from_rule(settlement_date, maturity,
                                   Period(floatingLegFrequency),
                                   calendar, floatingLegConvention,
                                   floatingLegConvention,
                                   DateGeneration.Forward, False)
spot5YearSwap = VanillaSwap(swapType, nominal,
                            fixedSchedule, fixedRate, fixedLegDayCounter,
                            floatSchedule, euriborIndex, spread,
                            floatingLegDayCounter)

fwdStart = calendar.advance(settlement_date, 1, Years)
fwdMaturity = fwdStart + lengthInYears*Years
fwdFixedSchedule = Schedule.from_rule(fwdStart, fwdMaturity,
                                      Period(fixedLegFrequency),
                                      calendar, fixedLegConvention,
                                      fixedLegConvention,
                                      DateGeneration.Forward, False)
fwdFloatSchedule = Schedule.from_rule(fwdStart, fwdMaturity,
                                      Period(floatingLegFrequency),
                                      calendar, floatingLegConvention,
                                      floatingLegConvention,
                                      DateGeneration.Forward, False)
oneYearForward5YearSwap = VanillaSwap(swapType, nominal,
                                      fwdFixedSchedule, fixedRate, fixedLegDayCounter,
                                      fwdFloatSchedule, euriborIndex, spread,
                                      floatingLegDayCounter)


# /***************
# * SWAP PRICING *
# ****************/


swapEngine = DiscountingSwapEngine(discountingTermStructure)

spot5YearSwap.set_pricing_engine(swapEngine)
oneYearForward5YearSwap.set_pricing_engine(swapEngine)

headers = ["", "net present value", "fair spread", "fair fixed rate"]

s5yRate = swap_quotes[5 * Years]
NPV = spot5YearSwap.npv
fairSpread = spot5YearSwap.fair_spread
fairRate = spot5YearSwap.fair_rate

vals1 = [f"5-years swap paying {fixedRate:.2%}", NPV, fairSpread, fairRate]

# now let's price the 1Y forward 5Y swap
NPV = oneYearForward5YearSwap.npv
fairSpread = oneYearForward5YearSwap.fair_spread
fairRate = oneYearForward5YearSwap.fair_rate

vals2 = [f"5-years, 1 year forward paying {fixedRate:.2%}", NPV, fairSpread, fairRate]
print(f"With 5-year market swap-rate = {s5yRate.value:.2%}")
print(tabulate([vals1, vals2], headers=headers, floatfmt=(None, ".2f", ".2%", ".2%"), tablefmt="fancy_grid"))

# now let's say that the 5-years swap rate goes up to 0.9%.
# A smarter market element--say, connected to a data source-- would
# notice the change itself. Since we're using SimpleQuotes,
# we'll have to change the value manually
s5yRate.value = 0.009
NPV = spot5YearSwap.npv
fairSpread = spot5YearSwap.fair_spread
fairRate = spot5YearSwap.fair_rate

vals1 = [f"5-years swap paying {fixedRate:.2%}", NPV, fairSpread, fairRate]

# now let's price the 1Y forward 5Y swap
NPV = oneYearForward5YearSwap.npv
fairSpread = oneYearForward5YearSwap.fair_spread
fairRate = oneYearForward5YearSwap.fair_rate

vals2 = [f"5-years, 1 year forward paying {fixedRate:.2%}", NPV, fairSpread, fairRate]
print()
print(f"With 5-year market swap-rate = {s5yRate.value:.2%}")
print(tabulate([vals1, vals2], headers=headers, floatfmt=(None, ".2f", ".2%", ".2%"), tablefmt="fancy_grid"))

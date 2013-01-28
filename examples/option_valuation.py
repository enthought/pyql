""" Option valuation example based on a C++ example from the QuantLib mailing list.

Expected  buggy results (see quantlib mailing list:

///////////////////////////  RESULTS
////////////////////////////////////////////////
Description of the option:        IBM Option
Date of maturity:                       January 26th, 2013
Type of the option:                   Call
Strike of the option:                  190
Discrete dividends
Dates                           Dividends
February 10th, 2012             0
May 10th, 2012                  0
August 10th, 2012               0
November 10th, 2012             0
NPV of the European Option with discrete dividends=0:           17.9647
NPV of the European Option without dividend:                     17.9647
NPV of the American Option with discrete dividends=0:   18.5707
NPV of the American Option without dividend:                    17.9647

"""

from quantlib.settings import Settings
from quantlib.compounding import Simple
from quantlib.currency import USDCurrency
from quantlib.indexes.libor import Libor
from quantlib.indexes.swap_index import SwapIndex
from quantlib.instruments.option import EuropeanExercise, AmericanExercise
from quantlib.instruments.option import VanillaOption, DividendVanillaOption
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.pricingengines.api import AnalyticDividendEuropeanEngine
from quantlib.pricingengines.api import FDDividendAmericanEngine
from quantlib.pricingengines.api import AnalyticEuropeanEngine
from quantlib.pricingengines.api import FDAmericanEngine
from quantlib.processes.black_scholes_process import BlackScholesProcess
from quantlib.quotes import SimpleQuote
from quantlib.time.api import (
    Date, Days, Period, Actual360, Months, Jan, ModifiedFollowing, Years, Feb
)
from quantlib.time.calendars.united_states import UnitedStates
from quantlib.termstructures.yields.api import (
    PiecewiseYieldCurve, DepositRateHelper
)
from quantlib.termstructures.volatility.equityfx.black_vol_term_structure import BlackConstantVol
from quantlib.termstructures.yields.api import SwapRateHelper

def dividendOption():
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # ++++++++++++++++++++ General Parameter for all the computation +++++++++++++++++++++++
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    # declaration of the today's date (date where the records are done)
    todaysDate = Date(24 , Jan ,2012)	# INPUT
    Settings.instance().evaluation_date = todaysDate #!\ IMPORTANT COMMAND REQUIRED FOR ALL VALUATIONS
    calendar = UnitedStates() # INPUT
    settlement_days	= 2	# INPUT
    # Calcul of the settlement date : need to add a period of 2 days to the todays date
    settlementDate =  calendar.advance(
        todaysDate, period=Period(settlement_days, Days)
    )
    dayCounter = Actual360() # INPUT
    currency = USDCurrency() # INPUT	

    print "Date of the evaluation:			", todaysDate
    print "Calendar used:         			", calendar.name()
    print "Number of settlement Days:		", settlement_days
    print "Date of settlement:       		", settlementDate
    print "Convention of day counter:		", dayCounter.name()
    print "Currency of the actual context:\t\t", currency.name

    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # ++++++++++++++++++++ Description of the underlying +++++++++++++++++++++++++++++++++++
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    underlying_name		= "IBM"
    underlying_price	= 191.75	# INPUT
    underlying_vol		= 0.2094	# INPUT

    print "**********************************"
    print "Name of the underlying:			", underlying_name
    print "Price of the underlying at t0:	", underlying_price
    print "Volatility of the underlying:		", underlying_vol

    # For a great managing of price and vol objects --> Handle
    underlying_priceH  = SimpleQuote(underlying_price)

    # We suppose the vol constant : his term structure is flat --> BlackConstantVol object
    flatVolTS = BlackConstantVol(settlementDate, calendar, underlying_vol, dayCounter)
    
    # ++++++++++++++++++++ Description of Yield Term Structure
    
    #  Libor data record 
    print "**********************************"
    print "Description of the Libor used for the Yield Curve construction" 
    
    Libor_dayCounter = Actual360();

    liborRates = []
    liborRatesTenor = []
    # INPUT : all the following data are input : the rate and the corresponding tenor
    #		You could make the choice of more or less data
    #		--> However you have tho choice the instruments with different maturities
    liborRates = [ 0.002763, 0.004082, 0.005601, 0.006390, 0.007125, 0.007928, 0.009446, 
            0.01110]
    liborRatesTenor = [Period(tenor, Months) for tenor in [1,2,3,4,5,6,9,12]]
    
    for tenor, rate in zip(liborRatesTenor, liborRates):
        print tenor, "\t\t\t", rate

    # Swap data record 

    # description of the fixed leg of the swap
    Swap_fixedLegTenor	= Period(12, Months) # INPUT
    Swap_fixedLegConvention = ModifiedFollowing # INPUT
    Swap_fixedLegDayCounter = Actual360() # INPUT
    # description of the float leg of the swap
    Swap_iborIndex =  Libor(
        "USDLibor", Period(3,Months), settlement_days, USDCurrency(),
        UnitedStates(), Actual360()
    )

    print "Description of the Swap used for the Yield Curve construction"
    print "Tenor of the fixed leg:			", Swap_fixedLegTenor
    print "Index of the floated leg: 		", Swap_iborIndex.name
    print "Maturity		Rate				"

    swapRates = []
    swapRatesTenor = []
    # INPUT : all the following data are input : the rate and the corresponding tenor
    #		You could make the choice of more or less data
    #		--> However you have tho choice the instruments with different maturities
    swapRates = [0.005681, 0.006970, 0.009310, 0.012010, 0.014628, 0.016881, 0.018745,
                 0.020260, 0.021545]
    swapRatesTenor = [Period(i, Years) for i in range(2, 11)]
    
    for tenor, rate in zip(swapRatesTenor, swapRates):
        print tenor, "\t\t\t", rate
    
    # ++++++++++++++++++++ Creation of the vector of RateHelper (need for the Yield Curve construction)
    # ++++++++++++++++++++ Libor 
    LiborFamilyName = currency.name + "Libor"
    instruments = []
    for rate, tenor in zip(liborRates, liborRatesTenor):
        # Index description ___ creation of a Libor index
        liborIndex =  Libor(LiborFamilyName, tenor, settlement_days, currency, calendar,
                Libor_dayCounter)
        # Initialize rate helper	___ the DepositRateHelper link the recording rate with the Libor index													
        instruments.append(DepositRateHelper(rate, index=liborIndex))

    # +++++++++++++++++++++ Swap
    SwapFamilyName = currency.name + "swapIndex";
    for tenor, rate in zip(swapRatesTenor, swapRates):
        # swap description ___ creation of a swap index. The floating leg is described in the index 'Swap_iborIndex'
        swapIndex = SwapIndex (SwapFamilyName, tenor, settlement_days, currency, calendar,
                Swap_fixedLegTenor, Swap_fixedLegConvention, Swap_fixedLegDayCounter,
                Swap_iborIndex)
        # Initialize rate helper __ the SwapRateHelper links the swap index width his rate
        instruments.append(SwapRateHelper.from_index(rate,swapIndex))
    
    # ++++++++++++++++++  Now the creation of the yield curve

    riskFreeTS = PiecewiseYieldCurve('zero', 'linear', settlementDate, instruments, dayCounter)


    # ++++++++++++++++++  build of the underlying process : with a Black-Scholes model 

    print 'Creating process'

    bsProcess = BlackScholesProcess(underlying_priceH, riskFreeTS, flatVolTS)


    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # ++++++++++++++++++++ Description of the option +++++++++++++++++++++++++++++++++++++++
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    Option_name = "IBM Option"
    maturity = Date(26, Jan,2013)
    strike = 190
    option_type = 'call'

    # Here, as an implementation exemple, we make the test with borth american and european exercise
    europeanExercise = EuropeanExercise(maturity)
    # The emericanExercise need also the settlement date, as his right to exerce the buy or call start at the settlement date!
    #americanExercise = AmericanExercise(settlementDate, maturity)
    americanExercise = AmericanExercise(maturity, settlementDate)
    
    print "**********************************"
    print "Description of the option:		", Option_name
    print "Date of maturity:     			", maturity
    print "Type of the option:   			", option_type
    print "Strike of the option:		    ", strike



    # ++++++++++++++++++ Description of the discrete dividends
    # INPUT You have to determine the frequece and rates of the discrete dividend. Here is a sollution, but she's not the only one.
    # Last know dividend:
    dividend			= 0.75 #//0.75
    next_dividend_date	= Date(10,Feb,2012)
    # HERE we have make the assumption that the dividend will grow with the quarterly croissance:
    dividendCroissance	= 1.03
    dividendfrequence	= Period(3, Months)
    dividendDates = []
    dividends = []


    d = next_dividend_date
    while d <= maturity:
        dividendDates.append(d)
        dividends.append(dividend)
        d = d + dividendfrequence
        dividend *= dividendCroissance

    print "Discrete dividends				"
    print "Dates				Dividends		"
    for date, div in zip(dividendDates, dividends):
        print date, "		", div

    # ++++++++++++++++++ Description of the final payoff 
    payoff = PlainVanillaPayoff(option_type, strike)

    # ++++++++++++++++++ The OPTIONS : (American and European) with their dividends description:
    dividendEuropeanOption = DividendVanillaOption(
        payoff, europeanExercise, dividendDates, dividends
    )
    dividendAmericanOption = DividendVanillaOption(
        payoff, americanExercise, dividendDates, dividends
    )


    # just too test
    europeanOption = VanillaOption(payoff, europeanExercise)
    americanOption =  VanillaOption(payoff, americanExercise)

    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # ++++++++++++++++++++ Description of the pricing  +++++++++++++++++++++++++++++++++++++
    # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    # For the european options we have a closed analytic formula: The Black Scholes:
    dividendEuropeanEngine = AnalyticDividendEuropeanEngine(bsProcess)

    # For the american option we have make the choice of the finite difference model with the CrankNicolson scheme
    #		this model need to precise the time and space step
    #		More they are greater, more the calul will be precise.
    americanGirdPoints = 600
    americanTimeSteps	= 600
    dividendAmericanEngine = FDDividendAmericanEngine('CrankNicolson', bsProcess,americanTimeSteps, americanGirdPoints)

    # just to test
    europeanEngine = AnalyticEuropeanEngine(bsProcess)
    americanEngine = FDAmericanEngine('CrankNicolson', bsProcess,americanTimeSteps, americanGirdPoints)


    # ++++++++++++++++++++ Valorisation ++++++++++++++++++++++++++++++++++++++++
        
    # Link the pricing Engine to the option
    dividendEuropeanOption.set_pricing_engine(dividendEuropeanEngine)
    dividendAmericanOption.set_pricing_engine(dividendAmericanEngine)
    
    # just	to test
    europeanOption.set_pricing_engine(europeanEngine)
    americanOption.set_pricing_engine(americanEngine)

    # Now we make all the needing calcul	
    # ... and final results
    print "NPV of the European Option with discrete dividends=0:	{:.4f}".format(dividendEuropeanOption.npv)
    print "NPV of the European Option without dividend:		{:.4f}".format(europeanOption.npv)
    print "NPV of the American Option with discrete dividends=0:	{:.4f}".format(dividendAmericanOption.npv)
    print "NPV of the American Option without dividend:		{:.4f}".format(americanOption.npv)
    # just a single test
    print "ZeroRate with a maturity at ", maturity, ": ", \
            riskFreeTS.zero_rate(maturity, dayCounter, Simple)



if __name__ == '__main__':

    dividendOption()


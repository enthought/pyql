import numpy as np
import pandas
import datetime
from datetime import date

from pandas import DataFrame

from quantlib.models.equity.heston_model import (
    HestonModelHelper, HestonModel)

from quantlib.pricingengines.vanilla import AnalyticHestonEngine
from quantlib.processes.heston_process import HestonProcess
from quantlib.settings import Settings
from quantlib.time.api import Period, Date, Actual365Fixed, ActualActual, TARGET, Days
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.zero_curve import ZeroCurve

from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import (
            Put, Call, EuropeanExercise, VanillaOption)

from quantlib.util.QL_converter import dateToQLDate, dfToZeroCurve

def heston_pricer(dtTrade, df_option, params, df_rates, spot):

    """
    price a list of European options with heston model
    """

    spot = SimpleQuote(spot)
        
    risk_free_ts = dfToZeroCurve(df_rates['iRate'], dtTrade)
    dividend_ts = dfToZeroCurve(df_rates['dRate'], dtTrade)

    process = HestonProcess(
        risk_free_ts, dividend_ts, spot, params['v0'], params['kappa'],
         params['theta'], params['sigma'], params['rho'])

    model = HestonModel(process)
    engine = AnalyticHestonEngine(model, 64)

    DtSettlement = dateToQLDate(dtTrade)
    
    settings = Settings()
    settings.evaluation_date = DtSettlement

    calendar = TARGET()

    model_value = np.zeros(len(df_option))
    daycounter = ActualActual()
    
    for index, row in df_option.T.iteritems():

        dtExpiry = row['dtExpiry']

        strike = row['Strike']

        cp = Call if row['Type'] == 'C' else Put

        payoff = PlainVanillaPayoff(cp, strike)

        dtExpiry = dateToQLDate(row['dtExpiry'])
        exercise = EuropeanExercise(dtExpiry)

        option = VanillaOption(payoff, exercise)

        option.set_pricing_engine(engine)
        
        model_value[index] = option.net_present_value
        
    df_final = DataFrame.filter(df_option, items=['dtExpiry', 'Strike', 'Type',
                                                  'Spot'])
    df_final['HestonPrice'] = model_value
    df_final['dtTrade'] = dtTrade

    return df_final

if __name__ == "__main__":

    dt_trade = date(2011,1,24)
    
    # option definition
    df_option = DataFrame({'Type': ['C', 'P'],
                           'Strike': [1290, 1290],
                           'dtExpiry': [date(2015,1,1), date(2015,1,1)],
                           'Spot': [1290, 1290]})
    
    # interest rate and dividend yield
    df_rates = DataFrame({'dRate': [.021, .023, .024],
                          'iRate': [.010, .015, .019]},
                         index=[date(2011,3,16), date(2013,3,16), date(2015,3,16)])

    # heston model
    heston_params={'v0': 0.051965, 'kappa': 0.977314, 'theta': 0.102573, 'sigma': 0.987796,
            'rho': -0.747033}

    df_final = heston_pricer(dt_trade, df_option, heston_params, df_rates, spot=1290.58)

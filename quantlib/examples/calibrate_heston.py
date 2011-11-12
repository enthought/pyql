import numpy as np
import pandas
from pandas import DataFrame
import datetime

from quantlib.models.equity.heston_model import (
    HestonModelHelper, HestonModel, ImpliedVolError
)
from quantlib.processes.heston_process import HestonProcess
from quantlib.pricingengines.vanilla import AnalyticHestonEngine
from quantlib.math.optimization import LevenbergMarquardt, EndCriteria
from quantlib.settings import Settings
from quantlib.time.api import (
    today, Actual360, NullCalendar, Period, Days, Months, Years, Date,
    Actual365Fixed, TARGET, Weeks, ActualActual
)
from quantlib.termstructures.yields.flat_forward import FlatForward
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.zero_curve import ZeroCurve

def dateToDate(dt):
    return Date(dt.day, dt.month, dt.year)

def dfToZeroCurve(df, dtSettlement, daycounter=Actual365Fixed()):
    """
    Convert a series into a QL zero curve
    """
    dates = [dateToDate(dt) for dt in df.index]
    dates.insert(0, dateToDate(dtSettlement))
    dates.append(dates[-1]+365)
    vx = list(df.values)
    vx.insert(0, vx[0])
    vx.append(vx[-1])
    return ZeroCurve(dates, vx, daycounter)
    
def heston_calibration(df_option, dtTrade=None, df_rates=None, ival=None):
    """
    calibrate heston model 
    """
    
    if dtTrade is None:
        dtTrade = df_option['dtTrade'][0]
    DtSettlement = Date(dtTrade.day, dtTrade.month, dtTrade.year)

    settings = Settings()
    settings.evaluation_date = DtSettlement

    daycounter = Actual365Fixed()
    calendar = TARGET()

    if df_rates is None:
        df_tmp = DataFrame.filter(df_option, items=['dtExpiry', 'IR', 'IDIV'])
        grouped = df_tmp.groupby('dtExpiry')
        df_rates = grouped.agg(lambda x: x[0])

    # convert data frame (date/value) into zero curve
    # expect the index to be a date, and 1 column of values
    
    risk_free_ts = dfToZeroCurve(df_rates['R'], dtTrade)
    dividend_ts = dfToZeroCurve(df_rates['D'], dtTrade)

    # back out the spot from any forward
    iRate = df_option['R'][0]
    iDiv = df_option['D'][0]
    TTM = df_option['T'][0]
    Fwd = df_option['F'][0]
    spot = SimpleQuote(Fwd*np.exp(-(iRate-iDiv)*TTM))
    print('Spot: %f' % spot.value)
    
    # loop through rows in option data frame, construct 
    # helpers for bid/ask

    oneDay = datetime.timedelta(days=1)
    dtExpiry = [dtTrade + int(t*365)*oneDay for t in df_option['T']]
    df_option['dtExpiry'] = dtExpiry

    options = []
    for index, row in df_option.T.iteritems():
        
        strike = row['K']
        if (strike/spot.value > 1.25) | (strike/spot.value < .75):
            continue

        days = int(365*row['T'])
        DtExpiry = DtSettlement + days
        maturity = Period((days+3)/7.0, Weeks)

        options.append(
                HestonModelHelper(
                    maturity, calendar, spot.value, 
                    strike, SimpleQuote(row['VB']),
                    risk_free_ts, dividend_ts,
                    ImpliedVolError))

        options.append(
                HestonModelHelper(
                    maturity, calendar, spot.value, 
                    strike, SimpleQuote(row['VA']),
                    risk_free_ts, dividend_ts,
                    ImpliedVolError))
    
    if ival is None:
        ival = {'v0': 0.1, 'kappa': 1.0, 'theta': 0.1,
        'sigma': 0.5, 'rho': -.5}
        
    process = HestonProcess(
        risk_free_ts, dividend_ts, spot, ival['v0'], ival['kappa'],
         ival['theta'], ival['sigma'], ival['rho'])
         
    model = HestonModel(process)

    engine = AnalyticHestonEngine(model, 64)

    for option in options:
        option.set_pricing_engine(engine)

    om = LevenbergMarquardt(1e-8, 1e-8, 1e-8)
    model.calibrate(
        options, om, EndCriteria(400, 40, 1.0e-8, 1.0e-8, 1.0e-8)
    )

    print('model calibration')
    print('v0: %f kappa: %f theta: %f sigma: %f rho: %f' %
          (model.v0, model.kappa, model.theta, model.sigma,
           model.rho))

    calib_error = (1.0/len(options)) * sum(
        [pow(o.calibration_error()*100.0,2) for o in options])

    print('SSE: %f' % calib_error)
    
    df_output = DataFrame.filter(df_option,
                items=['dtTrade', 'dtExpiry', 
                       'Type', 'K', 'Mid',
                       'QuickDelta', 'VB', 'VA',
                       'R', 'D', 'ATMVol', 'F', 'T'])

    model_value = np.zeros(len(df_option))
    model_iv = np.zeros(len(df_option))
    for i, j in zip(range(len(df_option)), range(0, len(options),2)):
        model_value[i] = options[j].model_value()
        model_iv[i] = options[j].impliedVolatility(model_value[i],
            accuracy=1.e-5, maxEvaluations=5000,
            minVol=.01, maxVol=10.0)
        
    df_output['ModelValue'] = model_value
    df_output['IVModel'] = model_iv

    return df_output

df_rates = pandas.load('data/df_rates.pkl')

# data set with no smoothing
df_option = pandas.load('data/df_final.pkl')
dtTrade = None
df_output = heston_calibration(df_option, dtTrade,
                               df_rates)
df_output.save('data/df_calibration_output_no_smoothing.pkl')





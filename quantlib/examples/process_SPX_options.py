import pandas
import dateutil
import re
import datetime
import numpy as np
from pandas import DataFrame
from pandas.stats.interface import ols
from scipy.interpolate import interp1d
from scipy.stats import norm

from quantlib.pricingengines.blackformula import blackFormulaImpliedStdDev

option_data_file      = 'data/SPX-Options-24jan2011.csv'
calibration_data_file = 'data/IV-SPX-Options-24jan2011.csv'
rate_div_file         = 'data/rate_div.csv'

# min number of quotes per expiry
nMinQuotes = 6
# minimum time to expiry
tMin = 1.0 / 12
# min and max Quick Delta
QDMin = .2; QDMax=.8

##################################################
# script to parse the SPX option file and compute:
# - implied volatility
# - implied interest rate and dividend yield
##################################################

def ExpiryMonth(s):
    """
    SPX contract months
    """
    call_monhts = "ABCDEFGHIJKL"
    put_months = "MNOPQRSTUVWX"

    try:
        m = call_monhts.index(s)
    except ValueError:
        m = put_months.index(s)

    return m

spx_symbol = re.compile("\\(SPX(1[0-9])([0-9]{2})([A-Z])([0-9]{3,4})-E\\)")

def parseSPX(s):
    """
    Parse an SPX quote string, return expiry date and strike
    """
    tokens = spx_symbol.split(s)

    if len(tokens) == 1:
        return {'dtExpiry': None, 'strike': -1}

    year = 2000 + int(tokens[1])
    day = int(tokens[2])
    month = ExpiryMonth(tokens[3])
    strike = float(tokens[4])

    dtExpiry = datetime.date(year, month, day)

    return ({'dtExpiry': dtExpiry, 'strike': strike})

def read_SPX_file(option_data_file):
    """
    Read SPX csv file, return spot and data frame of option quotes
    """

    # read two lines for spot price and trade date
    with open(option_data_file) as fid:
        lineOne = fid.readline()
        spot = eval(lineOne.split(',')[1])

        lineTwo = fid.readline()
        dt = lineTwo.split('@')[0]
        dtTrade = dateutil.parser.parse(dt).date()

    print('Dt Calc: %s Spot: %f' % (dtTrade, spot))

    # read all option price records as a data frame
    df = pandas.io.parsers.read_csv(
        option_data_file, header=2, skiprows=(0,1), sep=','
    )

    # split and stack calls and puts
    call_df = df[df.columns[0:7]]
    call_df = call_df.rename(columns={'Calls':'Spec'})
    call_df['Type'] = 'C'

    put_df = df[df.columns[7:14]]
    put_df = put_df.rename(
        columns = {
            'Puts':'Spec',
            'Last Sale.1':'Last Sale',
            'Net.1':'Net',
            'Bid.1':'Bid',
            'Ask.1':'Ask',
            'Vol.1':'Vol',
            'Open Int.1':'Open Int'
        }
    )
    put_df['Type'] = 'P'

    df_all = call_df.append(put_df,  ignore_index=True)

    # parse Calls and Puts columns for strike and contract month
    # insert into data frame
    
    cp = [parseSPX(s) for s in df_all['Spec']]
    df_all['Strike'] = [x['strike'] for x in cp]
    df_all['dtExpiry'] = [x['dtExpiry'] for x in cp]

    df_all = df_all[df_all['Strike'] > 0]
    df_all['dtTrade'] = dtTrade

    return (spot, df_all)

def ATM_Vol(premium, discountFactor, forward, strike):
    """
    Aproximate std dev, for calls close to the money
    """
    vol = (premium/discountFactor - .5*(forward-strike))*5.0/(forward+strike) 

    return vol

    # get spot and option data frame
    
    (spot, optionDataFrame) = read_SPX_file(option_data_file)

    grouped = optionDataFrame.groupby('dtExpiry') 

    isFirst = True
    for spec, group in grouped:
        print('processing group %s' % spec)

        # implied vol for this type/expiry group

        indx = group.index
        
        dtTrade = group['dtTrade'][indx[0]]
        dtExpiry = group['dtExpiry'][indx[0]]
        daysToExpiry = (dtExpiry-dtTrade).days
        timeToMaturity = daysToExpiry/365.0

        # exclude groups with too few data points 
        # or too short maturity

        if timeToMaturity < tMin:
            continue
            
        # valid call and put quotes
        df_call = group[(group['Type'] == 'C') & (group['Bid']>0) \
                    & (group['Ask']>0)]
        df_put = group[(group['Type'] == 'P') &  (group['Bid']>0) \
                    & (group['Ask']>0)]
        if (len(df_call) == 0) | (len(df_put) == 0):
            continue

        # calculate forward, implied interest rate and implied div. yield
            
        df_call['Mid'] = (df_call['Bid']+df_call['Ask'])/2
        df_put['Mid'] = (df_put['Bid']+df_put['Ask'])/2
    
        df_C = DataFrame.filter(df_call, items=['Strike', 'Mid'])
        df_C.columns = ['Strike', 'PremiumC']
        to_join = DataFrame(df_put['Mid'], index=df_put['Strike'],
            columns=['PremiumP']) 

        # use 'inner' join because some strikes are not quoted for C and P
        df_all = df_C.join(to_join, on='Strike', how='inner')
    
        df_all['C-P'] = df_all['PremiumC'] - df_all['PremiumP']
    
        model = ols(y=df_all['C-P'], x=df_all.ix[:,'Strike'])
        b = model.beta 
    
        # intercept is last coef
        iRate = -np.log(-b[0])/timeToMaturity
        dRate = np.log(spot/b[1])/timeToMaturity
        discountFactor = np.exp(-iRate*timeToMaturity)
        Fwd = spot * np.exp((iRate-dRate)*timeToMaturity)

        print('Fwd: %f int rate: %f div yield: %f' % (Fwd, iRate, dRate))

        # interpolate ATM premium and vol: used to compute Quick Delta
        f_call = interp1d(df_all['Strike'].values, df_all['PremiumC'].values)
        f_put = interp1d(df_all['Strike'].values, df_all['PremiumP'].values)

        atmPremium = (f_call(Fwd)+f_put(Fwd))/2
        atmVol = blackFormulaImpliedStdDev('C', strike=Fwd,
                 forward=Fwd, blackPrice=atmPremium,
                 discount=discountFactor,
                 TTM=timeToMaturity)/np.sqrt(timeToMaturity)
                    
        print('ATM vol: %f' % atmVol)

        # Quick Delta, computed with ATM vol
        rv = norm()
        df_call['QuickDelta'] = [rv.cdf(np.log(Fwd/strike)/(atmVol*np.sqrt(timeToMaturity))) \
        for strike in df_call['Strike']]
        df_put['QuickDelta'] = [rv.cdf(np.log(Fwd/strike)/(atmVol*np.sqrt(timeToMaturity))) \
        for strike in df_put['Strike']]

        # implied bid/ask vol for all options
    
        def impvol(strike, premium):
            try:
                vol = blackFormulaImpliedStdDev(cp, strike,
                    forward=Fwd, blackPrice=premium, discount=discountFactor,
                    TTM=timeToMaturity)
            except:
                vol = np.nan
                return vol/np.sqrt(timeToMaturity)
        
        cp = 'C'
        df_call['IVBid'] = [impvol(strike, price) for strike, price in zip(df_call['Strike'], df_call['Bid'])]
    df_call['IVAsk'] = [impvol(strike, price) for strike, price in zip(df_call['Strike'], df_call['Ask'])]
    # QD computed with ATM vol 
        
    cp = 'P'
    df_put['IVBid'] = [impvol(strike, price) for strike, price in zip(df_put['Strike'], df_put['Bid'])]
    df_put['IVAsk'] = [impvol(strike, price) for strike, price in zip(df_put['Strike'], df_put['Ask'])]

    # keep OTM data for options within QD range
    
    df_call = df_call[  (df_call['Strike'] >= Fwd) & \
                        (df_call['QuickDelta'] >= QDMin) & \
                        (df_call['QuickDelta'] <= QDMax) ]
                        
    df_put = df_put[  (df_put['Strike'] < Fwd) & \
                        (df_put['QuickDelta'] >= QDMin) & \
                        (df_put['QuickDelta'] <= QDMax) ]

    # final assembly...

    df_cp = df_call.append(df_put,  ignore_index=True)
    df_cp['R'] = iRate 
    df_cp['D'] = dRate 
    df_cp['ATMVol'] = atmVol 
    df_cp['F'] = Fwd
    df_cp['T'] = timeToMaturity
    df_cp = df_cp.rename(columns=
                         {'IVBid': 'VB',
                          'IVAsk': 'VA',
                          'Strike': 'K'})
    df_cp['CP'] = [1 if t == 'C' else -1 for t in df_cp['Type']]
                         
    if isFirst:
        df_final = df_cp
        isFirst = False 
    else:
        df_final = df_final.append(df_cp, ignore_index=True)
        
df_final.to_csv(calibration_data_file, index=False)

df_final.save('data/df_final.pkl')

# save term structure of dividends and rate: first item in each expiry group   
df_tmp = DataFrame.filter(df_final, items=['dtExpiry', 'R', 'D'])
grouped = df_tmp.groupby('dtExpiry')
df_rates = grouped.agg(lambda x: x[0])
   
df_rates.to_csv(rate_div_file)
df_rates.save('data/df_rates.pkl')

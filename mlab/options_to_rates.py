
import pandas
import dateutil
import re
import datetime
import numpy as np
from pandas import DataFrame
from pandas.stats.interface import ols
from scipy.interpolate import interp1d
from scipy.stats import norm

def options_to_rates(optionDataFrame, tMin=1./12., nMin=6):
    
    """
    Extract implied risk-free rates and div. yield from
    standard European option quote file.
    """
    
    grouped = optionDataFrame.groupby('dtExpiry') 

    isFirst = True
    dt_exp = []
    vx_rate = []
    vx_div = []
    
    for spec, group in grouped:
        print('processing group %s' % spec)

        # implied vol for this type/expiry group

        indx = group.index
        
        dtTrade = group['dtTrade'][indx[0]]
        dtExpiry = group['dtExpiry'][indx[0]]
        spot = group['Spot'][indx[0]]
        daysToExpiry = (dtExpiry-dtTrade).days
        timeToMaturity = daysToExpiry/365.0

        # exclude groups with too short time to maturity
        
        if timeToMaturity < tMin:
            continue
            
        # exclude groups with too few data points
        
        df_call = group[group['Type'] == 'C']
        df_put = group[group['Type'] == 'P']
        
        if (len(df_call) < nMin) | (len(df_put) < nMin):
            continue

        # calculate forward, implied interest rate and implied div. yield
            
        df_C = DataFrame((df_call['PBid']+df_call['PAsk'])/2,
                         columns=['PremiumC'])
        df_C.index = df_call['Strike']
        df_P = DataFrame((df_put['PBid']+df_put['PAsk'])/2,
                         columns=['PremiumP'])
        df_P.index = df_put['Strike']
        
        # use 'inner' join because some strikes are not quoted for C and P
        df_all = df_C.join(df_P, how='inner')
        df_all['Strike'] = df_all.index
        df_all['C-P'] = df_all['PremiumC'] - df_all['PremiumP']
    
        model = ols(y=df_all['C-P'], x=df_all['Strike'])
        b = model.beta 
    
        # intercept is last coef
        iRate = -np.log(-b[0])/timeToMaturity
        dRate = np.log(spot/b[1])/timeToMaturity

        vx_rate.append(iRate)
        vx_div.append(dRate)
        dt_exp.append(dtExpiry)
        
    df = DataFrame({'iRate': vx_rate, 'dRate': vx_div}, index=dt_exp)

    return df

if __name__ == '__main__':
    option_data_frame = pandas.core.common.load('../examples/data/df_SPX_24jan2011.pkl')

    df_rate = options_to_rates(option_data_frame)

    df_rate.save('df_rates.pkl')
    

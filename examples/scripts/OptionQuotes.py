# -*- coding: utf-8 -*-
# <nbformat>3</nbformat>

# <markdowncell>

# Preprocessing of Option Quotes
# ==============================
# 
# This notebook demonstrates the preprocessing of equity options, in preparation for the estimation of the parameters of a stochastic model.
# A number of preliminary calculations must be performed:
# 
# 1. Calculation of implied risk-free rate and dividend yield, and derivation of forward prices
# 2. Calculation of forward at-the-money volatility. There is probably no option struck at the forward price, so this item must be computed by interpolation.
# 3. Calculation of the Black-=Scholes implied bid and ask volatility, given bid and ask option prices. 
# 4. Calculation of 'Quick Delta': this is a common measure of moneyness, useful for representing the volatility smile.
# 
# Each step is now described.
# 
# Calculation of implied dividend yield and risk-free rate
# --------------------------------------------------------
# 
# Recall the put-call parity relationship with continuous dividends:
# 
# $$
# C_t - P_t = S_t e^{-d (T-t)} - K e^{-r (T-t)}
# $$
# 
# where
# 
# * $C_t$ price of call at time $t$
# * $P_t$ price of put at time $t$
# * $S_t$ spot price of underlying asset
# * $d$ continuous dividend yield
# * $r$ risk-free rate
# * $T$ Expity
# 
# For each maturity, we estimate the linear regression:
# 
# $$
# C_t - P_t = a_0 + a_1 K
# $$
# 
# which yields
# 
# $$
# r = - \frac{1}{T} \ln (-a_1)
# $$
# $$
# d = \frac{1}{T} \ln \left( \frac{S_t}{a_0} \right)
# $$
# 
# Calculation of forward at-the-money volatility
# ----------------------------------------------
# 
# We next want to estimate the implied volatility of an option struck at the forward price. In general, such option is not traded, and the volatility must therefore be estimated. The calculation involves 3 steps, performed separately on calls and puts:
# 
# 1. Estimate the bid ($\sigma_b(K)$) and ask ($\sigma_a(K)$) Black-Scholes volatility for each quote.
# 2. Compute a mid-market implied volatility for each quote:
# $$
# \sigma(K) = \frac{\sigma_b(K)+\sigma_a(K)}{2}
# $$
# 3. Let $F$ be the forward price, the corresponding mid-market implied volatility is computed by linear interpolation between the two quuotes braketing $F$.
# 
# The forward ATM volatility is the average of the volatilities computed on calls and puts.
# 
# Quick Delta
# -----------
# 
# Recall that the delta of a European call is defined as $N(d_1)$, where
# 
# $$
# d_{1} = \frac{1}{\sigma \sqrt{T}} \left[ \ln \left( \frac{S}{K} \right) + \left( r + \frac{1}{2}\sigma^2 \right)T \right]
# $$
# 
# The "Quick Delta" (QD) is a popular measure of moneyness, inspired from the definition of delta:
# 
# $$
# QD(K) = N \left( \frac{1}{\sigma \sqrt{T}} \ln \left( \frac{F_T}{K} \right) \right)
# $$
# 
# Note that $QD(F_T)=0.5$, for all maturities, while the regular forward delta is a function of time to expiry. This property of Quick Delta makes it convenient for representing the volatility smile.
# 
# Data Filters
# ------------
# 
# A number of filters may be applied, in an attempt to exclude inconsistent or erroneous data.
# 
# 1. Exclusion of maturities shorter than $tMin$
# 2. Exclusion of maturities with less than $nMin$ quotes
# 3. Exclusion of quotes with Quick Delta less than $QDMin$ or higher than $QDMax$
# 
# Implementation
# --------------
# 
# This logic is implemented in the function `Compute_IV`, presented below. The function takes as argument a `pandas DataFrame` and returns another 
# `DataFrame`, with one row per quote and 14 columns:
# 
# 1. Type: 'C'/'P'
# 2. Strike
# 3. dtExpiry
# 4. dtTrade
# 5. Spot
# 6. IVBid: Black-Scholes implied volatility (bid)
# 7. IVAsk: Black-Scholes implied volatility (ask)
# 8. QD: Quick Delta
# 9. iRate: risk-free rate (continuously compounded)
# 10. iDiv: dividend yield (continuously compounded)
# 11. Fwd: Forward price
# 12. TTM: Time to maturity, in fraction of years (ACT/365)
# 13. PBid: Premium (bid)
# 14. PAsk: Premium (ask)

# <codecell>

import pandas
import dateutil
import re
import datetime
import numpy as np
from pandas import DataFrame
from scipy.interpolate import interp1d
from scipy.stats import norm
from scipy.linalg import lstsq

import quantlib.pricingengines.blackformula
from quantlib.pricingengines.blackformula import blackFormulaImpliedStdDev

def Compute_IV(optionDataFrame, tMin=0, nMin=0, QDMin=0, QDMax=1, keepOTMData=True):
    
    """
    Pre-processing of a standard European option quote file.
    - Calculation of implied risk-free rate and dividend yield
    - Calculation of implied volatility
    - Estimate ATM volatility for each expiry
    - Compute implied volatility and Quick Delta for each quote
    
    Options for filtering the input data set: 
    - maturities with less than nMin strikes are ignored
    - maturities shorter than tMin (ACT/365 daycount) are ignored
    - strikes with Quick Delta < qdMin or > qdMax are ignored
    """
    
    grouped = optionDataFrame.groupby('dtExpiry') 

    isFirst = True
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

        y = np.array(df_all['C-P'])
        x = np.array(df_all['Strike'])
        A = np.vstack((x, np.ones(x.shape))).T

        b = np.linalg.lstsq(A, y)[0]
        # intercept is last coef
        iRate = -np.log(-b[0])/timeToMaturity
        dRate = np.log(spot/b[1])/timeToMaturity
        
        discountFactor = np.exp(-iRate*timeToMaturity)
        Fwd = spot * np.exp((iRate-dRate)*timeToMaturity)

        print('Fwd: %f int rate: %f div yield: %f' % (Fwd, iRate, dRate))

        # mid-market ATM volatility
        
        def impvol(cp, strike, premium):
            try:
                vol = blackFormulaImpliedStdDev(cp, strike,
                    forward=Fwd, blackPrice=premium, discount=discountFactor,
                    TTM=timeToMaturity)
            except:
                vol = np.nan
            return vol/np.sqrt(timeToMaturity)
        
        # implied bid/ask vol for all options
        
        df_call['IVBid'] = [impvol('C', strike, price) for strike, price
                            in zip(df_call['Strike'], df_call['PBid'])]
        df_call['IVAsk'] = [impvol('C', strike, price) for strike, price
                            in zip(df_call['Strike'], df_call['PAsk'])]
        
        df_call['IVMid'] = (df_call['IVBid'] + df_call['IVAsk'])/2
        
        df_put['IVBid'] = [impvol('P', strike, price) for strike, price
                           in zip(df_put['Strike'], df_put['PBid'])]
        df_put['IVAsk'] = [impvol('P', strike, price) for strike, price
                           in zip(df_put['Strike'], df_put['PAsk'])]
        
        df_put['IVMid'] = (df_put['IVBid'] + df_put['IVAsk'])/2
        
        f_call = interp1d(df_call['Strike'].values, df_call['IVMid'].values)
        f_put = interp1d(df_put['Strike'].values, df_put['IVMid'].values)

        atmVol = (f_call(Fwd)+f_put(Fwd))/2
        print('ATM vol: %f' % atmVol)

        # Quick Delta, computed with ATM vol
        rv = norm()
        df_call['QuickDelta'] = [rv.cdf(np.log(Fwd/strike)/(atmVol*np.sqrt(timeToMaturity))) \
        for strike in df_call['Strike']]
        df_put['QuickDelta'] = [rv.cdf(np.log(Fwd/strike)/(atmVol*np.sqrt(timeToMaturity))) \
        for strike in df_put['Strike']]

        # keep data within QD range
    
        df_call = df_call[(df_call['QuickDelta'] >= QDMin) & \
                          (df_call['QuickDelta'] <= QDMax) ]
                        
        df_put = df_put[  (df_put['QuickDelta'] >= QDMin) & \
                          (df_put['QuickDelta'] <= QDMax) ]

        # final assembly...

        df_cp = df_call.append(df_put,  ignore_index=True)
        df_cp['iRate'] = iRate 
        df_cp['iDiv'] = dRate 
        df_cp['ATMVol'] = atmVol 
        df_cp['Fwd'] = Fwd
        df_cp['TTM'] = timeToMaturity
        df_cp['CP'] = [1 if t == 'C' else -1 for t in df_cp['Type']]

        # keep only OTM data ?
        if keepOTMData:
            df_cp = df_cp[((df_cp['Strike']>=Fwd) & (df_cp['Type'] == 'C')) |
                          ((df_cp['Strike']<Fwd) & (df_cp['Type'] == 'P'))]
                         
        if isFirst:
            df_final = df_cp
            isFirst = False 
        else:
            df_final = df_final.append(df_cp, ignore_index=True)

    return df_final

# <markdowncell>

# Example
# -------
# 
# Using the SPX data set found in the data folder, the above procedure generates a `DataFrame` suited for use in a calibration program.

# <codecell>

if __name__ == '__main__':

    option_data_frame = pandas.core.common.load('../data/df_SPX_24jan2011.pkl')

    df_final = Compute_IV(option_data_frame, tMin=1/12, nMin=6, QDMin=.2, QDMax=.8)

    # save a csv file and pickled data frame
    df_final.to_csv('../data/df_options_SPX_24jan2011.csv', index=False)
    df_final.save('../data/df_options_SPX_24jan2011.pkl')


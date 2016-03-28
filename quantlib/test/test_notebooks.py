from __future__ import division
from __future__ import print_function
from .unittest_tools import unittest

import pandas
import numpy as np
from pandas import DataFrame

import quantlib.reference.names as nm
from quantlib.pricingengines.blackformula import blackFormulaImpliedStdDev

def Compute_IV(optionDataFrame, tMin=0, nMin=0, QDMin=0, QDMax=1,
               keepOTMData=True):

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

    grouped = optionDataFrame.groupby(nm.EXPIRY_DATE)

    isFirst = True
    for spec, group in grouped:
        print('processing group %s' % spec)

        # implied vol for this type/expiry group

        indx = group.index

        dtTrade = group[nm.TRADE_DATE][indx[0]]
        dtExpiry = group[nm.EXPIRY_DATE][indx[0]]
        spot = group[nm.SPOT][indx[0]]
        daysToExpiry = (dtExpiry - dtTrade).days
        timeToMaturity = daysToExpiry / 365.0

        # exclude groups with too short time to maturity

        if timeToMaturity < tMin:
            print('Skipped due to too short time to maturity')
            continue

        # exclude groups with too few data points

        df_call = group[group[nm.OPTION_TYPE] == nm.CALL_OPTION]
        df_put = group[group[nm.OPTION_TYPE] == nm.PUT_OPTION]

        if (len(df_call) < nMin) | (len(df_put) < nMin):
            print('Skip too few data points')
            continue

        # calculate forward, implied interest rate and implied div. yield

        df_C = DataFrame((df_call['PBid'] + df_call['PAsk']) / 2,
                         columns=['PremiumC'])
        df_C.index = df_call['Strike'].values

        df_P = DataFrame((df_put['PBid'] + df_put['PAsk']) / 2,
                         columns=['PremiumP'])
        df_P.index = df_put['Strike'].values

        # use 'inner' join because some strikes are not quoted for C and P
        df_all = df_C.join(df_P, how='inner')
        df_all.loc[:, 'Strike'] = df_all.index
        df_all.loc[:, 'C-P'] = df_all['PremiumC'] - df_all['PremiumP']

        y = np.array(df_all['C-P'])
        x = np.array(df_all['Strike'])
        A = np.vstack((x, np.ones(x.shape))).T

        b = np.linalg.lstsq(A, y)[0]

        # intercept is last coef
        iRate = -np.log(-b[0]) / timeToMaturity
        dRate = np.log(spot / b[1]) / timeToMaturity

        discountFactor = np.exp(-iRate * timeToMaturity)
        Fwd = spot * np.exp((iRate - dRate) * timeToMaturity)

        print('Fwd: %f int rate: %f div yield: %f' % (Fwd, iRate, dRate))

        # mid-market ATM volatility

        def impvol(cp, strike, premium):
            try:
                vol = blackFormulaImpliedStdDev(cp, strike,
                    forward=Fwd, blackPrice=premium, discount=discountFactor,
                    TTM=timeToMaturity)
            except:
                vol = np.nan
            return vol / np.sqrt(timeToMaturity)

        # implied bid/ask vol for all options

        df_call.loc[:, 'IVBid'] = [impvol('C', strike, price) for strike, price
                            in zip(df_call['Strike'], df_call['PBid'])]
        df_call.loc[:, 'IVAsk'] = [impvol('C', strike, price) for strike, price
                            in zip(df_call['Strike'], df_call['PAsk'])]

        df_call.loc[:, 'IVMid'] = (df_call['IVBid'] + df_call['IVAsk']) / 2

        df_put.loc[:, 'IVBid'] = [impvol('P', strike, price) for strike, price
                           in zip(df_put['Strike'], df_put['PBid'])]
        df_put.loc[:, 'IVAsk'] = [impvol('P', strike, price) for strike, price
                           in zip(df_put['Strike'], df_put['PAsk'])]

        df_put.loc[:, 'IVMid'] = (df_put['IVBid'] + df_put['IVAsk']) / 2

        # atmVol = (f_call(Fwd) + f_put(Fwd)) / 2
        atmVol = .20
        print('ATM vol: %f' % atmVol)

        # Quick Delta, computed with ATM vol
        df_call.loc[:, 'QuickDelta'] = 0.5
        df_put.loc[:, 'QuickDelta'] = 0.5

        # keep data within QD range

        df_call = df_call[(df_call['QuickDelta'] >= QDMin) & \
                          (df_call['QuickDelta'] <= QDMax) ]

        df_put = df_put[(df_put['QuickDelta'] >= QDMin) & \
                        (df_put['QuickDelta'] <= QDMax) ]

        # final assembly...

        df_cp = df_call.append(df_put, ignore_index=True)
        df_cp.loc[:, nm.INTEREST_RATE] = iRate
        df_cp.loc[:, nm.DIVIDEND_YIELD] = dRate
        df_cp.loc[:, nm.ATMVOL] = atmVol
        df_cp.loc[:, nm.FORWARD] = Fwd

        # keep only OTM data ?
        if keepOTMData:
            df_cp = df_cp[((df_cp[nm.STRIKE]>=Fwd) & (df_cp[nm.OPTION_TYPE] == nm.CALL_OPTION)) |
                          ((df_cp[nm.STRIKE]<Fwd) & (df_cp[nm.OPTION_TYPE] == nm.PUT_OPTION))]

        if isFirst:
            df_final = df_cp
            isFirst = False
        else:
            df_final = df_final.append(df_cp, ignore_index=True)

    return df_final


class NoteBooksTestCase(unittest.TestCase):
    """
    Test some functions used in notebooks.
    Mostly useful to test stability of pandas API
    """

    def test_option_quotes(self):

        option_data_frame = pandas.read_pickle(
            './quantlib/test/data/df_SPX_24jan2011.pkl'
        )

        df_final = Compute_IV(
            option_data_frame, tMin=0.5/12, nMin=6, QDMin=.2, QDMax=.8
        )

        print('Number of rows: %d' % len(df_final.index))
        self.assertEqual(len(df_final.index), 553, 'Wrong number of rows')

if __name__ == '__main__':
    unittest.main()

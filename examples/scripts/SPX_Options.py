from __future__ import print_function
# -*- coding: utf-8 -*-
# <nbformat>3</nbformat>

# <markdowncell>

# Standardized Option Quotes Data Format
# ======================================
# 
# To facilitate model calibration, a standard input format has been defined, which contains all the
# necessary data. The data is held in a [Panda](http://pandas.pydata.org) table, with one row per quote and
# 8 columns, as follows:
# 
# * dtTrade: Quote date, or time stamp
# * Strike: Ditto
# * dtExpiry: Option expiry date
# * CP: Call/Put flag, coded as C/P or Call/Put
# * Spot: Price of underlying asset
# * Type: European/American
# * PBid: Bid price
# * PAsk: Ask price
# 
# Note that we do not include the dividend yield nor the risk-free rate in the data set: The 
# implied forward price and risk-free rate are estimated from the call/put parity.
# 
# SPX Option Data Processing
# --------------------------
# 
# As an illustration, we provide below the procedure for converting raw SPX option data, as published by the [CBOE](http://www.cboe.com/DelayedQuote/QuoteTableDownload.aspx), into the standard input format.
# 
# ### SPX Utility functions
# 
# These functions parse the SPX option names, and extract expiry date and strike.

# <codecell>

import pandas
import dateutil, datetime
import re

def ExpiryMonth(s):
    """
    SPX contract months
    """
    call_months = "ABCDEFGHIJKL"
    put_months = "MNOPQRSTUVWX"

    try:
        m = call_months.index(s)
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


# <markdowncell>

# ### Reading the SPX raw data file
# 
# The csv file downloaded from the CBOE site can be converted into a standard panda table by the following function. 

# <codecell>

def read_SPX_file(option_data_file):
    """
    Read SPX csv file, return spot and data frame of option quotes
    """

    # read two lines for spot price and trade date
    with open(option_data_file) as fid:
        lineOne = fid.readline()
        spot = float(lineOne.split(',')[1])

        lineTwo = fid.readline()
        dt = lineTwo.split('@')[0]
        dtTrade = dateutil.parser.parse(dt).date()

        print(('Dt Calc: %s Spot: %f' % (dtTrade, spot)))

    # read all option price records as a data frame
    df = pandas.io.parsers.read_csv(option_data_file, header=0, sep=',', skiprows=[0,1])

    # split and stack calls and puts
    call_df = df[['Calls', 'Bid', 'Ask']]
    call_df = call_df.rename(columns={'Calls':'Spec', 'Bid':'PBid', 'Ask': 'PAsk'})
    call_df['Type'] = 'C'

    put_df = df[['Puts', 'Bid.1', 'Ask.1']]
    put_df = put_df.rename(columns = {'Puts':'Spec', 'Bid.1':'PBid',
    'Ask.1':'PAsk'})
    put_df['Type'] = 'P'

    df_all = call_df.append(put_df,  ignore_index=True)

    # parse Calls and Puts columns for strike and contract month
    # insert into data frame

    cp = [parseSPX(s) for s in df_all['Spec']]
    df_all['Strike'] = [x['strike'] for x in cp]
    df_all['dtExpiry'] = [x['dtExpiry'] for x in cp]

    del df_all['Spec']

    df_all = df_all[(df_all['Strike'] > 0) & (df_all['PBid']>0) \
                    & (df_all['PAsk']>0)]

    df_all['dtTrade'] = dtTrade
    df_all['Spot'] = spot

    return df_all

option_data_file = \
    '../data/SPX-Options-24jan2011.csv'

if __name__ == '__main__':
    df_SPX = read_SPX_file(option_data_file)
    print('%d records processed' % len(df_SPX))

    # save a csv file and pickled data frame
    df_SPX.to_csv('../data/df_SPX_24jan2011.csv', index=False)
    df_SPX.save('../data/df_SPX_24jan2011.pkl')
    print('File saved')


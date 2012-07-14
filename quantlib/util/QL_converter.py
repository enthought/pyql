"""
 Copyright (C) 2012, Enthought Inc
 Copyright (C) 2012, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import pandas
from pandas import DataFrame

from quantlib.time.api import Date, Actual365Fixed
from quantlib.termstructures.yields.zero_curve import ZeroCurve


def dateToQLDate(dt):
    """
    Converts a datetime object into a QL Date
    """
    
    return Date(dt.day, dt.month, dt.year)

def dfToZeroCurve(df_rates, dt_settlement, daycounter=Actual365Fixed()):
    """
    Convert a panda data frame into a QL zero curve
    """
    
    dates = [dateToQLDate(dt) for dt in df_rates.index]
    dates.insert(0, dateToQLDate(dt_settlement))
    dates.append(dates[-1]+365*2)
    vx = list(df_rates.values)
    vx.insert(0, vx[0])
    vx.append(vx[-1])
    return ZeroCurve(dates, vx, daycounter)

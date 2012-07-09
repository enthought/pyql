import pandas
from pandas import DataFrame
import datetime

from quantlib.time.api import Period, Date, Actual365Fixed, TARGET, Days
from quantlib.termstructures.yields.zero_curve import ZeroCurve

def dateToQLDate(dt):
    """
    Converts a datetime object into a QL Date
    """
    
    return Date(dt.day, dt.month, dt.year)

def dfToZeroCurve(df_rates, dtSettlement, daycounter=Actual365Fixed()):
    """
    Convert a panda data frame into a QL zero curve
    """
    
    dates = [dateToQLDate(dt) for dt in df_rates.index]
    dates.insert(0, dateToQLDate(dtSettlement))
    dates.append(dates[-1]+365*2)
    vx = list(df_rates.values)
    vx.insert(0, vx[0])
    vx.append(vx[-1])
    return ZeroCurve(dates, vx, daycounter)


from quantlib.time.api import Date, Actual365Fixed
from quantlib.termstructures.yields.zero_curve import ZeroCurve

def pydate_to_qldate(date):
    """ Converts a datetime object into a QL Date. """

    return Date(date.day, date.month, date.year)

def df_to_zero_curve(rates, settlement_date, daycounter=Actual365Fixed()):
    """ Converts a pandas data frame into a QL zero curve. """

    dates = [pydate_to_qldate(dt) for dt in rates.index]
    dates.insert(0, pydate_to_qldate(settlement_date))
    dates.append(dates[-1] + 365 * 2) # why adding two years here. Is it conventional?

    values = rates.values.tolist()
    values.insert(0, values[0])
    values.append(values[-1])

    return ZeroCurve(dates, values, daycounter)

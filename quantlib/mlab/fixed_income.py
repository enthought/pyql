"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

from datetime import date

from quantlib.instruments.bonds import (
    FixedRateBond, ZeroCouponBond
)
from quantlib.pricingengines.bond import DiscountingBondEngine
from quantlib.time.calendar import (
    TARGET, Unadjusted, ModifiedFollowing, Following
)
from quantlib.time.calendars.united_states import (
    UnitedStates, GOVERNMENTBOND
)
from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.compounding import Compounded, Continuous
from quantlib.time.date import (
    Date, Days, Semiannual, January, August, Period, March, February,
    Jul, Annual, Years
)
from quantlib.time.daycounter import Actual365Fixed
from quantlib.time.daycounters.actual_actual import ActualActual, Bond, ISMA
from quantlib.time.schedule import Schedule, Backward
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure
)
from quantlib.util.converter import pydate_to_qldate

from quantlib.mlab.util import common_shape, array_call
import inspect

DEBUG = True

def bndprice(bond_yield, coupon_rate, evaluation_date, maturity_date,
             period, daycounter):

    frame = inspect.currentframe()
    the_shape, shape, values = common_shape(frame)

    if DEBUG:
        print(the_shape)
        print(shape)
        print(values)
        
    all_scalars = np.all([shape[key][0] == 'scalar' for key in shape])

    if all_scalars:
        price, ac = _bndprice(**values)
    else:
        res = array_call(_bndprice, shape, values)
        price = np.reshape([x[0] for x in res], the_shape)
        ac = np.reshape([x[1] for x in res], the_shape)
    return (price, ac) 


def _bndprice(bond_yield, coupon_rate, evaluation_date, maturity_date,
              period=Semiannual, daycounter=Actual365Fixed()):
    """
    Clean price and accrued interest of a bond
    """

    evaluation_date = pydate_to_qldate(evaluation_date)
    
    settings = Settings()
    settings.evaluation_date =  evaluation_date

    calendar = TARGET()
    effective_date = Date(10, Jul, 2006)
    termination_date = pydate_to_qldate(maturity_date)

    # effective date must be before settlement date, but do not
    # care about exact issuance date of bond

    effective_date = Date(termination_date.day, termination_date.month,
                          evaluation_date.year)
    effective_date = calendar.advance(
        effective_date, -1, Years, convention=Unadjusted)

    settlement_days = 1
    settlement_date = calendar.advance(
        evaluation_date, -1, Days, convention=ModifiedFollowing)

    face_amount = 100.0
    redemption = 100.0

    fixed_bond_schedule = Schedule(
        effective_date,
        termination_date,
        Period(period),
        calendar,
        ModifiedFollowing,
        ModifiedFollowing,
        Backward
    )

    issue_date = effective_date

    bond = FixedRateBond(
        settlement_days,
                face_amount,
                fixed_bond_schedule,
                [coupon_rate],
        ActualActual(ISMA),
                Following,
        redemption,
        issue_date
    )

    discounting_term_structure = YieldTermStructure(relinkable=True)
    flat_term_structure = FlatForward(
        settlement_days = 1,
        forward         = bond_yield,
        calendar        = NullCalendar(),
        daycounter      = daycounter,
        compounding     = Annual,
        frequency       = Annual)

    discounting_term_structure.link_to(flat_term_structure)

    engine = DiscountingBondEngine(discounting_term_structure)

    bond.set_pricing_engine(engine)


    price = bond.clean_price
    ac = bond.accrued_amount(settlement_date)

    return (price, ac)


if __name__ == '__main__':

    Yield = [0.04, 0.05, 0.06] 
    CouponRate = 0.05
    Settle = '20-Jan-1997' 
    Maturity = '15-Jun-2002' 
    Period = 2 
    Basis = 0 

    (price, ac) = bndprice(bond_yield=Yield, coupon_rate=CouponRate,
                           evaluation_date = Settle,
                           maturity_date = Maturity,
                           Period = 'SemiAnnual',
                           Basis = 'ActualActual')

    print('price: %5.2f' % price)
    print('ac: %5.2f' % ac)

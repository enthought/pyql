"""
 Copyright (C) 2013, Enthought Inc
 Copyright (C) 2013, Patrick Henaff

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
"""

import numpy as np
from quantlib.instruments.bonds import (
    FixedRateBond
)

from quantlib.compounding import Compounded

from quantlib.pricingengines.bond import DiscountingBondEngine
from quantlib.time.calendar import (
    TARGET, Unadjusted, ModifiedFollowing, Following)

from quantlib.time.calendars.null_calendar import NullCalendar
from quantlib.time.date import (
    Date, Days, Period, Years, str_to_frequency)

from quantlib.time.schedule import Schedule, Backward
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import (
    FlatForward, YieldTermStructure
)

from quantlib.time.daycounter import DayCounter

from quantlib.util.converter import pydate_to_qldate

from quantlib.mlab.util import common_shape, array_call
import inspect

DEBUG = False


def bndprice(bond_yield, coupon_rate, pricing_date, maturity_date,
             period, basis, compounding_frequency=None):
    """
    Calculate price and accrued interest

    Args:

    bond_yield:    compound yield to maturity
    coupon_rate:   coupon rate in decimal form (5% = .05)
    pricing_date:  the date where market data is observed. Settlement
                   is by default 2 days after pricing_date
    maturity_date: ... bond
    period:        periodicity of coupon payments
    basis:         day count basis for computing accrued interest
    compounding_frequency: ... of yield. By default: annual for ISMA,
                           semi annual otherwise


    Returns:
    price: clean price
    ac:    accrued interest

    """

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


def _bndprice(bond_yield, coupon_rate, pricing_date, maturity_date,
              period, basis, compounding_frequency):
    """
    Clean price and accrued interest of a bond
    """

    _period = str_to_frequency(period)

    evaluation_date = pydate_to_qldate(pricing_date)

    settings = Settings()
    settings.evaluation_date = evaluation_date

    calendar = TARGET()
    termination_date = pydate_to_qldate(maturity_date)

    # effective date must be before settlement date, but do not
    # care about exact issuance date of bond

    effective_date = Date(termination_date.day, termination_date.month,
                          evaluation_date.year)
    effective_date = calendar.advance(
        effective_date, -1, Years, convention=Unadjusted)

    settlement_date = calendar.advance(
            evaluation_date, 2, Days, convention=ModifiedFollowing)

    face_amount = 100.0
    redemption = 100.0

    fixed_bond_schedule = Schedule(
        effective_date,
        termination_date,
        Period(_period),
        calendar,
        ModifiedFollowing,
        ModifiedFollowing,
        Backward
    )

    issue_date = effective_date
    cnt = DayCounter.from_name(basis)
    settlement_days = 2

    bond = FixedRateBond(
                settlement_days,
                face_amount,
                fixed_bond_schedule,
                [coupon_rate],
                cnt,
                Following,
                redemption,
                issue_date
    )

    discounting_term_structure = YieldTermStructure(relinkable=True)

    cnt_yield = DayCounter.from_name('Actual/Actual (Historical)')

    flat_term_structure = FlatForward(
        settlement_days=2,
        forward=bond_yield,
        calendar=NullCalendar(),
        daycounter=cnt_yield,
        compounding=Compounded,
        frequency=_period)

    discounting_term_structure.link_to(flat_term_structure)

    engine = DiscountingBondEngine(discounting_term_structure)

    bond.set_pricing_engine(engine)

    price = bond.clean_price
    ac = bond.accrued_amount(pydate_to_qldate(settlement_date))

    return (price, ac)


def cfamounts(coupon_rate, pricing_date, maturity_date,
             period, basis):
    """
    Calculate price and accrued interest

    Args:

    coupon_rate:   coupon rate in decimal form (5% = .05)
    pricing_date:  the date where market data is observed. Settlement
                   is by default 2 days after pricing_date
    maturity_date: ... bond
    period:        periodicity of coupon payments
    basis:         day count basis for computing accrued interest


    Returns:
    cf_amounts: cash flow amount
    cf_dates:   cash flow dates

    """

    frame = inspect.currentframe()
    the_shape, shape, values = common_shape(frame)

    all_scalars = np.all([shape[key][0] == 'scalar' for key in shape])

    if all_scalars:
        cf_a, cf_d = _cfamounts(**values)
    else:
        raise Exception('Only scalar inputs are handled')

    return (cf_a, cf_d)


def _cfamounts(coupon_rate, pricing_date, maturity_date,
              period, basis):
    """
    cash flow schedule
    """

    _period = str_to_frequency(period)

    evaluation_date = pydate_to_qldate(pricing_date)

    settings = Settings()
    settings.evaluation_date = evaluation_date

    calendar = TARGET()
    termination_date = pydate_to_qldate(maturity_date)

    # effective date must be before settlement date, but do not
    # care about exact issuance date of bond

    effective_date = Date(termination_date.day, termination_date.month,
                          evaluation_date.year)
    effective_date = calendar.advance(
        effective_date, -1, Years, convention=Unadjusted)


    face_amount = 100.0
    redemption = 100.0

    fixed_bond_schedule = Schedule(
        effective_date,
        termination_date,
        Period(_period),
        calendar,
        ModifiedFollowing,
        ModifiedFollowing,
        Backward
    )

    issue_date = effective_date
    cnt = DayCounter.from_name(basis)
    settlement_days = 2

    bond = FixedRateBond(
                settlement_days,
                face_amount,
                fixed_bond_schedule,
                [coupon_rate],
                cnt,
                Following,
                redemption,
                issue_date)

    res = zip(*bond.cashflows)

    return(res)

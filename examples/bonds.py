""" Example demonstrating pricing bonds using PyQL.

This example is based on the QuantLib Excel bond demo.

"""
from __future__ import print_function

from quantlib.instruments.bonds import FixedRateBond
from quantlib.time import (
    TARGET, Unadjusted, ModifiedFollowing, Following, NullCalendar
)
from quantlib.compounding import Continuous
from quantlib.pricingengines import DiscountingBondEngine
from quantlib.time.date import Date, August, Period, Jul, Annual, Years
from quantlib.time.daycounters import ActualActual, ISMA, Actual365Fixed
from quantlib.time.schedule import Schedule, Backward
from quantlib.settings import Settings
from quantlib.termstructures.yields import (
    FlatForward, YieldTermStructure
)

todays_date = Date(25, August, 2011)


settings = Settings.instance()
settings.evaluation_date = todays_date

calendar = TARGET()
effective_date = Date(10, Jul, 2006)
termination_date = calendar.advance(
    effective_date, 10, Years, convention=Unadjusted
)


settlement_days = 3
face_amount = 100.0
coupon_rate = 0.05
redemption = 100.0

fixed_bond_schedule = Schedule(
    effective_date,
    termination_date,
    Period(Annual),
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
    forward         = 0.044,
    calendar        = NullCalendar(),
    daycounter      = Actual365Fixed(),
    compounding     = Continuous,
    frequency       = Annual)
discounting_term_structure.link_to(flat_term_structure)
pricing_engine = DiscountingBondEngine(discounting_term_structure)
bond.set_pricing_engine(pricing_engine)


print('Settlement date: ', bond.settlement_date())
print('Maturity date:', bond.maturity_date)
print('Accrued amount: ', bond.accrued_amount(bond.settlement_date()))
print('Clean price:', bond.clean_price)



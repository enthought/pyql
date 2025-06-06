""" Example demonstrating pricing bonds using PyQL.

This example is based on the QuantLib Excel bond demo.

"""
from quantlib.instruments.bonds import FixedRateBond
from quantlib.time.api import (
    Date, Period, Annual, TARGET, Unadjusted, ModifiedFollowing, Following, NullCalendar, Years,
    DateGeneration
)
from quantlib.compounding import Continuous
from quantlib.pricingengines.bond import DiscountingBondEngine
from quantlib.time.daycounters.simple import Actual365Fixed
from quantlib.time.daycounters.actual_actual import ActualActual, ISMA
from quantlib.time.schedule import Schedule
from quantlib.settings import Settings
from quantlib.termstructures.yields.api import (
    FlatForward, HandleYieldTermStructure
)

todays_date = Date(25, 8, 2011)


settings = Settings.instance()
settings.evaluation_date = todays_date

calendar = TARGET()
effective_date = Date(10, 7, 2006)
termination_date = calendar.advance(
    effective_date, 10, Years, convention=Unadjusted
)


settlement_days = 3
face_amount = 100.0
coupon_rate = 0.05
redemption = 100.0

fixed_bond_schedule = Schedule.from_rule(
    effective_date,
    termination_date,
    Period(Annual),
    calendar,
    ModifiedFollowing,
    ModifiedFollowing,
    DateGeneration.Backward
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

discounting_term_structure = HandleYieldTermStructure()
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
print('Clean price:', bond.clean_price())

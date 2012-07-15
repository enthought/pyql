import numpy as np

from ..compounding import Continuous
from ..instruments.bonds import FixedRateBond
from ..pricingengines.bond import DiscountingBondEngine
from ..settings import Settings
from ..time.api import (
    ActualActual, Schedule, TARGET, Period, Semiannual, Bond, Following,
    NullCalendar
)
from ..termstructures.yields.api import FlatForward, YieldTermStructure

def bond_price(yields, coupon_rate, settlement_date, maturity_date, period=2,
               day_counter=ActualActual(Bond), face_amount=100., issue_date=None
               ):
    """ Price a fixed income security from yield to maturity.

    :param yield: Bond yield to maturity is on a semiannual basis for basis
        values 0 through 7 and an annual basis for basis values 8 through 12.
    :param coupon_rate: Decimal number indicating the annual percentage rate
        used to determine the coupons payable on a bond.
    :param settlement_date: Settlement date. Settlement date must be earlier
        than maturity date.
    :param maturity_date: Maturity date.
    :param period: coupons per year for the bond. Defaults to 2
    :param day_counter: day-count basis of the instrument. Defauts to
        ActualActual(Bond)
    """

    if settlement_date > maturity_date:
        raise ValueError('Settlement date must be earlier than maturity date.')


    settings = Settings.instance()
    settings.evaluation_date =  settlement_date

    if issue_date is None:
        issue_date = settlement_date

    settlement_days = 2 #issue_date - settlement_date
    print settlement_days
    calendar = TARGET()

    redemption = face_amount


    fixed_bond_schedule = Schedule (
        settlement_date,
        maturity_date,
        Period(Semiannual),
        calendar
    )

    bond = FixedRateBond(
        settlement_days, face_amount, fixed_bond_schedule, [coupon_rate],
        ActualActual(Bond),
        Following, redemption, issue_date=issue_date
    )

    discounting_term_structure = YieldTermStructure(relinkable=True)

    engine = DiscountingBondEngine(discounting_term_structure)

    bond.set_pricing_engine(engine)

    if np.isscalar(yields):
        yields = np.atleast_1d(yields)

    output_price = np.empty_like(yields)
    output_accrued_interest = np.empty_like(yields)

    for i, y in enumerate(yields):
        flat_term_structure = FlatForward(
            settlement_days = settlement_days,
            forward         = y,
            calendar        = NullCalendar(),
            daycounter      = ActualActual(Bond),
            compounding     = Continuous,
            frequency       = Semiannual
        )
        discounting_term_structure.link_to(flat_term_structure)

        output_price[i] = bond.clean_price
        output_accrued_interest[i] = bond.accrued_amount(settlement_date)


    return output_price, output_accrued_interest




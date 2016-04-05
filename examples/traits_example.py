""" Simple example pricing a European option using a Black&Scholes Merton process."""

import datetime
from traits.api import HasTraits, Enum, Float, Date, Property, Range
from traitsui.api import View, Item, HGroup, EnumEditor

from quantlib.instruments.option import Put, Call, EuropeanExercise
from quantlib.instruments.payoffs import PlainVanillaPayoff
from quantlib.instruments.option import VanillaOption
from quantlib.pricingengines.vanilla import AnalyticEuropeanEngine
from quantlib.processes.black_scholes_process import BlackScholesMertonProcess
from quantlib.quotes import SimpleQuote
from quantlib.settings import Settings
from quantlib.time import TARGET, Actual365Fixed, today, Date as QlDate
from quantlib.termstructures.yields import FlatForward
from quantlib.termstructures.volatility.equityfx.black_vol_term_structure \
    import BlackConstantVol


settings = Settings.instance()
calendar = TARGET()

offset = 366

todays_date = today() - offset
settlement_date = todays_date + 2

settings.evaluation_date = todays_date


class OptionValuation(HasTraits):

    # options parameters
    option_type = Enum(Put, Call)
    underlying = Float(36)
    strike = Float(40)
    dividend_yield = Range(0.0, 0.5)
    risk_free_rate = Range(0.0, 0.2)
    volatility = Range(0.0, 0.5)
    maturity = Date(datetime.date.today())
    daycounter = Actual365Fixed()

    option_npv = Property(
        depends_on=[
            'option_type', 'underlying', 'strike', 'dividend_yield',
            'risk_free_rate', 'volatility', 'maturity'
        ]
    )

    ### Traits view   ##########################################################

    traits_view = View(
        Item('option_type', editor=EnumEditor(values={Put:'Put', Call:'Call'})),
        'underlying', 'strike', 'dividend_yield', 'risk_free_rate',
        'volatility', 'maturity',
        HGroup( Item('option_npv', label='Option value'))
    )

    ### Private protocol   #####################################################

    def _get_option_npv(self):
        """ Suboptimal getter for the npv.

        FIXME: We currently have to recreate most of the objects because we do not
        expose enough of the QuantLib api.

        """

        # convert datetime object to QlDate
        maturity = QlDate.from_datetime(self.maturity)

        underlyingH = SimpleQuote(self.underlying)

        # bootstrap the yield/dividend/vol curves
        flat_term_structure = FlatForward(
            reference_date = settlement_date,
            forward = self.risk_free_rate,
            daycounter = self.daycounter
        )

        flat_dividend_ts = FlatForward(
            reference_date = settlement_date,
            forward = self.dividend_yield,
            daycounter = self.daycounter
        )

        flat_vol_ts = BlackConstantVol(
            settlement_date, calendar, self.volatility, self.daycounter
        )

        black_scholes_merton_process = BlackScholesMertonProcess(
            underlyingH, flat_dividend_ts, flat_term_structure,flat_vol_ts
        )

        payoff = PlainVanillaPayoff(self.option_type, self.strike)

        european_exercise = EuropeanExercise(maturity)

        european_option = VanillaOption(payoff, european_exercise)

        analytic_european_engine = AnalyticEuropeanEngine(black_scholes_merton_process)

        european_option.set_pricing_engine(analytic_european_engine)

        return european_option.net_present_value

if __name__ == '__main__':

    model = OptionValuation()
    model.configure_traits()


### EOF #######################################################################

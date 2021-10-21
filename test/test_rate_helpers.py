import unittest

from quantlib.currency.api import USDCurrency
from quantlib.indexes.swap_index import SwapIndex
from quantlib.indexes.ibor.libor import Libor
from quantlib.indexes.api import Euribor3M, USDLibor, Eonia
from quantlib.quotes import SimpleQuote
from quantlib.termstructures.yields.rate_helpers import (
    DepositRateHelper, FraRateHelper, FuturesRateHelper, SwapRateHelper, FxSwapRateHelper
)
from quantlib.termstructures.yields.ois_rate_helper import OISRateHelper
from quantlib.termstructures.yields.api import YieldTermStructure, PiecewiseYieldCurve, FlatForward
from quantlib.math.interpolation import BackwardFlat, LogLinear
from quantlib.termstructures.yields.bootstraptraits import Discount, ForwardRate
from quantlib.time.api import (
    Period, Months, TARGET, ModifiedFollowing, Actual365Fixed, Date, Years,
    UnitedStates, Actual360, Annual, Following, NullCalendar, Days, Weeks,
    JointCalendar, Poland
)
from quantlib.settings import Settings

class RateHelpersTestCase(unittest.TestCase):

    def test_create_deposit_rate_helper(self):

        quote = SimpleQuote(0.0096)
        tenor = Period(3, Months)
        fixing_days = 3
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        deposit_day_counter = Actual365Fixed()


        helper_from_quote = DepositRateHelper(
            quote, tenor, fixing_days, calendar, convention, end_of_month,
            deposit_day_counter
        )

        ## create helper from float directly
        helper_from_float = DepositRateHelper(
            0.0096, tenor, fixing_days, calendar, convention, end_of_month,
            deposit_day_counter
        )
        self.assertIsNotNone(helper_from_quote, helper_from_float)
        self.assertEqual(quote.value, helper_from_quote.quote.value)
        self.assertEqual(helper_from_quote.quote.value, helper_from_float.quote.value)

    def test_relativedate_rate_helper(self):
        tenor = Period(3, Months)
        fixing_days = 3
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        deposit_day_counter = Actual365Fixed()

        helper = DepositRateHelper(
            0.005, tenor, fixing_days, calendar, convention, end_of_month,
            deposit_day_counter
        )
        Settings.instance().evaluation_date = Date(8, 6, 2016)
        self.assertEqual(helper.latest_date, Date(13, 9, 2016))

    def test_deposit_end_of_month(self):
        tenor = Period(3, Months)
        fixing_days = 0
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        deposit_day_counter = Actual365Fixed()

        helper_end_of_month = DepositRateHelper(
            0.005, tenor, fixing_days, calendar, convention, True,
            deposit_day_counter
        )
        helper_no_end_of_month = DepositRateHelper(
            0.005, tenor, fixing_days, calendar, convention, False,
            deposit_day_counter
        )
        Settings.instance().evaluation_date = Date(29, 2, 2016)
        self.assertEqual(helper_end_of_month.latest_date, Date(31, 5, 2016))
        self.assertEqual(helper_no_end_of_month.latest_date, Date(30, 5, 2016))



    def test_create_fra_rate_helper(self):

        quote = SimpleQuote(0.0096)
        month_to_start = 3
        month_to_end = 9
        fixing_days = 2
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        day_counter = Actual365Fixed()


        helper_from_quote = FraRateHelper(
            quote, month_to_start, month_to_end, fixing_days, calendar,
            convention, end_of_month, day_counter
        )
        helper_from_float = FraRateHelper(
            0.0096, month_to_start, month_to_end, fixing_days, calendar,
            convention, end_of_month, day_counter
        )
        self.assertIsNotNone(helper_from_float, helper_from_quote)
        self.assertEqual(quote.value, helper_from_quote.quote.value)
        self.assertEqual(helper_from_quote.quote.value, helper_from_float.quote.value)

    def test_create_futures_rate_helper(self):

        quote = SimpleQuote(0.0096)
        imm_date = Date(19, 12, 2001)
        length_in_months = 9
        calendar =  TARGET()
        convention = ModifiedFollowing
        end_of_month = True
        day_counter = Actual365Fixed()


        helper_from_quote = FuturesRateHelper(
            quote, imm_date, length_in_months, calendar,
            convention, end_of_month, day_counter
        )
        helper_from_float = FuturesRateHelper(
            0.0096, imm_date, length_in_months, calendar,
            convention, end_of_month, day_counter
        )

        self.assertIsNotNone(helper_from_float, helper_from_quote)
        self.assertEqual(quote.value, helper_from_quote.quote.value)
        self.assertEqual(helper_from_quote.quote.value, helper_from_float.quote.value)

    def test_create_swap_rate_helper_no_classmethod(self):

        with self.assertRaises(ValueError):
            SwapRateHelper()


    def test_create_swap_rate_helper_from_index(self):
        calendar = UnitedStates()
        settlement_days = 2
        currency = USDCurrency()
        fixed_leg_tenor	= Period(12, Months)
        fixed_leg_convention = ModifiedFollowing
        fixed_leg_daycounter = Actual360()
        family_name = currency.name + 'index'
        ibor_index =  Libor(
            "USDLibor", Period(3,Months), settlement_days, USDCurrency(),
            UnitedStates(), Actual360()
        )

        rate = SimpleQuote(0.005681)
        tenor = Period(1, Years)

        index = SwapIndex (
            family_name, tenor, settlement_days, currency, calendar,
            fixed_leg_tenor, fixed_leg_convention,
            fixed_leg_daycounter, ibor_index)

        helper_from_quote = SwapRateHelper.from_index(rate, index)
        helper_from_float = SwapRateHelper.from_index(0.005681, index)

        #self.fail(
        #    'Make this pass: create and ask for the .quote property'
        #    ' Test the from_index and from_tenor methods'
        #)

        self.assertIsNotNone(helper_from_quote, helper_from_float)
        self.assertAlmostEqual(rate.value, helper_from_quote.quote.value)
        self.assertAlmostEqual(helper_from_float.quote.value, helper_from_quote.quote.value)

        with self.assertRaises(RuntimeError):
            self.assertAlmostEqual(rate.value, helper_from_quote.implied_quote)

    def test_create_swap_rate_helper_from_tenor(self):
        calendar = UnitedStates()
        settlement_days = 2

        rate = SimpleQuote(0.005681)

        ibor_index =  Libor(
            "USDLibor", Period(3,Months), settlement_days, USDCurrency(),
            UnitedStates(), Actual360())
        helper_from_quote = SwapRateHelper.from_tenor(rate, Period(12, Months), calendar,
                                            Annual, ModifiedFollowing, Actual360(),
                                            ibor_index)
        helper_from_float =  SwapRateHelper.from_tenor(0.005681, Period(12, Months), calendar,
                                            Annual, ModifiedFollowing, Actual360(),
                                            ibor_index)

        self.assertIsNotNone(helper_from_float, helper_from_quote)
        self.assertEqual(rate.value, helper_from_quote.quote.value)
        self.assertEqual(helper_from_quote.quote.value, helper_from_float.quote.value)

        with self.assertRaises(RuntimeError):
            self.assertAlmostEqual(rate.value, helper_from_quote.implied_quote)


class FxSwapRateHelperTest(unittest.TestCase):

    def setUp(self):

        # Market rates are artificial, just close to real ones.
        self.default_quote_date = Date(26, 8, 2016)

        self.fx_swap_quotes = {
            (1, Months): 20e-4,
            (3, Months): 60e-4,
            (6, Months): 120e-4,
            (1, Years): 240e-4,
        }

        # Valid only for the quote date of Date(26, 8, 2016)
        self.maturities = [Date(30, 9, 2016), Date(30, 11, 2016),
                           Date(28, 2, 2017), Date(30, 8, 2017)]

        self.fx_spot_quote_EURPLN = 4.3
        self.fx_spot_quote_EURUSD = 1.1

    def build_eur_curve(self, quotes_date):
        """
        Builds the EUR OIS curve as the collateral currency discount curve
        :param quotes_date: date fro which it is assumed all market data are
            valid
        :return: tuple consisting of objects related to EUR OIS discounting
            curve: PiecewiseFlatForward,
                   YieldTermStructureHandle
                   RelinkableYieldTermStructureHandle
        """
        calendar = TARGET()
        settlementDays = 2

        todaysDate = quotes_date
        Settings.instance().evaluation_date = todaysDate

        todays_Eonia_quote = -0.00341

        # market quotes
        # deposits, key structure as (settlement_days_number, number_of_units_
        # for_maturity, unit)
        deposits = {(0, 1, Days): todays_Eonia_quote}

        discounting_yts_handle = YieldTermStructure()
        on_index = Eonia(discounting_yts_handle)
        on_index.add_fixing(todaysDate, todays_Eonia_quote / 100.0)

        ois = {
            (1, Weeks): -0.342,
            (1, Months): -0.344,
            (3, Months): -0.349,
            (6, Months): -0.363,
            (1, Years): -0.389,
        }

        # convert them to Quote objects
        for k, v in deposits.items():
            deposits[k] = SimpleQuote(v / 100.0)

        for k, v in ois.items():
            ois[k] = SimpleQuote(v / 100.0)

        # build rate helpers
        dayCounter = Actual360()
        # looping left if somone wants two add more deposits to tests, e.g. T/N

        depositHelpers = [
            DepositRateHelper(
                q,
                Period(n, unit),
                sett_num,
                calendar,
                ModifiedFollowing,
                True,
                dayCounter,
            )
            for (sett_num, n, unit), q in deposits.items()
        ]

        oisHelpers = [
            OISRateHelper(
                settlementDays, Period(n, unit),
                q, on_index, discounting_yts_handle
            )
            for (n, unit), q in ois.items()
        ]

        rateHelpers = depositHelpers + oisHelpers

        # term-structure construction
        oisSwapCurve = PiecewiseYieldCurve[ForwardRate, BackwardFlat].from_reference_date(todaysDate, rateHelpers,
                                                                                    Actual360())
        oisSwapCurve.extrapolation = True
        return oisSwapCurve

    def build_pln_fx_swap_curve(self, base_ccy_yts, fx_swaps, fx_spot):
        """
        Build curve implied from fx swap curve.
        :param base_ccy_yts:
            Relinkable yield term structure handle to curve in base currency.
        :param fx_swaps:
            Dictionary with swap points, already divided by 10,000
        :param fx_spot:
            Float value of fx spot exchange rate.
        :return: tuple consisting of objects related to fx swap implied curve:
                PiecewiseFlatForward,
                YieldTermStructureHandle
                RelinkableYieldTermStructureHandle
                list of FxSwapRateHelper
        """
        todaysDate = base_ccy_yts.reference_date
        # I am not sure if that is required, but I guss it is worth setting
        # up just in case somewhere another thread updates this setting.
        Settings.instance().evaluation_date = todaysDate

        calendar = JointCalendar(TARGET(), Poland())
        spot_date_lag = 2
        trading_calendar = UnitedStates()

        # build rate helpers
        spotFx = SimpleQuote(fx_spot)

        fxSwapHelpers = [
            FxSwapRateHelper(
                SimpleQuote(fx_swaps[(n, unit)]),
                spotFx,
                Period(n, unit),
                spot_date_lag,
                calendar,
                ModifiedFollowing,
                True,
                True,
                base_ccy_yts,
                trading_calendar,
            )
            for n, unit in fx_swaps
        ]

        # term-structure construction
        fxSwapCurve = PiecewiseYieldCurve[ForwardRate, BackwardFlat].from_reference_date(todaysDate, fxSwapHelpers,
                                           Actual365Fixed())
        fxSwapCurve.extrapolation = True
        return fxSwapCurve, fxSwapHelpers

    def build_curves(self, quote_date):
        """
        Build all the curves in one call for a specified quote date
        :param quote_date: date for which quotes are valid,
            e.g. Date(26, 8, 2016)
        """
        self.today = quote_date
        self.eur_ois_curve = self.build_eur_curve(self.today)
        self.pln_eur_implied_curve, self.eur_pln_fx_swap_helpers = self.build_pln_fx_swap_curve(self.eur_ois_curve, self.fx_swap_quotes, self.fx_spot_quote_EURPLN)

    def testQuote(self):
        """ Testing FxSwapRateHelper.quote()  method. """
        self.build_curves(self.default_quote_date)
        # Not sure if all Python versions and machine will guarantee that the
        #  lists are not messed, probably some ordered maps should be used
        # here while retrieving values from fx_swap_quotes dictionary
        for q, helper in zip(self.fx_swap_quotes.values(), self.eur_pln_fx_swap_helpers):
            self.assertEqual(q, helper.quote.value)

    def testLatestDate(self):
        """ Testing FxSwapRateHelper.latestDate()  method. """
        self.build_curves(self.default_quote_date)
        # Check if still the test date is unchanged, otherwise all other
        # tests here make no sense.
        self.assertEqual(self.today, Date(26, 8, 2016))

        # Hard coded expected maturities of fx swaps
        for m, helper in zip(self.maturities, self.eur_pln_fx_swap_helpers):
            self.assertEqual(m, helper.latest_date)

    def testImpliedRates(self):
        """
        Testing if rates implied from the curve are returning fx forwards
        very close to those used for bootstrapping
        """
        self.build_curves(self.default_quote_date)
        # Not sure if all Python versions and machine will guarantee that the
        #  lists are not messed, probably some ordered maps should be used
        # here while retrieving values from fx_swap_quotes dictionary
        original_quotes = list(self.fx_swap_quotes.values())
        spot_date = Date(30, 8, 2016)
        spot_df = self.eur_ois_curve.discount(
            spot_date) / self.pln_eur_implied_curve.discount(spot_date)

        for original_quote, maturity in zip(original_quotes, self.maturities):
            original_forward = self.fx_spot_quote_EURPLN + original_quote
            curve_impl_forward = (
                    self.fx_spot_quote_EURPLN
                    * self.eur_ois_curve.discount(maturity)
                    / self.pln_eur_implied_curve.discount(maturity)
                    / spot_df
            )

            self.assertAlmostEqual(original_forward, curve_impl_forward,
                                   places=6)

    def testFxMarketConventionsForCrossRate(self):
        """
        Testing if FxSwapRateHelper obeys the fx spot market
        conventions for cross rates.
        """
        today = Date(1, 7, 2016)
        spot_date = Date(5, 7, 2016)
        self.build_curves(today)

        us_calendar = UnitedStates()

        joint_calendar = JointCalendar(TARGET(), Poland())

        settlement_calendar = JointCalendar(joint_calendar, us_calendar)

        # Settlement should be on a day where all three centers are operating
        #  and follow EndOfMonth rule
        maturities = [
            settlement_calendar.advance(spot_date, n, unit,
                                        convention=ModifiedFollowing, end_of_month=True)
            for n, unit in self.fx_swap_quotes
        ]

        for m, helper in zip(maturities, self.eur_pln_fx_swap_helpers):
            self.assertEqual(m, helper.latest_date)

    def testFxMarketConventionsForCrossRateONPeriod(self):
        """
        Testing if FxSwapRateHelper obeys the fx spot market
        conventions for cross rates' ON Period.
        """
        today = Date(1, 7, 2016)
        Settings.instance().evaluation_date = today

        spot_date = Date(5, 7, 2016)
        fwd_points = 4.0
        # critical for ON rate helper
        on_period = Period("1d")
        fixing_days = 0

        # empty RelinkableYieldTermStructureHandle is sufficient for testing
        # dates
        base_ccy_yts = YieldTermStructure()

        us_calendar = UnitedStates()

        joint_calendar = JointCalendar(TARGET(), Poland())

        # Settlement should be on a day where all three centers are operating
        #  and follow EndOfMonth rule
        on_rate_helper = FxSwapRateHelper(
            SimpleQuote(fwd_points),
            SimpleQuote(self.fx_spot_quote_EURPLN),
            on_period,
            fixing_days,
            joint_calendar,
            ModifiedFollowing,
            False,
            True,
            base_ccy_yts,
            us_calendar,
        )

        self.assertEqual(spot_date, on_rate_helper.latest_date)

    def testFxMarketConventionsForCrossRateAdjustedSpotDate(self):
        """
        Testing if FxSwapRateHelper obeys the fx spot market
        conventions
        """
        today = Date(30, 6, 2016)
        spot_date = Date(5, 7, 2016)
        self.build_curves(today)
        us_calendar = UnitedStates()
        joint_calendar = JointCalendar(TARGET(), Poland())

        settlement_calendar = JointCalendar(joint_calendar, us_calendar)
        # Settlement should be on a day where all three centers are operating
        #  and follow EndOfMonth rule
        maturities = [
            joint_calendar.advance(spot_date, n, unit, convention=ModifiedFollowing,
                                   end_of_month=True)
            for n, unit in self.fx_swap_quotes
        ]

        maturities = [settlement_calendar.adjust(date) for date in maturities]

        for helper, maturity in zip(self.eur_pln_fx_swap_helpers, maturities):
            self.assertEqual(maturity, helper.latest_date)

    def testFxMarketConventionsForDatesInEURUSD_ON_Period(self):
        """
        Testing if FxSwapRateHelper obeys the fx spot market
        conventions for EURUSD settlement dates on the ON Period.
        """
        today = Date(1, 7, 2016)
        Settings.instance().evaluation_date = today

        spot_date = Date(5, 7, 2016)
        fwd_points = 4.0
        # critical for ON rate helper
        on_period = Period("1d")
        fixing_days = 0

        # empty RelinkableYieldTermStructureHandle is sufficient for testing
        # dates
        base_ccy_yts = YieldTermStructure()

        # In EURUSD, there must be two days to spot date in Target calendar
        # and one day in US, therefore it is sufficient to pass only Target
        # as a base calendar
        calendar = TARGET()
        trading_calendar = UnitedStates()

        on_rate_helper = FxSwapRateHelper(
            SimpleQuote(fwd_points),
            SimpleQuote(self.fx_spot_quote_EURUSD),
            on_period,
            fixing_days,
            calendar,
            ModifiedFollowing,
            False,
            True,
            base_ccy_yts,
            trading_calendar,
        )

        self.assertEqual(spot_date, on_rate_helper.latest_date)

    def testFxMarketConventionsForDatesInEURUSD_ShortEnd(self):
        """
        Testing if FxSwapRateHelper obeys the fx spot market
        conventions for EURUSD settlement dates on the 3M tenor.
        """
        today = Date(1, 7, 2016)
        Settings.instance().evaluation_date = today

        expected_3M_date = Date(5, 10, 2016)
        fwd_points = 4.0
        # critical for ON rate helper
        period = Period("3M")
        fixing_days = 2

        # empty RelinkableYieldTermStructureHandle is sufficient for testing
        # dates
        base_ccy_yts = YieldTermStructure()

        # In EURUSD, there must be two days to spot date in Target calendar
        # and one day in US, therefore it is sufficient to pass only Target
        # as a base calendar. Passing joint calendar would result in wrong
        # spot date of the trade
        calendar = TARGET()
        trading_calendar = UnitedStates()

        rate_helper = FxSwapRateHelper(
            SimpleQuote(fwd_points),
            SimpleQuote(self.fx_spot_quote_EURUSD),
            period,
            fixing_days,
            calendar,
            ModifiedFollowing,
            True,
            True,
            base_ccy_yts,
            trading_calendar,
        )

        self.assertEqual(expected_3M_date, rate_helper.latest_date)

    def tearDown(self):
        Settings.instance().evaluation_date = Date()


def flat_rate(rate):
    return FlatForward(
        settlement_days=0, calendar=NullCalendar(), forward=SimpleQuote(rate), daycounter=Actual365Fixed())


if __name__ == '__main__':
    unittest.main()

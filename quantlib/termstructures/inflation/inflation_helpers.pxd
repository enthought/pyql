#ifndef quantlib_inflation_helpers_hpp
#define quantlib_inflation_helpers_hpp

#include <ql/termstructures/bootstraphelper.hpp>
#include <ql/termstructures/inflationtermstructure.hpp>
#include <ql/instruments/zerocouponinflationswap.hpp>
#include <ql/instruments/yearonyearinflationswap.hpp>

namespace QuantLib {

    //! Zero-coupon inflation-swap bootstrap helper
    class ZeroCouponInflationSwapHelper
    : public BootstrapHelper<ZeroInflationTermStructure> {
    public:
        ZeroCouponInflationSwapHelper(
            const Handle<Quote>& quote,
            const Period& swapObsLag,   // lag on swap observation of index
            const Date& maturity,
            const Calendar& calendar,   // index may have null calendar as valid on every day
            BusinessDayConvention paymentConvention,
            const DayCounter& dayCounter,
            const boost::shared_ptr<ZeroInflationIndex>& zii);

        void setTermStructure(ZeroInflationTermStructure*);
        Real impliedQuote() const;
    protected:
        Period swapObsLag_;
        Date maturity_;
        Calendar calendar_;
        BusinessDayConvention paymentConvention_;
        DayCounter dayCounter_;
        boost::shared_ptr<ZeroInflationIndex> zii_;
        boost::shared_ptr<ZeroCouponInflationSwap> zciis_;
    };


    //! Year-on-year inflation-swap bootstrap helper
    class YearOnYearInflationSwapHelper
    : public BootstrapHelper<YoYInflationTermStructure> {
    public:
        YearOnYearInflationSwapHelper(const Handle<Quote>& quote,
                                      const Period& swapObsLag_,
                                      const Date& maturity,
                                      const Calendar& calendar,
                                      BusinessDayConvention paymentConvention,
                                      const DayCounter& dayCounter,
                                      const boost::shared_ptr<YoYInflationIndex>& yii);

        void setTermStructure(YoYInflationTermStructure*);
        Real impliedQuote() const;
    protected:
        Period swapObsLag_;
        Date maturity_;
        Calendar calendar_;
        BusinessDayConvention paymentConvention_;
        DayCounter dayCounter_;
        boost::shared_ptr<YoYInflationIndex> yii_;
        boost::shared_ptr<YearOnYearInflationSwap> yyiis_;
    };

}

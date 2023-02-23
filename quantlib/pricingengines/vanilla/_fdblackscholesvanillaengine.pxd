from libcpp cimport bool
from quantlib.handle cimport shared_ptr
from quantlib.types cimport Size, Real
from quantlib.instruments._option cimport DividendVanillaOption
from quantlib.instruments._dividendschedule cimport DividendSchedule
from quantlib.processes._black_scholes_process cimport GeneralizedBlackScholesProcess
from quantlib.methods.finitedifferences.solvers._fdmbackwardsolver cimport FdmSchemeDesc

cdef extern from 'ql/pricingengines/vanilla/fdblackscholesvanillaengine.hpp' namespace 'QuantLib::FdBlackScholesVanillaEngine':
    cdef enum CashDividendModel:
        Spot
        Escrowed

cdef extern from 'ql/pricingengines/vanilla/fdblackscholesvanillaengine.hpp' namespace 'QuantLib':

    cdef cppclass FdBlackScholesVanillaEngine(DividendVanillaOption.engine):
        enum CashDividendModel:
            pass

        FdBlackScholesVanillaEngine(
            shared_ptr[GeneralizedBlackScholesProcess]&,
            Size tGrid, # = 100,
            Size xGrid, # = 100,
            Size dampingSteps, # = 0,
            const FdmSchemeDesc& schemeDesc, # = FdmSchemeDesc::Douglas(),
            bool localVol, # = false,
            Real illegalLocalVolOverwrite, # = -Null<Real>(),
            CashDividendModel cashDividendModel) # = Spot)

        FdBlackScholesVanillaEngine(
            shared_ptr[GeneralizedBlackScholesProcess]&,
            DividendSchedule dividends,
            Size tGrid, # = 100,
            Size xGrid, # = 100,
            Size dampingSteps, # = 0,
            const FdmSchemeDesc& schemeDesc, # = FdmSchemeDesc::Douglas(),
            bool localVol, # = false,
            Real illegalLocalVolOverwrite, # = -Null<Real>(),
            CashDividendModel cashDividendModel) # = Spot)

        # FdBlackScholesVanillaEngine(
        #     const shared_ptr[GeneralizedBlackScholesProcess]&,
        #     const shared_ptr[FdmQuantoHelper]& quantoHelper,
        #     Size tGrid, # = 100,
        #     Size xGrid, # = 100,
        #     Size dampingSteps, # = 0,
        #     const FdmSchemeDesc& schemeDesc, # = FdmSchemeDesc::Douglas(),
        #     bool localVol, # = false,
        #     Real illegalLocalVolOverwrite, # = -Null<Real>(),
        #     CashDividendModel cashDividendModel) # = Spot)

        void calculate()

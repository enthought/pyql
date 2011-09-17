#include "ql_settings.hpp"
#include <ql/quantlib.hpp>
#include <iostream>
#include <iomanip>

using namespace QuantLib;


static FixedRateBond* get_bond_for_evaluation_date(
        Date &in_date
) {
  Date        evaluation_date;
  Calendar    calendar;
  Date        effective_date;
  Date        termination_date;
  Natural     settlement_days;
  Real        face_amount;
  Real        coupon_rate;
  Real        redemption;
  Schedule    fixed_bond_schedule;
  Date        issue_date;

  std::vector<Rate>* coupons;

  FixedRateBond*    bond;

  QL::set_evaluation_date(in_date);

  evaluation_date = QL::get_evaluation_date();

  std::cout << "Current evaluation date:" << evaluation_date << std::endl;

  calendar = QuantLib::TARGET();

  effective_date = Date(10, QuantLib::Jul, 2006);

  termination_date = calendar.advance(
        effective_date, 10, Years, Unadjusted, 0
   );

  settlement_days = 3;
  face_amount = 100.0;
  coupon_rate = 0.05;
  redemption = 100.0;

  fixed_bond_schedule = Schedule(
        effective_date, termination_date, Period(Annual), calendar, 
        ModifiedFollowing, ModifiedFollowing, DateGeneration::Backward, 0
  );

  issue_date = Date(10, Jul, 2006);
    
  coupons = new std::vector<Rate>();

  coupons->push_back(coupon_rate);

  bond = new FixedRateBond(
       settlement_days, face_amount, fixed_bond_schedule, *coupons, 
       ActualActual(ActualActual::ISMA), Following, redemption, issue_date
  );

 return bond;
}


static bool test_bond_schedule_today_cython()
{
  Date           today;
  Calendar       calendar;
  FixedRateBond* bond;
  Date          s_date;
  Date          b_date;

  today = Date::todaysDate();
  calendar = TARGET();

   bond = get_bond_for_evaluation_date(today);

  s_date = calendar.advance(today, 3, Days, Following, 0);

  b_date = bond->settlementDate();

  if (s_date != b_date) {
      std::cout << "Dates are not equivalent " 
           << s_date 
           << " vs " 
           << b_date 
           << std::endl;
      return false;
  }
  return true;


}

static bool test_bond_schedule_anotherday_cython()
{

  Date              last_month;
  Date              today;
  FixedRateBond*    bond;
  Calendar          calendar;
  Date              s_date;
  Date              b_date;
  Date              e_date;
  
  last_month = Date(30, August, 2011);

  today = Date::endOfMonth(last_month);

  bond = get_bond_for_evaluation_date(today);

  calendar = TARGET();

  s_date = calendar.advance(today, 3, Days, Following, 0);

  b_date = bond->settlementDate();

  e_date = QL::get_evaluation_date();

  if (s_date != b_date) {
      std::cout << "Dates are not equivalent " 
           << s_date 
           << " vs " 
           << b_date 
           << std::endl;
      return false;
   }
  
   if (today != e_date) {
      std::cout << "Evaluation dates are not equivalent " 
           << today 
           << " vs " 
           << e_date 
           << std::endl;
      return false;
  }
   return true;
} 


int main(int, char* [])
{
   if (test_bond_schedule_today_cython()) 
       std::cout << "Test 1 passed" << std::endl;
   else std::cout << "Very very weird. This should pass" << std::endl;
   if (test_bond_schedule_anotherday_cython())
       std::cout << "Test 2 passed" << std::endl;
   else std::cout << "Bug replicated" << std::endl;
   return 0;
}


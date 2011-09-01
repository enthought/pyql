#ifndef __PYX_HAVE__quantlib__time__date
#define __PYX_HAVE__quantlib__time__date


/* "quantlib/time/date.pyx":22
 *     void* memcpy ( void* destination, void* source, size_t num )
 * 
 * cdef public enum Month:             # <<<<<<<<<<<<<<
 *     January   = _date.January
 *     February  = _date.February
 */
enum Month {

  /* "quantlib/time/date.pyx":45
 *     Oct = _date.Oct
 *     Nov = _date.Nov
 *     Dec = _date.Dec             # <<<<<<<<<<<<<<
 * 
 * cdef public enum Weekday:
 */
  January = QuantLib::January,
  February = QuantLib::February,
  March = QuantLib::March,
  April = QuantLib::April,
  May = QuantLib::May,
  June = QuantLib::June,
  July = QuantLib::July,
  August = QuantLib::August,
  September = QuantLib::September,
  October = QuantLib::October,
  November = QuantLib::November,
  December = QuantLib::December,
  Jan = QuantLib::Jan,
  Feb = QuantLib::Feb,
  Mar = QuantLib::Mar,
  Apr = QuantLib::Apr,
  Jun = QuantLib::Jun,
  Jul = QuantLib::Jul,
  Aug = QuantLib::Aug,
  Sep = QuantLib::Sep,
  Oct = QuantLib::Oct,
  Nov = QuantLib::Nov,
  Dec = QuantLib::Dec
};

/* "quantlib/time/date.pyx":47
 *     Dec = _date.Dec
 * 
 * cdef public enum Weekday:             # <<<<<<<<<<<<<<
 *     Sunday   = _date.Sunday
 *     Monday   = _date.Monday
 */
enum Weekday {

  /* "quantlib/time/date.pyx":61
 *     Thu = _date.Thu
 *     Fri = _date.Fri
 *     Sat = _date.Sat             # <<<<<<<<<<<<<<
 * 
 * cdef public enum Frequency:
 */
  Sunday = QuantLib::Sunday,
  Monday = QuantLib::Monday,
  Tuesday = QuantLib::Tuesday,
  Wednesday = QuantLib::Wednesday,
  Thursday = QuantLib::Thursday,
  Friday = QuantLib::Friday,
  Saturday = QuantLib::Saturday,
  Sun = QuantLib::Sun,
  Mon = QuantLib::Mon,
  Tue = QuantLib::Tue,
  Wed = QuantLib::Wed,
  Thu = QuantLib::Thu,
  Fri = QuantLib::Fri,
  Sat = QuantLib::Sat
};

/* "quantlib/time/date.pyx":63
 *     Sat = _date.Sat
 * 
 * cdef public enum Frequency:             # <<<<<<<<<<<<<<
 *     NoFrequency      = _period.NoFrequency # null frequency
 *     Once             = _period.Once  # only once, e.g., a zero-coupon
 */
enum Frequency {

  /* "quantlib/time/date.pyx":76
 *     Weekly           = _period.Weekly # once a week
 *     Daily            = _period.Daily # once a day
 *     OtherFrequency   = _period.OtherFrequency # some other unknown frequency             # <<<<<<<<<<<<<<
 * 
 * cdef public enum TimeUnit:
 */
  NoFrequency = QuantLib::NoFrequency,
  Once = QuantLib::Once,
  Annual = QuantLib::Annual,
  Semiannual = QuantLib::Semiannual,
  EveryFourthMonth = QuantLib::EveryFourthMonth,
  Quarterly = QuantLib::Quarterly,
  Bimonthly = QuantLib::Bimonthly,
  Monthly = QuantLib::Monthly,
  EveryFourthWeek = QuantLib::EveryFourthWeek,
  Biweekly = QuantLib::Biweekly,
  Weekly = QuantLib::Weekly,
  Daily = QuantLib::Daily,
  OtherFrequency = QuantLib::OtherFrequency
};

/* "quantlib/time/date.pyx":78
 *     OtherFrequency   = _period.OtherFrequency # some other unknown frequency
 * 
 * cdef public enum TimeUnit:             # <<<<<<<<<<<<<<
 *     Days   = _period.Days
 *     Weeks  = _period.Weeks
 */
enum TimeUnit {

  /* "quantlib/time/date.pyx":82
 *     Weeks  = _period.Weeks
 *     Months = _period.Months
 *     Years  = _period.Years             # <<<<<<<<<<<<<<
 * 
 * cdef extern from "string" namespace "std":
 */
  Days = QuantLib::Days,
  Weeks = QuantLib::Weeks,
  Months = QuantLib::Months,
  Years = QuantLib::Years
};

#ifndef __PYX_HAVE_API__quantlib__time__date

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

#endif /* !__PYX_HAVE_API__quantlib__time__date */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initdate(void);
#else
PyMODINIT_FUNC PyInit_date(void);
#endif

#endif /* !__PYX_HAVE__quantlib__time__date */

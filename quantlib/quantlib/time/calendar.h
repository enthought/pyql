#ifndef __PYX_HAVE__quantlib__time__calendar
#define __PYX_HAVE__quantlib__time__calendar


/* "quantlib/time/calendar.pyx":11
 * 
 * # BusinessDayConvention:
 * cdef public enum BusinessDayConvention:             # <<<<<<<<<<<<<<
 *     Following         = _calendar.Following
 *     ModifiedFollowing = _calendar.ModifiedFollowing
 */
enum BusinessDayConvention {

  /* "quantlib/time/calendar.pyx":16
 *     Preceding         = _calendar.Preceding
 *     ModifiedPreceding = _calendar.ModifiedPreceding
 *     Unadjusted        = _calendar.Unadjusted             # <<<<<<<<<<<<<<
 * 
 * 
 */
  Following = QuantLib::Following,
  ModifiedFollowing = QuantLib::ModifiedFollowing,
  Preceding = QuantLib::Preceding,
  ModifiedPreceding = QuantLib::ModifiedPreceding,
  Unadjusted = QuantLib::Unadjusted
};

#ifndef __PYX_HAVE_API__quantlib__time__calendar

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

#endif /* !__PYX_HAVE_API__quantlib__time__calendar */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initcalendar(void);
#else
PyMODINIT_FUNC PyInit_calendar(void);
#endif

#endif /* !__PYX_HAVE__quantlib__time__calendar */

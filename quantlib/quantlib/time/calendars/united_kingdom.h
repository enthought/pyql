#ifndef __PYX_HAVE__quantlib__time__calendars__united_kingdom
#define __PYX_HAVE__quantlib__time__calendars__united_kingdom


/* "quantlib/time/calendars/united_kingdom.pyx":5
 * from quantlib.time.calendar cimport Calendar
 * 
 * cdef public enum Market:             # <<<<<<<<<<<<<<
 *     SETTLEMENT = _uk.Settlement
 *     EXCHANGE   = _uk.Exchange
 */
enum Market {

  /* "quantlib/time/calendars/united_kingdom.pyx":8
 *     SETTLEMENT = _uk.Settlement
 *     EXCHANGE   = _uk.Exchange
 *     METALS     = _uk.Metals             # <<<<<<<<<<<<<<
 * 
 * cdef class UnitedKingdom(Calendar):
 */
  SETTLEMENT = QuantLib::UnitedKingdom::Settlement,
  EXCHANGE = QuantLib::UnitedKingdom::Exchange,
  METALS = QuantLib::UnitedKingdom::Metals
};

#ifndef __PYX_HAVE_API__quantlib__time__calendars__united_kingdom

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

#endif /* !__PYX_HAVE_API__quantlib__time__calendars__united_kingdom */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initunited_kingdom(void);
#else
PyMODINIT_FUNC PyInit_united_kingdom(void);
#endif

#endif /* !__PYX_HAVE__quantlib__time__calendars__united_kingdom */

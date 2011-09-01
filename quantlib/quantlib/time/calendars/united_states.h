#ifndef __PYX_HAVE__quantlib__time__calendars__united_states
#define __PYX_HAVE__quantlib__time__calendars__united_states


/* "quantlib/time/calendars/united_states.pyx":5
 * from quantlib.time.calendar cimport Calendar
 * 
 * cdef public enum Market:             # <<<<<<<<<<<<<<
 *     SETTLEMENT     = _us.Settlement # generic settlement calendar
 *     NYSE           = _us.NYSE # New York stock exchange calendar
 */
enum Market {

  /* "quantlib/time/calendars/united_states.pyx":9
 *     NYSE           = _us.NYSE # New York stock exchange calendar
 *     GOVERNMENTBOND = _us.GovernmentBond # government-bond calendar
 *     NERC           = _us.NERC # off-peak days for NERC             # <<<<<<<<<<<<<<
 * 
 * cdef class UnitedStates(Calendar):
 */
  SETTLEMENT = QuantLib::UnitedStates::Settlement,
  NYSE = QuantLib::UnitedStates::NYSE,
  GOVERNMENTBOND = QuantLib::UnitedStates::GovernmentBond,
  NERC = QuantLib::UnitedStates::NERC
};

#ifndef __PYX_HAVE_API__quantlib__time__calendars__united_states

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

#endif /* !__PYX_HAVE_API__quantlib__time__calendars__united_states */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initunited_states(void);
#else
PyMODINIT_FUNC PyInit_united_states(void);
#endif

#endif /* !__PYX_HAVE__quantlib__time__calendars__united_states */

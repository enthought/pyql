#ifndef __PYX_HAVE__quantlib__time__daycounters__actual_actual
#define __PYX_HAVE__quantlib__time__daycounters__actual_actual


/* "quantlib/time/daycounters/actual_actual.pyx":19
 * from quantlib.time.daycounter cimport DayCounter
 * 
 * cdef public enum Convention:             # <<<<<<<<<<<<<<
 *     ISMA       = _aa.ISMA
 *     Bond       = _aa.Bond
 */
enum Convention {

  /* "quantlib/time/daycounters/actual_actual.pyx":26
 *     Actual365  = _aa.Actual365
 *     AFB        = _aa.AFB
 *     Euro       = _aa.Euro             # <<<<<<<<<<<<<<
 * 
 * cdef class ActualActual(DayCounter):
 */
  ISMA = QuantLib::ActualActual::ISMA,
  Bond = QuantLib::ActualActual::Bond,
  ISDA = QuantLib::ActualActual::ISDA,
  Historical = QuantLib::ActualActual::Historical,
  Actual365 = QuantLib::ActualActual::Actual365,
  AFB = QuantLib::ActualActual::AFB,
  Euro = QuantLib::ActualActual::Euro
};

#ifndef __PYX_HAVE_API__quantlib__time__daycounters__actual_actual

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

#endif /* !__PYX_HAVE_API__quantlib__time__daycounters__actual_actual */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initactual_actual(void);
#else
PyMODINIT_FUNC PyInit_actual_actual(void);
#endif

#endif /* !__PYX_HAVE__quantlib__time__daycounters__actual_actual */

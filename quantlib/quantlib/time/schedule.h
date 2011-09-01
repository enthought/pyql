#ifndef __PYX_HAVE__quantlib__time__schedule
#define __PYX_HAVE__quantlib__time__schedule


/* "quantlib/time/schedule.pyx":12
 * 
 * 
 * cdef public enum Rule:             # <<<<<<<<<<<<<<
 *     # Backward from termination date to effective date.
 *     Backward       = _schedule.Backward
 */
enum Rule {

  /* "quantlib/time/schedule.pyx":37
 *     # Credit derivatives standard rule since 'Big Bang' changes
 *     # in 2009.
 *     CDS            = _schedule.CDS             # <<<<<<<<<<<<<<
 * 
 * cdef class Schedule:
 */
  Backward = QuantLib::DateGeneration::Backward,
  Forward = QuantLib::DateGeneration::Forward,
  Zero = QuantLib::DateGeneration::Zero,
  ThirdWednesday = QuantLib::DateGeneration::ThirdWednesday,
  Twentieth = QuantLib::DateGeneration::Twentieth,
  TwentiethIMM = QuantLib::DateGeneration::TwentiethIMM,
  OldCDS = QuantLib::DateGeneration::OldCDS,
  CDS = QuantLib::DateGeneration::CDS
};

#ifndef __PYX_HAVE_API__quantlib__time__schedule

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

#endif /* !__PYX_HAVE_API__quantlib__time__schedule */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initschedule(void);
#else
PyMODINIT_FUNC PyInit_schedule(void);
#endif

#endif /* !__PYX_HAVE__quantlib__time__schedule */

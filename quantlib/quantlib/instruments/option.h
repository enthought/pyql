#ifndef __PYX_HAVE__quantlib__instruments__option
#define __PYX_HAVE__quantlib__instruments__option


/* "quantlib/instruments/option.pyx":14
 * from quantlib.pricingengines.vanilla cimport VanillaOptionEngine
 * 
 * cdef public enum OptionType:             # <<<<<<<<<<<<<<
 *     Put = _option.Put
 *     Call = _option.Call
 */
enum OptionType {

  /* "quantlib/instruments/option.pyx":16
 * cdef public enum OptionType:
 *     Put = _option.Put
 *     Call = _option.Call             # <<<<<<<<<<<<<<
 * 
 * cdef public enum ExerciseType:
 */
  Put = QuantLib::Option::Put,
  Call = QuantLib::Option::Call
};

/* "quantlib/instruments/option.pyx":18
 *     Call = _option.Call
 * 
 * cdef public enum ExerciseType:             # <<<<<<<<<<<<<<
 *     American = _exercise.American
 *     Bermudan  = _exercise.Bermudan
 */
enum ExerciseType {

  /* "quantlib/instruments/option.pyx":21
 *     American = _exercise.American
 *     Bermudan  = _exercise.Bermudan
 *     European = _exercise.European             # <<<<<<<<<<<<<<
 * 
 * cdef class Exercise:
 */
  American = QuantLib::Exercise::American,
  Bermudan = QuantLib::Exercise::Bermudan,
  European = QuantLib::Exercise::European
};

#ifndef __PYX_HAVE_API__quantlib__instruments__option

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

#endif /* !__PYX_HAVE_API__quantlib__instruments__option */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initoption(void);
#else
PyMODINIT_FUNC PyInit_option(void);
#endif

#endif /* !__PYX_HAVE__quantlib__instruments__option */

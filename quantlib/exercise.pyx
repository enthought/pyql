from cython.operator cimport dereference as deref, preincrement as preinc
from libcpp cimport bool
from libcpp.vector cimport vector
from quantlib.handle cimport shared_ptr
from quantlib.time.date cimport Date, _pydate_from_qldate
from quantlib.time._date cimport Date as QlDate

cdef class Exercise:

    American = Type.American
    Bermudan = Type.Bermudan
    European = Type.European

    def __str__(self):
        return "Exercise type: {}".format(self.type.name)

    @property
    def last_date(self):
        return _pydate_from_qldate(self._thisptr.get().lastDate())

    def dates(self):
        cdef vector[QlDate].const_iterator it = self._thisptr.get().dates().const_begin()
        cdef list r = []
        while it != self._thisptr.get().dates().end():
            r.append(_pydate_from_qldate(deref(it)))
            preinc(it)

    @property
    def type(self):
       return self._thisptr.get().type()

cdef class EuropeanExercise(Exercise):

    def __init__(self, Date exercise_date not None):
        self._thisptr.reset(
            new _exercise.EuropeanExercise(
                exercise_date._thisptr
            )
        )

cdef class AmericanExercise(Exercise):

    def __init__(self, Date latest_exercise_date, Date earliest_exercise_date=None):
        """ Creates an AmericanExercise.

        :param latest_exercise_date: Latest exercise date for the option
        :param earliest_exercise_date: Earliest exercise date for the option (default to None)

        """
        if earliest_exercise_date is not None:
            self._thisptr = shared_ptr[_exercise.Exercise]( \
                new _exercise.AmericanExercise(
                    earliest_exercise_date._thisptr,
                    latest_exercise_date._thisptr
                )
            )
        else:
            self._thisptr = shared_ptr[_exercise.Exercise]( \
                new _exercise.AmericanExercise(
                    latest_exercise_date._thisptr
                )
            )


cdef class BermudanExercise(Exercise):
    def __init__(self, list dates, bool payoff_at_expiry=False):
        """ Bermudan exercise

        A Bermudan option can only be exercised at a set of fixed dates.

        Parameters
        ----------
        dates : list of exercise dates
        payoff_at_expiry : bool
        """
        cdef vector[QlDate] c_dates
        for d in dates:
            c_dates.push_back((<Date?>d)._thisptr)
        self._thisptr.reset(
            new _exercise.BermudanExercise(c_dates,
                                           payoff_at_expiry)
        )

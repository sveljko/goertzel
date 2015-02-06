/* -*- c-file-style:"stroustrup"; indent-tabs-mode: nil -*- */

#if !defined INC_GOERTZEL
#define      INC_GOERTZEL

#include <cstdlib>
#include <cmath>
#include <utility>
#include <cassert>


/** The Goertzel filter implementation in pure C++. It is designed
    with speed and portability in mind.

    This provides both the static methods for "pure Goertzel
    calculations" and regular methods for representing a
    Goertzel filter with an object of this class.
 */
template <class T>
class GoertzelFilter {
    /** The frequency of the filter */
    T f_;
    /** The sampling frequency */
    T fs_;
    /** The Goertzel coefficient, calculate from frequencies */
    T koef_;
    /** Past results of the Goertzel recursive formula */
    std::pair<T,T> vn_;
    
public:
    /** Constructor takes the frequency of the filter and the
        sampling frequency.
    */
    GoertzelFilter(T f, T fs) : f_(f), fs_(fs) {
        assert(f < fs/2);
        koef_ = calc_koef(f, fs);
        vn_.first = vn_.second = 0;
        reset();
    }
    
    /** Resets the filter for a new calculation */
    void reset() {
        vn_.first = vn_.second = 0.0;
    }
    
    /** Returns the frequency of the filter */
    T get_f() const {
        return f_;
    }
    
    /** Anything less than this is meaningless */
    static const T EPSILON = 0.000000001;
    
    /** The "kernel" of the Goertzel recursive calculation.
        @param sample Array of samples to pass through the filter
        @param k The Goertzel coefficient
        @param vn Previous (two) results - on output, the new two results
    */
    static std::pair<T,T> kernel(T sample[], size_t n, T k, std::pair<T,T> vn) {
        for (int i = 0; i < n; ++i) {
            T t = k * vn.first - vn.second + sample[i];
            vn.second = vn.first;
            vn.first = t;
        }
        return vn;
    }

    /// Helper function for arrays of samples of compile-time-known
    /// size
    template <size_t N>
    static std::pair<T,T> kernel(T (&sample)[N], T k, std::pair<T,T> vn) {
        return kernel(sample, N, vn);
    }
    
    /** Calculate the power of the signal that was passed through
        the filter.
        @param koef The Goertzel coefficient
        @paarm vn Previous (two) results
        @param n The number of samples that have passed through the
        filter
    */
    static double power(T koef, std::pair<T,T> vn, int n) {
        assert(n > 0);
        T rslt = vn.first*vn.first + vn.second*vn.second - koef * vn.first * vn.second;
        if (rslt < EPSILON) {
            rslt = EPSILON;
        }
        return rslt / (n*n);
    }
 
    /** The 'dBm', or 'dBmW' - decibel-milliwatts, a power ratio in dB
        (decibels) of the (given) measured power referenced to one (1)
        milliwat (mW).

        This uses the audio/telephony usual 600 Ohm impedance.
    */
    static T dBm(T power) {
        return 10 * log10(2 * power * 1000 / 600.0);
    }
    
    /** Calculates the Goertzel coefficient for the given frequency
        of the filter and the sampling frequency.
    */
    static T calc_koef(T f, T fs) {
        return 2 * cos(2 * M_PI * f / fs);
    }
    
    /** Process the given array of samples on this filter.
        @return The current power of the signal passed through the
        filter (from the start).
    */
    T process(T samples[], size_t n) {
        vn_ = kernel(samples, n, koef_, vn_);
        return power(koef_, vn_, n);
    }

    /// Helper function for arrays of samples of compile-time-known
    /// size
    template<size_t N> T process(T (&samples)[N]) {
        return process(samples, N);
    }
};


#endif // !defined INC_GOERTZEL

/* -*- c-file-style:"stroustrup"; indent-tabs-mode: nil -*- */
#if !defined INC_GOERTZEL
#define      INC_GOERTZEL

#include <stdlib.h>


/** The Goertzel filter implementation in pure C. It is designed with
    speed and portability in mind.
    
    This provides both the function for "pure Goertzel calculations"
    and for manipulating a Goertzel filter struct.
 */

/** Helper class to hold previous two results. */
struct GoertzelFilter_Vn {
    /** Previous result */
    double _1;
    /** Result before the previous */
    double _2;
};
  
/** Data of a Goertzel filter 
 */
struct GoertzelFilter {   
    /** The frequency of the filter */
    double f;
    /** The sampling frequency */
    double fs;
    /** The Goertzel coefficient, calculate from frequencies */
    double koef;
    /** Past results of the Goertzel recursive formula */
    struct GoertzelFilter_Vn vn;
};

/** Anything less than this is meaningless */
#if !defined EPSILON
#define EPSILON 0.000000001
#endif


/** Construct a Goertzel filter using the frequency of the filter and
    the sampling frequency.
*/
struct GoertzelFilter makeGoertzelFilter(double f, double fs);
    
/** Resets the filter for a new calculation */
void GoertzelFilter_Reset(struct GoertzelFilter *pf);
   
/** The "kernel" of the Goertzel recursive calculation.
    @param sample Array of samples to pass through the filter
    @param n Number of samples
    @param k The Goertzel coefficient
    @param vn Previous (two) results
    @return The new two results
*/
struct GoertzelFilter_Vn GoertzelFilter_kernel(double sample[], size_t n, double k, struct GoertzelFilter_Vn vn);
   

/** Calculate the power of the signal that was passed through
    the Goertzel filter.
    @param koef The Goertzel coefficient
    @paarm vn Previous (two) results
    @param n The number of samples that have passed through the
    filter
*/
double GoertzelFilter_power(double koef, struct GoertzelFilter_Vn vn, int n);
 
/** The 'dBm', or 'dBmW' - decibel-milliwatts, a power ratio in dB
    (decibels) of the (given) measured power referenced to one (1)
    milliwat (mW).
    
    This uses the audio/telephony usual 600 Ohm impedance.
*/
double calc_dBm(double power);
    
/** Calculates the Goertzel coefficient for the given frequency
    of the filter and the sampling frequency.
*/
double GoertzelFilter_koef(double f, double fs);
    
/** Process the given array of samples on this filter.
    @return The current power of the signal passed through the
    filter (from the start).
*/
double GoertzelFilter_process(struct GoertzelFilter *pGF, double samples[], size_t n);


#endif /* !defined INC_GOERTZEL */

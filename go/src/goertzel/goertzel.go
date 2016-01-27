/* 
	The Goertzel filter implementation in pure Go. It is designed
	with speed and portability in mind.

	This provides both the functions for "pure Goertzel calculations"
	and methods for representing a Goertzel filter with an object of
	this class.  
*/
package goertzel

import "math"


// Helper class to hold previous two results.
type Vn struct {
	_1 float64
	_2 float64
}

// Goertzel Filter data
type Filter struct {
	// The frequency of the filter
	f float64
	// The sampling frequency
	fs float64
	// The Goertzel coefficient, calculate from frequencies
	koef float64
	// Past results of the Goertzel recursive formula
	vn Vn
}

// Kernel of the Goertzel recursive calculation. Uses `sample`
// as the slice of samples to pass through the filter, `k` as the
// Goertzel coefficient, and `vn` as the previous (two) results -
// on output, the new two results .
func Kernel(sample []float64, k float64, vn *Vn) { 
	for _, x := range sample { 
		t := k * vn._1 - vn._2 + x 
		vn._2 = vn._1 
		vn._1 = t 
	}
}


// Power function calculates the power of the signal that was passed
// through the filter. Using the filter coefficient, the last two results
// and the number of samples passed through the filter.
func Power(koef float64, vn Vn, n int) (result float64) {
	result = (vn._1*vn._1 + vn._2*vn._2 - koef*vn._1*vn._2) / float64(n*n)
	return
}


/* Calc_dBm calculates the power of the signal that was passed through the
filter. Using the filter coefficient, the last two results and the
number of samples passed through the filter.  
*/
func Calc_dBm(power float64) (result float64) {
	result = 10 * math.Log10(2 * power * 1000 / 600)
	return
}

/* Calc_koef Calculates the Goertzel filter coefficient for a given
frequency and sampling frequency
*/
func Calc_koef(f float64, fs float64) (result float64) {
	result = 2 * math.Cos(2*math.Pi * f / fs)
	return
}

/* Process the given samples on the filter, returning the
    power of the signal.
*/
func (flt *Filter) Process(samples []float64) (result float64) {
	Kernel(samples, flt.koef, &flt.vn)
	result = Power(flt.koef, flt.vn, len(samples))
	return
}

/* reset the filter, so that new samples that are processed
"start from the beginning".
*/
func (flt Filter) reset() {
	flt.vn._1 = 0
	flt.vn._2 = 0
}

/* Make and return a filter for the given frequency and sampling 
frequency */
func Make(f float64, fs float64) (result Filter) {
	result.f = f
	result.fs = fs
	result.koef = Calc_koef(f, fs)
	result.reset()
	return
}

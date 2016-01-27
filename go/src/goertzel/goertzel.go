package goertzel

import "math"


type Vn struct {
	_1 float64
	_2 float64
}
type Filter struct {
	f float64
	fs float64
	koef float64
	vn Vn
}

func kernel(sample []float64, k float64, vn *Vn) {
	for _, x := range sample {
		t := k * vn._1 - vn._2 + x
		vn._2 = vn._1
		vn._1 = t
	}
}

func Power(koef float64, vn Vn, n int) (result float64) {
	result = (vn._1*vn._1 + vn._2*vn._2 - koef*vn._1*vn._2) / float64(n*n)
	return
}

func Calc_dBm(power float64) (result float64) {
	result = 10 * math.Log10(2 * power * 1000 / 600)
	return
}

func Calc_koef(f float64, fs float64) (result float64) {
	result = 2 * math.Cos(2*math.Pi * f / fs)
	return
}

func (flt *Filter) Process(samples []float64) (result float64) {
	kernel(samples, flt.koef, &flt.vn)
	result = Power(flt.koef, flt.vn, len(samples))
	return
}

func (flt Filter) reset() {
	flt.vn._1 = 0
	flt.vn._2 = 0
}

func Make(f float64, fs float64) (result Filter) {
	result.f = f
	result.fs = fs
	result.koef = Calc_koef(f, fs)
	result.reset()
	return
}

fn calc_koef(f: f64, fs: f64) -> f64 {
    assert!(f < fs / 2.0);
    assert!(fs > 0.0);
    2.0 * (2.0 * std::f64::consts::PI * f / fs).cos()
}

/// Helper for remembering the last two filter "running values" for
/// the Geortzel filter implemented as an IIR filter.
#[derive(Copy, Clone, Debug)]
pub struct Vn {
    _1: f64,
    _2: f64
}

/// Holds data for a Goertzel filter
#[derive(Debug)]
pub struct Filter {
    /// The frequency of the filter
    f: f64,
    /// The sampling frequency
    fs: f64,
    /// The Goertzel coefficient, calulcated
    /// from the above mentioned frequencies
    koef: f64,
    /// The running values of the Goertzel filter calculation.
    vn: Vn
}

impl Filter {
    /// Returns a Goertzel filter for the given parameters
    /// * `f` The frequency of the filter
    /// * `fs`  The sampling frequency of the samples to process
    pub fn new(f: f64, fs: f64) -> Filter {
	Filter {
	    f: f,
	    fs: fs,
	    koef: calc_koef(f, fs),
	    vn: Vn{_1: 0.0, _2: 0.0}
	}
    }
    
    /// Resets the filter so that we can start it over again.
    pub fn reset(&mut self) {
	self.vn._1 = 0.0;
	self.vn._2 = 0.0;
    }
    
    /// Process the samples using the filter.
    /// Returns the resulting power of the signal at the filter frequency
    pub fn process(&mut self, sample: &[f64]) -> f64 {
	kernel(sample, self.koef, &mut self.vn);
	power(self.koef, self.vn, sample.len())
    }
}

/// The "kernel" of the Gortzel filter as an IIR filter
pub fn kernel(sample: &[f64], k: f64, vn: &mut Vn) {
    for x in sample.iter() {
	let t = k * vn._1 - vn._2 + x;
	vn._2 = vn._1;
	vn._1 = t;
    }
}

/// Returns the power of the signal that has passed through a Goertzel
/// filter.
pub fn power(k: f64, vn: Vn, n: usize) -> f64 {
    let mut rslt = vn._1 * vn._1 + vn._2 * vn._2 - k * vn._1 * vn._2;
    if rslt < f64::EPSILON  {
	rslt = f64::EPSILON;
    }
    rslt / (n*n) as f64
}

/// Returns the dBm of the given power of a signal
pub fn dbm(power: f64) -> f64 {
    10.0 * (2.0 * power * 1000.0 / 600.0).log10()
}

mod goertzel;

pub fn main() {
    let mut flt = goertzel::Filter::new(2000.0, 8000.0);
    let samples: [f64; 4] = [ 0.0, 1.0, 0.0, -1.0 ];
    let y = flt.process(&samples);
    println!("{:?}:\n {}", flt, goertzel::dbm(y));
}

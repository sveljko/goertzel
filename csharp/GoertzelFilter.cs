/* -*- indent-tabs-mode: nil -*- */
using System;

/// <summary>
/// The Goertzel filter implementation in pure C#. 
/// </summary>
/// <remarks>
///   <para>
///      It is designed with speed and portability in mind.  
///   </para>
///   <para>
///    This provides both the static methods for "pure Goertzel
///    calculations" and regular methods for representing a Goertzel
///    filter with an object of this class.
///   </para>
/// </remarks>
public class GoertzelFilter {
    /// <summary>
    /// Helper class to hold previous two results.
    /// </summary>
    public struct Vn {
        /// Previous result
        public double _1;
        /// Result before the previous
        public double _2;
    }
    
    private double f_;
    /// <summary>
    ///   The frequency of the filter
    /// </summary> 
    public double f { get { return f_;} }

    private double fs_;
    /// <summary>
    ///   The sampling frequency used by the filter
    /// </summary> 
    public double fs { get { return fs_; } }

    /// <summary>
    ///   The Goertzel coefficient, calculate from frequencies
    /// </summary>
    double koef_;

    /// <summary>
    /// Past results of the Goertzel recursive formula  
    /// </summary>
    Vn vn_;
    
    /// <summary>
    ///   Constructor takes the frequency of the filter and the
    ///   sampling frequency.
    /// </summary> 
    public GoertzelFilter(double i_f, double i_fs) {
        f_ = i_f;
        fs_ = i_fs;
        koef_ = calc_koef(f, fs);
        Reset();
    }
    
    /// <summary>
    ///   Resets the filter for a new calculation
    /// </summary>
    public void Reset() {
        vn_._1 = vn_._2 = 0.0;
    }
    
    /// <summary>
    /// The "kernel" of the Goertzel recursive calculation.  
    /// </summary>
    /// <param name="sample">Array of samples to pass through the filter</param>
    /// <param name="k"> The Goertzel coefficient </param>
    /// <param name="vn"> Previous (two) results</param>
    /// <returns>The new value of "previous two results" </returns>
    public static Vn kernel(double[] sample, double k, Vn vn) {
        foreach (double x in sample) {
            double t = k * vn._1 - vn._2 + x;
            vn._2 = vn._1;
            vn._1 = t;
        }
        return vn;
    }
    
    /// <summary>
    /// Calculate the power of the signal that was passed through
    /// the filter.  
    /// </summary>
    /// <param name="koef"> The Goertzel coefficient </param>
    /// <param name="vn"> Previous (two) results</param>
    /// <param name="n"> The number of samples that have passed through the
    /// filter </param>
    /// <returns> The calculated power </returns>
    static double power(double koef, Vn vn, int n) {
        double rslt = vn._1*vn._1 + vn._2*vn._2 - koef * vn._1 * vn._2;
        if (rslt < Double.Epsilon) {
            rslt = Double.Epsilon;
        }
        return rslt / (n*n);
    }
 
    /// <summary>
    ///   The 'dBm', or 'dBmW' - decibel-milliwatts, a power ratio in dB
    ///   (decibels) of the (given) measured power referenced to one (1)
    ///   milliwat (mW).
    /// </summary> 
    /// <remarks>
    ///   <para>
    ///   This uses the audio/telephony usual 600 Ohm impedance.    
    ///   </para>
    /// </remarks>
    public static double dBm(double power) {
        return 10 * Math.Log10(2 * power * 1000 / 600.0);
    }
    
    /// <summary>
    ///   Calculates the Goertzel coefficient for the given frequency
    ///   of the filter and the sampling frequency.
    /// </summary> 
    public static double calc_koef(double f, double fs) {
        return 2 * Math.Cos(2 * Math.PI * f / fs);
    }
    
    /// <summary>
    ///   Process the given array of samples on this filter.
    /// </summary> 
    /// <returns> The current power of the signal passed through the
    /// filter (from the start). 
    /// </returns>
    public double Process(double[] samples) {
        vn_ = kernel(samples, koef_, vn_);
        return power(koef_, vn_, samples.Length);
    }

    /// <summary>
    ///   Let's print nicely
    /// </summary>
    public override string ToString() {
        return "GoertzelFilter: f=" + f + ", fs= " + fs + ", k= " + koef_ + ", Vn-1= " + vn_._1 + ", Vn-2= " + vn_._2;
    }
}

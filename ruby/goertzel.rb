# -*- indent-tabs-mode: nil -*-

# Goertzel filter implementation in pure Ruby.  This provides both the
# static methods for "pure Goertzel calculations" and a class
# representing a Goertzel filter with an object of this class.
module Goertzel

  # Anything less than this is meaningless
  EPSILON = 0.000000001

  # The "kernel" of the Goertzel recursive calculation.
  # Processes +samples+ array of samples to pass through the filter,
  # using the +k+ the Goertzel coefficient and the 
  # previous (two) results - +v_n_1+ and +v_n_2+.
  # Returns the two new results.
  def kernel(samples, koef, v_n_1, v_n_2)
    samples.each { |x|
      v_n_1, v_n_2 = koef*v_n_1 - v_n_2 + x, v_n_1
    }
    return v_n_1, v_n_2
  end

  # Calculates (and returns) the 'dBm', or 'dBmW' -
  # decibel-milliwatts, a power ratio in dB (decibels) of the (given)
  # measured power referenced to one (1) milliwat (mW).
  #
  # This uses the audio/telephony usual 600 Ohm impedance.
  def dBm(koef, v_n_1, v_n_2, n)
    ampX = v_n_1**2 + v_n_2**2 - koef*v_n_1*v_n_2
    ampX = EPSILON if ampX < EPSILON
    10 * Math.log10(2 * ampX * 1000 / (600*n**2))
  end

  # Processe the given +samples+ with the given +koef+ Goertzel
  # coefficient, returning the dBm of the signal (represented,
  # in full, by the +samples+).
  def processSamplesKoef(samples, koef)
    v_n_1, v_n_2 = kernel(samples, koef, 0, 0)
    dBm(koef, v_n_1, v_n_2, samples.length)
  end

  # Calculates the Goertzel coefficient for the given frequency
  # of the filter and the sampling frequency.
  def calc_koef(f, fs)
    2 * Math.cos(2 * Math::PI * f / fs)
  end

  # Processe the given +samples+ with the given Goertzel filter
  # frequency +f+ and sample frequency +fs+, returning the dBm of the
  # signal (represented, in full, by the +samples+).
  def processSamples(samples, f, fs)
    processSamplesKoef(samples, calc_koef(f, fs))
  end

  # Helper class representing a Goertzel filter
  class Filter

    include Goertzel

    # The frequency of the filter
    attr_accessor :f
   
    # To construct, give the frequency of the filter and the
    # sampling frequency
    def initialize(f, fs)
      raise 'f is too big' if f >= fs / 2
      @f, @fs = f, fs
      @koef = calc_koef(f, fs)
      reset
    end

    # Reset for a new calculation
    def reset
      @v_n_1 = @v_n_2 = 0
    end

    # Process the given array of samples, return dBm
    def process(samples)
      @v_n_1, @v_n_2 = kernel(samples, @koef, @v_n_1, @v_n_2)
      dBm(@koef, @v_n_1, @v_n_2, samples.length)
    end
  end
  
  # Helper class to do Goertzel algorithm sample by sample
  class SampleBySample

    # I need Frequency, sampling frequency and the number of
    # samples that we shall process
    def initialize(f, fs, n)
      @f, @fs, @n = f, fs, n
      @koef = 2 * Math.cos(2 * Math::PI * f / fs)
      @cntSamples = 0
      @v_n_1 = @v_n_2 = 0
    end

    # Do one sample. Returns dBm of the input if this is the final
    # sample, or nil otherwise.
    def processSample(x)
      @v_n_1, @v_n_2 = @koef*@v_n_1 - @v_n_2 + x, @v_n_1
      @cntSamples += 1

      if @cntSamples == @n
        @cntSamples = 0
        
        return dBm(@koef, @v_n_1, @v_n_2, @n)
      end

      nil
    end

  end

end


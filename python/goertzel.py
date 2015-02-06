# -*- indent-tabs-mode: nil -*-

"""Goertzel filter implementation in pure Python.  This provides both
the static methods for "pure Goertzel calculations" and a class
representing a Goertzel filter with an object of this class.

"""

import math

# Anything less than this is meaningless
EPSILON = 0.000000001


class Goertzel:
    """Contains static methods for Goertzel calculations and represents a
    "classic" Goertzel filter.

    """

    @staticmethod
    def kernel(samples, koef, v_n1, v_n2):
        """The "kernel" of the Goertzel recursive calculation.  Processes
        `samples` array of samples to pass through the filter, using the
        `k` Goertzel coefficient and the previous (two) results -
        `v_n1` and `v_n2`.  Returns the two new results.

        """

        for samp in samples:
            v_n1, v_n2 = koef*v_n1 - v_n2 + samp, v_n1
        return v_n1, v_n2

    @staticmethod
    def dbm(koef, v_n1, v_n2, nsamp):
        """Calculates (and returns) the 'dBm', or 'dBmW' - decibel-milliwatts,
        a power ratio in dB (decibels) of the (given) measured power
        referenced to one (1) milliwat (mW).

        This uses the audio/telephony usual 600 Ohm impedance.

        """
        amp_x = v_n1**2 + v_n2**2 - koef*v_n1*v_n2
        if amp_x < EPSILON:
            amp_x = EPSILON
        return 10 * math.log10(2 * amp_x * 1000 / (600*nsamp**2))

    @staticmethod
    def proc_samples_k(samples, koef):
        """Processe the given `samples` with the given `koef` Goertzel
        coefficient, returning the dBm of the signal (represented, in full,
        by the `samples`).

        """
        v_n1, v_n2 = Goertzel.kernel(samples, koef, 0, 0)
        return Goertzel.dbm(koef, v_n1, v_n2, len(samples))

    @staticmethod
    def calc_koef(freq, fsamp):
        """Calculates the Goertzel coefficient for the given frequency of the
        filter and the sampling frequency.

        """
        return 2 * math.cos(2 * math.pi * freq / fsamp)

    @staticmethod
    def process_samples(samples, freq, fsamp):
        """Processe the given +samples+ with the given Goertzel filter
        frequency `freq` and sample frequency `fsamp`, returning the
        dBm of the signal (represented, in full, by the `samples`).

        """
        return Goertzel.proc_samples_k(samples, Goertzel.calc_koef(freq, fsamp))

    def __init__(self, freq, fsamp):
        """To construct, give the frequency of the filter and the sampling
        frequency

        """
        if freq >= fsamp / 2:
            raise Exception("f is too big")
        self.freq, self.fsamp = freq, fsamp
        self.koef = Goertzel.calc_koef(freq, fsamp)
        self.vn1 = self.vn2 = 0

    def reset(self):
        """Reset for a new calculation"""
        self.vn1 = self.vn2 = 0

    def process(self, smp):
        """Process the given array of samples, return dBm"""
        self.vn1, self.vn2 = Goertzel.kernel(smp, self.koef, self.vn1, self.vn2)
        return Goertzel.dbm(self.koef, self.vn1, self.vn2, len(smp))


class GoertzelSampleBySample:
    """Helper class to do Goertzel algorithm sample by sample"""

    def __init__(self, freq, fsamp, nsamp):
        """I need Frequency, sampling frequency and the number of
        samples that we shall process"""
        self.freq, self.fsamp, self.nsamp = freq, fsamp, nsamp
        self.koef = 2 * math.cos(2 * math.pi * freq / fsamp)
        self.cnt_samples = 0
        self.vn1 = self.vn2 = 0

    def process_sample(self, samp):
        """Do one sample. Returns dBm of the input if this is the final
        sample, or None otherwise."""
        self.vn1, self.vn2 = self.koef*self.vn1 - self.vn2 + samp, self.vn1
        self.cnt_samples += 1
        if self.cnt_samples == self.nsamp:
            self.cnt_samples = 0

            return Goertzel.dbm(self.koef, self.vn1, self.vn2, self.nsamp)

        return None

    def reset(self):
        """Reset for a new calculation"""
        self.vn1 = self.vn2 = 0

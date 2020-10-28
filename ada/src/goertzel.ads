-- @summary
-- Goertzel filter in pure Ada/Spark
--
-- @description
-- An implementation of the Goertzel filter.
-- It is designed with speed and portability in mind.  
package Goertzel with
   SPARK_Mode => On
is

   -- The type for (most of the) values used. That is, samples, values
   -- derived from samples, frequencies and the like.
   type Value is digits 8;
   
   -- Maximum number of samples handled
   Max_Samples : constant := 1000;
   
   -- The type for the range of possible number of samples
   type Sample_Count is new Integer range 1..Max_Samples;
   
   -- Helper for remembering the last two filter "running values" for
   -- the Geortzel filter implemented as an IIR filter.
   type Vn2 is
      record
         -- The previous filter value
         M1: Value;
         -- The value before that
         M2: Value;
      end record;
   
   -- Holds data for a Goertzel filter
   type Filter is
      record
	 -- The frequency of the filter
         F: Value;
	 -- The sampling frequency
         Fs: Value;
	 -- The Goertzel coefficient, calulcated
	 -- from the above mentioned frequencies
         Koef: Value;
	 -- The running values of the Goertzel filter calculation.
         Vn: Vn2;
      end record;
   
   -- An array of samples to process
   type Samples is array (Positive range <>) of Value;
   
   -- Makes a Goertzel filter for the given parameters
   -- @param F The frequency of the filter
   -- @param Fs  The sampling frequency of the samples to process
   -- @return the filter made
   function Make(F, Fs: Value) return Filter
     with 
       Pre => (Fs < 100_000.0) and (F < Fs / 2.0) and (Fs > 0.0);
   
   -- Resets the filter so that we can start it over again.
   -- @param Flt The filter to reset
   procedure Reset(Flt: in out Filter);
   
   -- Process the samples using the given filter 
   -- @param Flt The filter to use
   -- @param Sample The Samples to process
   -- @param Rslt The resulting power of the signal at the filter frequency
   procedure Process(Flt: in out Filter; Sample: Samples; Rslt: out Value)
     with
       Pre => (Sample'Length in Sample_Count'Range);
   
   -- Returns the dBm of the given power of a signal
   -- @param Power The power to convert to dBm
   -- @result The calculated dBm
   function DBm(Power: Value) return Value 
     with
       Pre => Power > 0.0;
   
end Goertzel;

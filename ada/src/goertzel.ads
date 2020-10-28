-- @ummary
-- Goertzel filter in pure Ada/Spark
--
-- @description
-- An implementation of the Goertzel filter.
-- It is designed with speed and portability in mind.  
package Goertzel with
   SPARK_Mode => On
is

   -- The type for (most of the) values used 
   type Value is digits 8;
   
   -- Maximum number of samples handled
   Max_Samples : constant := 1000;
   
   -- The type for the range of possible number of samples
   type Sample_Count is new Integer range 1..Max_Samples;
   
   -- Helper for remembering the last two filter "running values"
   type Vn2 is
      record
         M1: Value;
         M2: Value;
      end record;
   
   -- Holds data for a Goertzel filter
   type Filter is
      record
         F: Value;
         Fs: Value;
         Koef: Value;
         Vn: Vn2;
      end record;
   
   -- An array of samples to process
   type Samples is array (Positive range <>) of Value;
   
   -- Makes (returns) a Goertzel filter for the given frequency (F)
   -- and sampling frequency (Fs)
   function Make(F, Fs: Value) return Filter
     with 
       Pre => (Fs < 100_000.0) and (F < Fs / 2.0) and (Fs > 0.0);
   
   -- Resets the filter so that we can start it over
   procedure Reset(Flt: in out Filter);
   
   -- Process the samples using the filter `Flt`, with the resulting
   -- power of the signal at the filter frequency being put into `Rslt`
   procedure Process(Flt: in out Filter; Sample: Samples; Rslt: out Value);
   
   -- Returns the dBm of the given power of a signal
   function DBm(Power: Value) return Value 
     with
       Pre => Power > 0.0;
   
end Goertzel;

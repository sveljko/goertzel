with Ada.Numerics.Generic_Elementary_Functions;

package body goertzel with
  SPARK_Mode => On
is

   package Ef is new Ada.Numerics.Generic_Elementary_Functions(Value);
   use Ef;

   function Calc_Koef(F, Fs: Value) return Value  is (2.0 * Cos(2.0 * Ada.Numerics.Pi * F / Fs))
     with
       Pre => (Fs < 100_000.0) and (F < Fs / 2.0) and (Fs > 0.0);


   procedure Reset(Vn: out Vn2) is
   begin
      Vn.m1 := 0.0;
      Vn.m2 := 0.0;
   end;


   function Make(F, Fs: Value) return Filter is ( F, Fs, Calc_Koef(F, Fs), (0.0, 0.0) );


   procedure Reset(Flt: in out Filter) is
   begin
      Reset(Flt.Vn);
   end;


   procedure Kernel(Sample: Samples; K: Value; Vn: in out Vn2) is
      T: Value;
   begin
      for I in Sample'Range loop
         T := K * Vn.m1 - Vn.m2 + Sample(I);
         Vn.m2 := Vn.m1;
         Vn.m1 := T;
      end loop;
   end;


   function Power(Koef: Value; Vn: Vn2; N: Sample_Count) return Value
   is
      Rslt: Value;
   begin
      Rslt := Vn.m1 * Vn.m1 + Vn.m2* Vn.m2 - Koef * Vn.m1 * Vn.m2;
      if Rslt < Value'Model_Epsilon then Rslt := Value'Model_Epsilon; end if;
      return Rslt / Value(N*N);
   end Power;


   function DBm(Power: Value) return Value is (10.0 * Log(2.0 * Power * 1000.0 / 600.0, 10.0));


   procedure Process(Flt: in out Filter; Sample: Samples; Rslt: out Value) is
   begin
      Kernel(Sample, Flt.Koef, Flt.Vn);
      Rslt := Power(Flt.Koef, Flt.Vn, Sample'Length);
   end Process;


end goertzel;

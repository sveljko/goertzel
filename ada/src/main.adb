with Goertzel;
with Ada.Text_Io;

procedure Main is
   Flt : Goertzel.Filter;
   Samples : Goertzel.Samples := ( 0.0, 1.0, 0.0, Goertzel.Value(-1.0) );
   Y : Goertzel.Value;
begin
   Flt := Goertzel.Make(2000.0, 8000.0);
   Goertzel.Process(Flt, Samples, y);
   Y := Goertzel.DBm(Y);
   Ada.Text_IO.Put_Line(Y'Image);
end Main;

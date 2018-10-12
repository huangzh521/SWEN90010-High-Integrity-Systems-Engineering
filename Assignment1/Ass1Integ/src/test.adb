with ClosedLoop;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure test is
begin
   ClosedLoop.Init;
   for I in Integer range 0..1000 loop
      ClosedLoop.Tick;
      --delay 0.1;
   end loop;


end test;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with Network;
with Principal;

-- this package implements the functionality of
-- the on mode of the system. That is, it provides
-- the necessary calculations of the
-- impulse based on the measured heart rate.
Package body ICD is
   -- The value of heart rate
   HeartRate : Measures.BPM;
   LastSixRate : array (Integer range 1..6) of Measures.BPM;
   NumReading : Integer := 0;
   ImpulseRate : Measures.BPM;
   ImpulseInterval : Integer;
   TickToNextImpulse : Integer;
   Signal : Integer := 0; -- The number of signals has been delivered
   Impulse : Measures.BPM;

   procedure Init(Icd : out ICDType) is
   begin
      Icd.IsOn := False;
      Icd.TachyBound := INITIAL_TACHY_BOUND;
      Icd.JoulesToDeliver := INITIAL_JOULES;
      Icd.IsTachycardia := False;
      Icd.IsFibrillation := False;
      Icd.IsDelivering := False;
   end Init;


   -- In the on mode, the closed-loop functionality of the device is on,
   -- meaning that impulses may be delivered to the patient,
   -- and settings cannot be changed
   procedure On(Icd : in out ICDType; Monitor : in out HRM.HRMType;
                Gen : in out ImpulseGenerator.GeneratorType;
                Hrt : in Heart.HeartType) is
   begin
      Icd.IsOn := True;
      HRM.On(Monitor, Hrt);
      ImpulseGenerator.On(Gen);

      -- Read and print the current measured heart rate
      HRM.GetRate(Monitor, HeartRate);
      Put("Measured heart rate  = ");
      Put(Item => HeartRate);
      New_Line;

      UpdateRateArray(Icd);
--        Put("   This last 6 Rate  ");
--        Put(Item => LastSixRate(1));
--        Put(Item => LastSixRate(2));
--        Put(Item => LastSixRate(3));
--        Put(Item => LastSixRate(4));
--        Put(Item => LastSixRate(5));
--        Put(Item => LastSixRate(6));
--        New_Line;

      -- Deliver impulse for Fibrillation first or Tachy first ???
      Icd.IsFibrillation := IsFibrillation(Icd);
      Icd.IsTachycardia := IsTachycardia(Icd);
      if Icd.IsFibrillation and not Icd.IsDelivering then
         Put_Line("A ventricular fibrillation is detected ");
         ImpulseGenerator.SetImpulse(Gen, Icd.JoulesToDeliver);
      elsif Icd.IsTachycardia and not Icd.IsDelivering then
         Put_Line("A ventricular tachycardia is detected ");
         CalculateInterval(Icd);
         DeliverSignals(Icd, Gen);
      elsif Icd.IsDelivering then
         DeliverSignals(Icd, Gen);
      end if;
   end On;

   function IsTachycardia(Icd : in out ICDType) return Boolean is
   begin
      -- check whether the heart rate is higher than the upper bound
      if HeartRate >= Icd.TachyBound then
         return True;
      else
         return False;
      end if;
   end IsTachycardia;


   procedure CalculateInterval(Icd : in out ICDType) is
   begin
      Icd.IsDelivering := True;
      ImpulseRate := HeartRate + ABOVE_HEART_RATE;
      ImpulseInterval := TICKS_PER_MINUTE / ImpulseRate - 1;
   end CalculateInterval;


   procedure DeliverSignals(Icd : in out ICDType;
                            Gen : in out ImpulseGenerator.GeneratorType) is
   begin
      if Signal < NUM_SIGNAL then
         if TickToNextImpulse = 0 then
            Impulse := JOULES_PER_SIGNAL;
            ImpulseGenerator.SetImpulse(Gen, Impulse);
            Signal := Signal + 1;
            TickToNextImpulse := ImpulseInterval;

            Put("Impulse signal  = ");
            Put(Item => Signal);
            New_Line;
         else
            Impulse := 0;
            ImpulseGenerator.SetImpulse(Gen, Impulse);
            TickToNextImpulse := TickToNextImpulse - 1;
         end if;
      end if;
      if Signal = NUM_SIGNAL then
         Icd.IsDelivering := False;
         Signal := 0;
         TickToNextImpulse := 0;
      end if;
   end DeliverSignals;


   function IsFibrillation(Icd : in out ICDType) return Boolean is
      AverageChange : Measures.BPM;
      SumOfChange : Measures.BPM := 0;
   begin
      -- Check if there are six previous readings
      if NumReading < LastSixRate'Last then
         return false;
      else
         for I in 1..LastSixRate'Length-1 loop
            SumOfChange := SumOfChange + abs(LastSixRate(I+1) - LastSixRate(I));
         end loop;
         AverageChange := SumOfChange / LastSixRate'Length;
         Put_Line("Average change of six readings is ");
         Put(item => AverageChange);
         New_Line;
         if AverageChange >= FIBR_BOUND then
            return True;
         else
            return False;
         end if;
      end if;
   end IsFibrillation;


   procedure UpdateRateArray(Icd : in out ICDType) is
   begin
      if NumReading < LastSixRate'Last then
         NumReading := NumReading + 1;
         LastSixRate(NumReading) := HeartRate;
      else
         for I in LastSixRate'Range loop
            if I = LastSixRate'Last then
               LastSixRate(I) := HeartRate;
            else
               LastSixRate(I) := LastSixRate(I+1);
            end if;
         end loop;
      end if;
   end UpdateRateArray;

   procedure Off(Icd : in out ICDType; Monitor : in out HRM.HRMType;
                 Gen : in out ImpulseGenerator.GeneratorType) is
   begin
      Icd.IsOn := False;
      HRM.Off(Monitor);
      ImpulseGenerator.Off(Gen);
   end Off;


   procedure Tick(Icd : in out ICDType; Monitor : in out HRM.HRMType;
                  Gen : in out ImpulseGenerator.GeneratorType;
                  Hrt : in out Heart.HeartType) is
   begin
      Off(Icd, Monitor, Gen);
      On(Icd, Monitor, Gen, Hrt);
      ImpulseGenerator.Tick(Gen, Hrt);

   end Tick;


end ICD;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with Network;
with Principal;


package body Icd is
   
   KnownCard : Principal.PrincipalPtr;    
   KnownClin : Principal.PrincipalPtr;    
   KnownPatient : Principal.PrincipalPtr; 
   Monitor : HRM.HRMType;
   Gen : ImpulseGenerator.GeneratorType;    
   Net : Network.Network;
   Hrt : Heart.HeartType;
   
   
   MsgAvailable : Boolean := False;
   Message : Network.NetworkMessage;
   
   -- The value of heart rate
   HeartRate : Measures.BPM;
   LastSevenRate : array (Integer range 1..7) of Measures.BPM;
   NumReading : Integer := 0;
   ImpulseRate : Integer;
   ImpulseInterval : Integer;
   TickToNextImpulse : Integer;
   Signal : Integer := 0; -- The number of signals has been delivered
   Impulse : Measures.BPM;
   

   
   procedure Init(Icd : out ICDType; HRMonitor : in out HRM.HRMType;
                  Generator : in out ImpulseGenerator.GeneratorType;
                  Hr : in out Heart.HeartType; Ntk : in out Network.Network; 
                  Card : in Principal.PrincipalPtr; 
                  Clin : in Principal.PrincipalPtr; 
                  Patient : in Principal.PrincipalPtr) is
   begin
      KnownCard := Card;
      KnownClin := Clin;
      KnownPatient := Patient;
      Gen := Generator;
      Monitor := HRMonitor;
      Net := Ntk;
      Hrt := Hr;

      Put("ICD Known Principals Check: "); New_Line;
      Principal.DebugPrintPrincipalPtr(KnownCard); New_Line;
      Principal.DebugPrintPrincipalPtr(KnownClin); New_Line;
      Principal.DebugPrintPrincipalPtr(KnownPatient); New_Line;
      
      Icd.IsOn := False;
      Icd.TachyBound := INITIAL_TACHY_BOUND;
      Icd.JoulesToDeliver := INITIAL_JOULES;
      Icd.IsTachycardia := False;
      Icd.IsFibrillation := False;
      Icd.IsDelivering := False;
      Icd.TickToNextCheck := WAIT_FOR_CHECK;
      Icd.NeedToWaitCheck := False;
   end Init;
   
  
   procedure GetMessage(Icd : in out ICDType; 
                        History : in Network.RateHistory) is
   begin
      Network.GetNewMessage(Net,MsgAvailable,Message);
      if MsgAvailable then
         --Network.DebugPrintMessage(Message);
         case Message.MessageType is
         when Network.ModeOn =>
            Network.DebugPrintMessage(Message);
            HandleModeOn(Icd);
         when Network.ModeOff =>
            Network.DebugPrintMessage(Message);
            HandleModeOff(Icd);
         when Network.ReadRateHistoryRequest =>
            Network.DebugPrintMessage(Message);
            HandleReadRateHistoryRequest(History);
         when Network.ReadSettingsRequest =>
            Network.DebugPrintMessage(Message);
            if Icd.IsOn = False then
               HandleReadSettingsRequest(Icd);
            end if;
         when Network.ChangeSettingsRequest =>
            Network.DebugPrintMessage(Message);
            if Icd.IsOn = False then
               HandleChangeSettingsRequest(Icd);
            end if;     
       
         when others =>
            -- you should implement these for your own debugging if you wish
            Put("Other Message Type: ");
            Put(Message.MessageType'Image);New_Line;

            null;
         end case;
         --Put(Message.MessageType'Image);New_Line;
      end if;
   end GetMessage;
   
   
   procedure HandleModeOn(Icd : in out ICDType) is
   begin
      if Principal.PrincipalPtrToString(Message.MOnSource) = Principal.PrincipalPtrToString(KnownCard) 
         or else Principal.PrincipalPtrToString(Message.MOnSource) = Principal.PrincipalPtrToString(KnownClin) then
         On(Icd);
      end if;
   end HandleModeOn;
   
   procedure HandleModeOff(Icd : in out ICDType) is
   begin
      if Principal.PrincipalPtrToString(Message.MOffSource) = Principal.PrincipalPtrToString(KnownCard) 
        or else Principal.PrincipalPtrToString(Message.MOffSource) = Principal.PrincipalPtrToString(KnownClin) then
         
         Off(Icd);
      end if;
   end HandleModeOff;
   
   procedure HandleReadRateHistoryRequest(History : in Network.RateHistory) is
   begin
      if Principal.PrincipalPtrToString(Message.HSource) = Principal.PrincipalPtrToString(KnownCard) 
        or else Principal.PrincipalPtrToString(Message.HSource) = Principal.PrincipalPtrToString(KnownClin) 
        or else Principal.PrincipalPtrToString(Message.HSource) = Principal.PrincipalPtrToString(KnownPatient) then
            -- send a rate history response message even though none was requested
   -- and it contains history that is not current
         Network.SendMessage(Net,
                       (MessageType => Network.ReadRateHistoryResponse,
                        HDestination => Message.HSource,
                        History => History));
      end if;
   end HandleReadRateHistoryRequest;
      
   procedure HandleReadSettingsRequest(Icd : in ICDType) is
   begin
      if Principal.PrincipalPtrToString(Message.RSource) = Principal.PrincipalPtrToString(KnownCard) 
        or else Principal.PrincipalPtrToString(Message.RSource) = Principal.PrincipalPtrToString(KnownClin) then
            -- send a rate history response message even though none was requested
   -- and it contains history that is not current
         Network.SendMessage(Net,
                       (MessageType => Network.ReadSettingsResponse,
                        RDestination => Message.RSource,
                        RTachyBound => Icd.TachyBound,
                        RJoulesToDeliver => Icd.JoulesToDeliver));
      end if;
   end HandleReadSettingsRequest;
   
   procedure HandleChangeSettingsRequest(Icd : in out ICDType) is
   begin
      if Principal.PrincipalPtrToString(Message.CSource) = Principal.PrincipalPtrToString(KnownClin) then
            -- send a rate history response message even though none was requested
            -- and it contains history that is not current
         Icd.TachyBound := Message.CTachyBound;
         Icd.JoulesToDeliver := Message.CJoulesToDeliver;
         Network.SendMessage(Net,
                       (MessageType => Network.ChangeSettingsResponse,
                        CDestination => Message.CSource));
      end if;
   end HandleChangeSettingsRequest;

   
   procedure Tick(Icd : in out ICDType;  History : in Network.RateHistory) is
   begin

      HRM.GetRate(Monitor, HeartRate);
      UpdateRateArray(Icd);
     
      Put("Measured heart rate  = ");
      Put(Item => HeartRate);
      New_Line;
      Put("Actual heart rate  = ");
      Put(Item => Hrt.Rate);
      New_Line;
      Put("heart impulse = ");
      Put(Item => Hrt.Impulse);
      New_Line;
      if not Icd.IsDelivering then
         Impulse := 0;
         ImpulseGenerator.SetImpulse(Gen, Impulse);
      end if;
      GetMessage(Icd, History);
      if Icd.IsOn then 
         ModeOnOperation(Icd);
      end if;
      
   end Tick;
   
   -- In the on mode, the closed-loop functionality of the device is on,
   -- meaning that impulses may be delivered to the patient,
   -- and settings cannot be changed
   procedure On(Icd : in out ICDType) is
   begin
      Icd.IsOn := True;
      HRM.On(Monitor, Hrt);
      ImpulseGenerator.On(Gen);
   end On;

   procedure ModeOnOperation(Icd : in out ICDType) is
   begin
      -- Read and print the current measured heart rate
      HRM.GetRate(Monitor, HeartRate);
--        Put("Measured heart rate  = ");
--        Put(Item => HeartRate);
--        New_Line;

--        UpdateRateArray(Icd);
          Put("   The last 7 Rate  ");
          Put(Item => LastSevenRate(1));       
          Put(Item => LastSevenRate(2));
          Put(Item => LastSevenRate(3));
          Put(Item => LastSevenRate(4));
          Put(Item => LastSevenRate(5));
          Put(Item => LastSevenRate(6));
          Put(Item => LastSevenRate(7));
          New_Line;

      -- When a Fibrillation is detected Tachycardia detection should be turn
      -- off, since Fibrillationis more serious than Tachycardia
      Icd.IsFibrillation := IsFibrillation(Icd);
      Icd.IsTachycardia := IsTachycardia(Icd);
   
      if Icd.IsFibrillation and not Icd.NeedToWaitCheck then
         Put_Line("A ventricular fibrillation is detected ");
         ImpulseGenerator.SetImpulse(Gen, Icd.JoulesToDeliver);
         Icd.NeedToWaitCheck := True;
         Signal := 0;
         TickToNextImpulse := 0;
         Icd.IsDelivering := False;
      elsif Icd.IsTachycardia and not Icd.IsDelivering then
         Put_Line("A ventricular tachycardia is detected ");
         CalculateInterval(Icd);
         DeliverSignals(Icd);
      elsif Icd.IsDelivering then
         DeliverSignals(Icd);
      else
         Put_Line("cannot detect problem");
         Put_Line("Tachy bound is ");
         Put(item => Icd.TachyBound);
         New_Line;
      end if;
   
   end ModeOnOperation;
   
   
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


   procedure DeliverSignals(Icd : in out ICDType) is
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
--           Put("heart impulse = ");
--           Put(Item => Hrt.Impulse);
        -- New_Line;
      end if;
   end DeliverSignals;


   function IsFibrillation(Icd : in out ICDType) return Boolean is
      AverageChange : Measures.BPM;
      SumOfChange : Measures.BPM := 0;
   begin
      -- Check if there are six previous readings
      if NumReading < LastSevenRate'Last then
         return False;
      elsif Icd.IsFibrillation and Icd.TickToNextCheck > 0
      and Icd.NeedToWaitCheck then
         Icd.TickToNextCheck := Icd.TickToNextCheck - 1;
         return True;
      else
         Icd.NeedToWaitCheck := False;
         Icd.TickToNextCheck := WAIT_FOR_CHECK;
         for I in 1..LastSevenRate'Length-1 loop
            if LastSevenRate(I) = (-1) then
               return False;
            else
               SumOfChange := SumOfChange + abs(LastSevenRate(I+1) - LastSevenRate(I));
            end if;
         end loop;
         AverageChange := SumOfChange / (LastSevenRate'Length - 1);
--           Put_Line("Average change of six readings is ");
--           Put(item => AverageChange);
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
      if NumReading < LastSevenRate'Last then
         NumReading := NumReading + 1;
         LastSevenRate(NumReading) := HeartRate;
      else
         for I in LastSevenRate'Range loop
            if I = LastSevenRate'Last then
               LastSevenRate(I) := HeartRate;
            else
               LastSevenRate(I) := LastSevenRate(I+1);
            end if;
         end loop;
      end if;
   end UpdateRateArray;

   
   procedure Off(Icd : in out ICDType) is
   HrtVariable : Heart.HeartType;
   begin
      Signal := 0;
      Impulse := 0;
      ImpulseGenerator.SetImpulse(Gen, Impulse);
      HrtVariable := Hrt;
      Heart.SetImpulse(HrtVariable, Gen.Impulse);
      Hrt := HrtVariable;
      Icd.IsOn := False;
      Icd.IsDelivering := False;
      HRM.Off(Monitor);
      ImpulseGenerator.Off(Gen);
   end Off;



end Icd;

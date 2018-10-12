with Ada.Text_IO; use Ada.Text_IO;
with Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with Network;
with Principal;

package Icd is
   -- The initial upper bound for tachycardia when the system starts
   INITIAL_TACHY_BOUND : constant Measures.BPM := 100;
   -- The initial number of joules to deliver in the case of a
   -- ventricle fibrillation
   INITIAL_JOULES : constant Measures.Joules := 30;
   ABOVE_HEART_RATE : constant Measures.BPM := 15;
   NUM_SIGNAL : constant Integer := 10;
   FIBR_BOUND : constant Measures.BPM := 10;
   JOULES_PER_SIGNAL : constant Measures.Joules := 2;
   TICKS_PER_MINUTE : constant Integer := 600;
   WAIT_FOR_CHECK : constant Integer := 6;

   -- The record type for a ICD
   type ICDType is private;

   procedure Init(Icd : out ICDType; HRMonitor : in out HRM.HRMType;
                  Generator : in out ImpulseGenerator.GeneratorType;
                  Hr : in out Heart.HeartType; Ntk : in out Network.Network;
                  Card : in Principal.PrincipalPtr;
                  Clin : in Principal.PrincipalPtr;
                  Patient : in Principal.PrincipalPtr);

   procedure Tick(Icd : in out ICDType; History : in Network.RateHistory);


   procedure On(Icd : in out ICDType);
   procedure ModeOnOperation(Icd : in out ICDType);
   procedure Off(Icd : in out ICDType);
   function IsTachycardia(Icd : in out ICDType) return Boolean;
   procedure CalculateInterval(Icd : in out ICDType);
   procedure DeliverSignals(Icd : in out ICDType);
   function IsFibrillation(Icd : in out ICDType) return Boolean;
   procedure UpdateRateArray(Icd : in out ICDType);

   procedure GetMessage(Icd : in out ICDType;  History : in Network.RateHistory);

   procedure HandleModeOn(Icd : in out ICDType);

   procedure HandleModeOff(Icd : in out ICDType);

   procedure HandleReadRateHistoryRequest(History : in Network.RateHistory);

   procedure HandleReadSettingsRequest(Icd : in ICDType);

   procedure HandleChangeSettingsRequest(Icd : in out ICDType);


private

   type ICDType is
      record

         IsOn : Boolean;
         TachyBound : Measures.BPM;   -- The upper bound for tachycardia
         -- The number of joules to deliver for ventricle fibrillation
         JoulesToDeliver : Measures.Joules;
         IsTachycardia : Boolean;  -- Detect if a tachycardia happened
         IsFibrillation : Boolean; -- Detect if a vertricle fibrillation happened
         IsDelivering : Boolean; -- Detect if in a process of delivering joules
         TickToNextCheck : Integer;
         NeedToWaitCheck : Boolean;

      end record;

end icd;

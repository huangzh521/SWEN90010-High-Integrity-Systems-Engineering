with Ada.Text_IO; use Ada.Text_IO;
with Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with Network;
with Principal;

-- this package provides the necessary calculations of the
-- impulse based on the measured heart rate.
Package ICD is
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

   -- The record type for a ICD
   type ICDType is private;

   -- Create and initialise a ICD.
   procedure Init(Icd : out ICDType);
   procedure Tick(Icd : in out ICDType; Monitor : in out HRM.HRMType;
                  Gen : in out ImpulseGenerator.GeneratorType;
                  Hrt : in out Heart.HeartType);



private
   procedure On(Icd : in out ICDType; Monitor : in out HRM.HRMType;
                Gen: in out ImpulseGenerator.GeneratorType;
                Hrt : in Heart.HeartType);
   procedure Off(Icd : in out ICDType; Monitor : in out HRM.HRMType;
                 Gen : in out ImpulseGenerator.GeneratorType);
   function IsTachycardia(Icd : in out ICDType) return Boolean;
   procedure CalculateInterval(Icd : in out ICDType);
   procedure DeliverSignals(Icd : in out ICDType;
                            Gen : in out ImpulseGenerator.GeneratorType);
   function IsFibrillation(Icd : in out ICDType) return Boolean;
   procedure UpdateRateArray(Icd : in out ICDType);

   type ICDType is
      record
         IsOn : Boolean;
         TachyBound : Measures.BPM;   -- The upper bound for tachycardia
         -- The number of joules to deliver for ventricle fibrillation
         JoulesToDeliver : Measures.Joules;
         IsTachycardia : Boolean;  -- Detect if a tachycardia happened
         IsFibrillation : Boolean; -- Detect if a vertricle fibrillation happened
         IsDelivering : Boolean; -- Detect if in a process of delivering joules

      end record;

end ICD;

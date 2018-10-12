with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with Measures; use Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with Network;
with Principal;
with Icd;


package body Closedloop is

   Hrt : Heart.HeartType;                -- The simulated heart
   Monitor : HRM.HRMType;                -- The simulated heart rate monitor
   Generator : ImpulseGenerator.GeneratorType; -- The simulated generator
   HeartRate : BPM;
   Net : Network.Network;                -- The simulated network
   IcdSoftware : Icd.ICDType;
   Card : Principal.PrincipalPtr := new Principal.Principal;  -- A cardiologist
   Clin : Principal.PrincipalPtr := new Principal.Principal;  -- A clinical assistant
   Patient : Principal.PrincipalPtr := new Principal.Principal; -- A patient

   KnownPrincipals : access Network.PrincipalArray := new Network.PrincipalArray(0..2);

   -- stores some history information on measured heart rate
   History : Network.RateHistory;
   --HistoryPos : Integer := History'First;
   CurrentTime : TickCount := 0;  -- current time as measured in ticks



   procedure Init is
   begin
      Principal.InitPrincipalForRole(Card.all,Principal.Cardiologist);
      Principal.InitPrincipalForRole(Clin.all,Principal.ClinicalAssistant);
      Principal.InitPrincipalForRole(Patient.all,Principal.Patient);
      KnownPrincipals(0) := Card;
      KnownPrincipals(1) := Clin;
      KnownPrincipals(2) := Patient;

      Put("Known Principals: "); New_Line;
      Principal.DebugPrintPrincipalPtr(Card); New_Line;
      Principal.DebugPrintPrincipalPtr(Clin); New_Line;
      Principal.DebugPrintPrincipalPtr(Patient); New_Line;

      -- Initialise the components
      Heart.Init(Hrt);
      HRM.Init(Monitor);
      ImpulseGenerator.Init(Generator);
      Network.Init(Net,KnownPrincipals);
      ICD.Init(IcdSoftware, Monitor, Generator, Hrt, Net, Card, Clin, Patient);
      for Index in History'Range loop
         --Put(HistoryPos);
         History(Index) := (Rate => HeartRate, Time => CurrentTime);
      end loop;
   end Init;

   procedure Tick is
   begin
      ImpulseGenerator.Tick(Generator, Hrt);
      Heart.Tick(Hrt);
      HRM.Tick(Monitor, Hrt);
      ICD.Tick(IcdSoftware, History);
      Network.Tick(Net);
      HRM.GetRate(Monitor, HeartRate);
      for Index in Integer range 1 .. (History'Last-1) loop
         --Put(HistoryPos);
         History(Index) := History(Index + 1);
      end loop;

      History(History'Last) := (Rate => HeartRate, Time => CurrentTime);
      CurrentTime := CurrentTime + 1;
   end Tick;

end Closedloop;

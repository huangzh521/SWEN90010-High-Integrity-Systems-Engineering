with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with Measures; use Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with Network;
with Principal;
With ICD;

package body Closedloop is

   Hrt : Heart.HeartType;                -- The simulated heart
   Monitor : HRM.HRMType;                -- The simulated heart rate monitor
   Generator : ImpulseGenerator.GeneratorType; -- The simulated generator
   IcdSoftware : ICD.ICDType; -- The simulated Implantable Cardioverter-Defibrillator
   -- HeartRate : BPM;
   Net : Network.Network;                -- The simulated network
   Card : Principal.PrincipalPtr := new Principal.Principal;  -- A cardiologist
   Clin : Principal.PrincipalPtr := new Principal.Principal;  -- A clinical assistant
   Patient : Principal.PrincipalPtr := new Principal.Principal; -- A patient

   KnownPrincipals : access Network.PrincipalArray := new Network.PrincipalArray(0..2);
   -- CurrentTime : TickCount := 0;  -- current time as measured in ticks


   procedure Init is
   begin
      Principal.InitPrincipalForRole(Card.all,Principal.Cardiologist);
      Principal.InitPrincipalForRole(Clin.all,Principal.ClinicalAssistant);
      Principal.InitPrincipalForRole(Patient.all,Principal.Patient);
      KnownPrincipals(0) := Card;
      KnownPrincipals(1) := Clin;
      KnownPrincipals(2) := Patient;
      -- CurrentTime := CurrentTime + 1;
      Put("Known Principals: "); New_Line;
      Principal.DebugPrintPrincipalPtr(Card); New_Line;
      Principal.DebugPrintPrincipalPtr(Clin); New_Line;
      Principal.DebugPrintPrincipalPtr(Patient); New_Line;

      -- Initialise the components
      Heart.Init(Hrt);
      HRM.Init(Monitor);
      ImpulseGenerator.Init(Generator);
      Network.Init(Net,KnownPrincipals);
      ICD.Init(IcdSoftware);
   end Init;

   procedure Tick is
   begin
      ICD.Tick(IcdSoftware, Monitor, Generator, Hrt);
      Heart.Tick(Hrt);
      HRM.Tick(Monitor, Hrt);
      -- ImpulseGenerator.Tick(Generator, Hrt);
      Network.Tick(Net);
      -- CurrentTime := CurrentTime + 1;
   end Tick;

end Closedloop;

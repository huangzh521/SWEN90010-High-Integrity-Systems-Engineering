pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__test.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__test.adb");
pragma Suppress (Overflow_Check);
with Ada.Exceptions;

package body ada_main is

   E013 : Short_Integer; pragma Import (Ada, E013, "system__soft_links_E");
   E023 : Short_Integer; pragma Import (Ada, E023, "system__exception_table_E");
   E025 : Short_Integer; pragma Import (Ada, E025, "system__exceptions_E");
   E017 : Short_Integer; pragma Import (Ada, E017, "system__secondary_stack_E");
   E150 : Short_Integer; pragma Import (Ada, E150, "ada__containers_E");
   E055 : Short_Integer; pragma Import (Ada, E055, "ada__io_exceptions_E");
   E110 : Short_Integer; pragma Import (Ada, E110, "ada__numerics_E");
   E131 : Short_Integer; pragma Import (Ada, E131, "interfaces__c_E");
   E078 : Short_Integer; pragma Import (Ada, E078, "system__os_lib_E");
   E057 : Short_Integer; pragma Import (Ada, E057, "ada__tags_E");
   E054 : Short_Integer; pragma Import (Ada, E054, "ada__streams_E");
   E081 : Short_Integer; pragma Import (Ada, E081, "system__file_control_block_E");
   E076 : Short_Integer; pragma Import (Ada, E076, "system__finalization_root_E");
   E074 : Short_Integer; pragma Import (Ada, E074, "ada__finalization_E");
   E073 : Short_Integer; pragma Import (Ada, E073, "system__file_io_E");
   E129 : Short_Integer; pragma Import (Ada, E129, "ada__calendar_E");
   E052 : Short_Integer; pragma Import (Ada, E052, "ada__text_io_E");
   E145 : Short_Integer; pragma Import (Ada, E145, "system__assertions_E");
   E127 : Short_Integer; pragma Import (Ada, E127, "system__random_seed_E");
   E107 : Short_Integer; pragma Import (Ada, E107, "measures_E");
   E147 : Short_Integer; pragma Import (Ada, E147, "principal_E");
   E109 : Short_Integer; pragma Import (Ada, E109, "randomnumber_E");
   E105 : Short_Integer; pragma Import (Ada, E105, "heart_E");
   E135 : Short_Integer; pragma Import (Ada, E135, "hrm_E");
   E139 : Short_Integer; pragma Import (Ada, E139, "impulsegenerator_E");
   E141 : Short_Integer; pragma Import (Ada, E141, "network_E");
   E137 : Short_Integer; pragma Import (Ada, E137, "icd_E");
   E103 : Short_Integer; pragma Import (Ada, E103, "closedloop_E");

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
   begin
      E052 := E052 - 1;
      declare
         procedure F1;
         pragma Import (Ada, F1, "ada__text_io__finalize_spec");
      begin
         F1;
      end;
      declare
         procedure F2;
         pragma Import (Ada, F2, "system__file_io__finalize_body");
      begin
         E073 := E073 - 1;
         F2;
      end;
      declare
         procedure Reraise_Library_Exception_If_Any;
            pragma Import (Ada, Reraise_Library_Exception_If_Any, "__gnat_reraise_library_exception_if_any");
      begin
         Reraise_Library_Exception_If_Any;
      end;
   end finalize_library;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (C, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   type No_Param_Proc is access procedure;

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Leap_Seconds_Support : Integer;
      pragma Import (C, Leap_Seconds_Support, "__gl_leap_seconds_support");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");

      Finalize_Library_Objects : No_Param_Proc;
      pragma Import (C, Finalize_Library_Objects, "__gnat_finalize_library_objects");
   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;
      Leap_Seconds_Support := 0;

      Runtime_Initialize (1);

      Finalize_Library_Objects := finalize_library'access;

      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E023 := E023 + 1;
      System.Exceptions'Elab_Spec;
      E025 := E025 + 1;
      System.Soft_Links'Elab_Body;
      E013 := E013 + 1;
      System.Secondary_Stack'Elab_Body;
      E017 := E017 + 1;
      Ada.Containers'Elab_Spec;
      E150 := E150 + 1;
      Ada.Io_Exceptions'Elab_Spec;
      E055 := E055 + 1;
      Ada.Numerics'Elab_Spec;
      E110 := E110 + 1;
      Interfaces.C'Elab_Spec;
      E131 := E131 + 1;
      System.Os_Lib'Elab_Body;
      E078 := E078 + 1;
      Ada.Tags'Elab_Spec;
      Ada.Tags'Elab_Body;
      E057 := E057 + 1;
      Ada.Streams'Elab_Spec;
      E054 := E054 + 1;
      System.File_Control_Block'Elab_Spec;
      E081 := E081 + 1;
      System.Finalization_Root'Elab_Spec;
      E076 := E076 + 1;
      Ada.Finalization'Elab_Spec;
      E074 := E074 + 1;
      System.File_Io'Elab_Body;
      E073 := E073 + 1;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E129 := E129 + 1;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E052 := E052 + 1;
      System.Assertions'Elab_Spec;
      E145 := E145 + 1;
      System.Random_Seed'Elab_Body;
      E127 := E127 + 1;
      E107 := E107 + 1;
      E147 := E147 + 1;
      Randomnumber'Elab_Body;
      E109 := E109 + 1;
      E105 := E105 + 1;
      E135 := E135 + 1;
      E139 := E139 + 1;
      Network'Elab_Body;
      E141 := E141 + 1;
      Icd'Elab_Body;
      E137 := E137 + 1;
      Closedloop'Elab_Body;
      E103 := E103 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_test");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      gnat_argc := argc;
      gnat_argv := argv;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/measures.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/principal.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/randomnumber.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/heart.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/hrm.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/impulsegenerator.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/network.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/icd.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/closedloop.o
   --   /Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/test.o
   --   -L/Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/
   --   -L/Users/wry/Documents/Uni Melb/SE/2018 S1/high integrity/Assignment1/Ass1Integ/obj/
   --   -L/usr/local/gnat/lib/gcc/x86_64-apple-darwin14.5.0/6.3.1/adalib/
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;

with Ada.Text_IO;
use Ada.Text_IO;

procedure Main is
   main_threads_amount: Integer := 3;

   subtype Index is Integer range 1 .. main_threads_amount;

   type Task_Step is array (Index) of Integer;
   type Task_Sequence is array (Index) of Integer;
   type Task_Initial_Value is array (Index) of Integer;


   Steps_Array : Task_Step := (1, 2, 3);
   Sequence_Array : Task_Sequence := (1, 2, 3);
   Initial_Value_Array : Task_Initial_Value := (0, 0, 0);

   can_stop : Boolean := False;
   pragma Atomic(can_stop);
   pragma Volatile(can_stop);

   task type break_thread;
   task type main_thread is
      entry Start(Step_Value: Integer; Start_Sequence_Number: Integer; Start_Initial_Value: Integer);
   end main_thread;

   task body break_thread is
   begin
      delay 5.0;
      can_stop := True;
   end break_thread;

   task body main_thread is
      Initial_Value : Integer := 0;
      Step : Integer := 0;
      Sequence_Number : Integer := 1;
      Number_Sequence_Elements : Integer := 0;
   begin
      accept Start(Step_Value: Integer; Start_Sequence_Number: Integer; Start_Initial_Value: Integer) do
               Step := Step_Value;
               Sequence_Number := Start_Sequence_Number;
               Initial_Value := Start_Initial_Value;
            end Start;
      while not can_stop loop
            Initial_Value := Initial_Value + Step;
            Number_Sequence_Elements := Number_Sequence_Elements + 1;
            delay 1.0;
      end loop;

      Put_Line("Thread " & Sequence_Number'Img & " - Final Value: " & Initial_Value'Img & " - Total elements: " & Number_Sequence_Elements'Img);
   end main_thread;

   type Tasks_Array is array (Index) of main_thread;

   Ts : Tasks_Array;
   B1 : break_thread;

begin

   for I in Index loop
      Ts(I).Start(Steps_Array(I), Sequence_Array(I), Initial_Value_Array(I));
   end loop;

   null;
end Main;

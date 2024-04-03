with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Main is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer;
                      Producer_Count : in Integer; Consumer_Count : in Integer) is
      Storage : List;
      Access_Storage : Counting_Semaphore (1, Default_Ceiling);
      Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

      task type Producer is
         entry Start(Item_Numbers:Integer);
      end;

      task type Consumer is
         entry Start(Item_Numbers:Integer);
      end;

      task body Producer is
         Item_Numbers : Integer;
      begin
         accept Start (Item_Numbers : in Integer) do
            Producer.Item_Numbers := Item_Numbers;
         end Start;

         for i in 1 .. Item_Numbers loop
            Full_Storage.Seize;
            Access_Storage.Seize;

            Storage.Append ("item " & i'Img);
            Put_Line ("Producer added item " & i'Img);

            Access_Storage.Release;
            Empty_Storage.Release;
            delay 0.1;
         end loop;

      end Producer;

      task body Consumer is
         Item_Numbers : Integer;
      begin
         accept Start (Item_Numbers : in Integer) do
            Consumer.Item_Numbers := Item_Numbers;
         end Start;

         for i in 1 .. Item_Numbers loop
            Empty_Storage.Seize;
            Access_Storage.Seize;

            declare
               item : String := First_Element (Storage);
            begin
               Put_Line ("Consumer took " & item);
            end;

            Storage.Delete_First;

            Access_Storage.Release;
            Full_Storage.Release;

            delay 0.5;
         end loop;

      end Consumer;

      C : array (1..Consumer_Count) of Consumer;
      P : array (1..Producer_Count) of Producer;
      Col : array (1..Consumer_Count) of Integer := (others => Item_Numbers);
      Pro : array (1..Producer_Count) of Integer := (others => Item_Numbers);
   begin
      for i in  C'Range loop
         C(i).Start(Col(i));
      end loop;

      for i in  P'Range loop
         P(i).Start(Pro(i));
      end loop;
   end Starter;

begin
   Starter (5, 10, 5, 3); --size, items, producer, consumer
end Main;

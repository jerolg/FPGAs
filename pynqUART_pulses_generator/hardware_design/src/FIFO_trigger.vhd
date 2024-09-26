----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.08.2024 12:01:38
-- Design Name: 
-- Module Name: FIFO_trigger - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FIFO_trigger is
    generic(ancho : integer := 14;
            profundo : integer := 1024;
            defaultdata : integer := 512);
            
    Port (clk : in STD_LOGIC;
          reset : in STD_LOGIC;
           
           clk_adc: in std_logic;
           dataIn : in std_logic_vector(ancho-1 downto 0);
           Trigger : in std_logic_vector(ancho-1 downto 0);  
            
           Trigger_out: out std_logic;
           IniciarLectura: in std_logic;
           finLectura:   out std_logic;
           dataOut   : out std_logic_vector(ancho-1 downto 0));
end FIFO_trigger;

architecture Behavioral of FIFO_trigger is

type fifodata is array (0 to profundo-1) of std_logic_vector(ancho-1 downto 0);
signal arraydatos : fifodata;

signal found : std_logic;
signal leido : std_logic;

begin


process(clk_adc,reset)
begin
if reset = '1' then
   for i in 0 to profundo-1 loop
       arraydatos(i) <= (others => '0');
   end loop;
elsif rising_edge(clk_adc) then
   if found = '0' then
      arraydatos(0) <= dataIn;
      for i in 1 to profundo-1 loop
          arraydatos(i) <= arraydatos(i-1);
      end loop;
   end if;
end if;
end process;

process(clk_adc,reset)

begin
if reset = '1' then
   found <= '0';
elsif rising_edge(clk_adc) then
   if (arraydatos(defaultdata) >= trigger and found = '0') then
          found <= '1';
   elsif found = '1' and leido = '1' then
          found <= '0';
   end if;       
end if;
end process;    

process(clk, reset) 
variable contadordatos : integer;
begin
  if reset = '1' then
     contadordatos := 0;
     leido <= '0';
  elsif rising_edge(clk) then
      if iniciarlectura = '1' then
         if contadordatos >= profundo-1 then
            leido <= '1';
         else
            dataOut <= arraydatos(contadordatos);           
            contadordatos := contadordatos + 1;
         end if;
      else
         contadordatos := 0;
         leido <= '0';
      end if; 
  end if;
end process;

 Trigger_out <= found;
 finLectura <= leido;
                     

end Behavioral;
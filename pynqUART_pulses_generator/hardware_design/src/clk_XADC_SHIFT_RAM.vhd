----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.09.2024 10:21:21
-- Design Name: 
-- Module Name: clk_XADC_SHIFT_RAM - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clk_XADC_SHIFT_RAM is
    generic(
    XADC_sampling_clk : integer := 1000000
    );
    Port (
        clk: in std_logic;
        aresetn: in std_logic;
        clk_out: out std_logic
        );
end clk_XADC_SHIFT_RAM;

architecture Behavioral of clk_XADC_SHIFT_RAM is
    signal contador: integer :=0;
    signal clk_int: std_logic :='0';
    
    
    
begin
process(clk, aresetn)
begin
if (aresetn = '0')then
   contador <= 0;
   clk_int  <= '0';
elsif rising_edge(clk) then

   if contador >= 50 then
      clk_int <= not clk_int;
      clk_out <= not clk_int;
     -- ser_clk <= not clk_int;
      contador <= 0;
   else
      contador <= contador + 1;
   end if;
end if;
end process;


end Behavioral;

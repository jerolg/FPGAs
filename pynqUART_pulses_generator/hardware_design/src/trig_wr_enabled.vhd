----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.09.2024 18:01:22
-- Design Name: 
-- Module Name: trig_wr_enabled - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trig_wr_enabled is
    Port ( clk : in std_logic;
    aresetn : in std_logic;
    trig_in : in std_logic;
    window_len : in std_logic_vector(15 downto 0);
    trig_wr_en : out std_logic );
    
    
end trig_wr_enabled;

architecture Behavioral of trig_wr_enabled is

signal last_trig : std_logic := '0';
signal trig_count : integer := 0;


begin

triggered : process(clk, aresetn)
begin
    if aresetn = '0' then
        last_trig <= '0';
        trig_count <= 0;
    elsif rising_edge(clk) then
        last_trig <= trig_in;
        if last_trig = '0' and trig_in = '1' then
            trig_count <= 1;
        elsif trig_count < TO_INTEGER(unsigned(window_len)) and trig_count /= 0 then
            trig_count <= trig_count + 1;
        else
            trig_count <= 0;
        end if;
    end if;

end process;

trig_wr_en <= '1' when trig_count /=0 else '0';

end Behavioral;

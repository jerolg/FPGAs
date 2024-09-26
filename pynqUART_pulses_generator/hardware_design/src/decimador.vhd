----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.08.2024 15:57:54
-- Design Name: 
-- Module Name: decimador - Behavioral
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

entity decimador is
   -- generic(
   -- dec_factor: integer :=0
   -- );
    Port (
        clk: in std_logic;
        reset: in std_logic;
        
        dec_factor: in std_logic_vector(7 downto 0);
        data_in: in std_logic_vector(15 downto 0);
        data_out: out std_logic_vector(15 downto 0);
        decim_valid: out std_logic
    );
end decimador;

architecture Behavioral of decimador is  

signal factor_count : integer := 0;
--signal trash_data : std_logic_vector(15 downto 0);
signal valid_data : std_logic_vector(15 downto 0);

begin
    process(reset, clk)
    begin
        
        if reset  = '1' then
            factor_count <= 0;
            decim_valid <= '0';
        
        elsif rising_edge(clk) then
        
         if factor_count = to_integer(unsigned(dec_factor))- 1 then
                valid_data <= data_in;
                factor_count <= 0;
                decim_valid <= '1';
            else
                
                factor_count <= factor_count + 1;
                decim_valid <= '0';
            end if;
        end if;   
    end process;
    data_out <= valid_data;
end Behavioral;

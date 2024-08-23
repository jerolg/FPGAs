----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.08.2024 22:13:41
-- Design Name: 
-- Module Name: trapezoidal_shaper - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity subs_delay is

    generic (
           width : integer := 255;
           delay : integer := 4;
    );
    
    Port (
        clk : in std_logic;
        reset : in std_logic;
        X_in : in std_logic_vector(width-1 downto 0);
        subs : out std_logic_vector(width-1 downto 0)
    );
end subs_delay;

architecture Behavioral of subs_delay is

    signal X_delay : std_logic_vector(width-1 downto 0);
    signal count : integer := 0;
    signal flag: std_logic := '0';

begin

process(clk, reset)
begin
    if reset = '1' then
      count <= 0;
      flag <= '0';
    
    elsif rising_edge(clk) then

        if flag = '0' then 
            X_delay <= X_in;
            flag = '1';
        else
            count <= count + 1;
            
            if count = delay then
                subs <= X_delay-X_in;
                flag <= '0';
            end if;

        end if;
        
    end if;    
    end process;
------------------------------------------------
------------------------------------------------
    


end Behavioral;
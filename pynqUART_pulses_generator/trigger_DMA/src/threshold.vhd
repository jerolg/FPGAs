----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.09.2024 12:30:34
-- Design Name: 
-- Module Name: threshold - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity  threshold is
    generic(
    --mode : integer := 0;
    data_width : integer := 32
    --thresh_level : integer;
    --upper_lim : integer;
    --lower_lim : integer;
    --sleep_trig : integer := 100
    );
    Port (
    clk : in std_logic;
    aresetn : in std_logic;
    D_in : in std_logic_vector(data_width-1 downto 0);
    thres_level : in std_logic_vector(data_width-1 downto 0);
    edge_sel : in std_logic;  -- 0:POS_EDGE, 1:NEG_EDGE
    
    trigger : out std_logic
    --led_out : out std_logic
    );
end threshold;

architecture Behavioral of threshold is
    
    signal last_val : std_logic_vector(data_width -1 downto 0);
    
   -- signal counter : integer := 0;  -- Contador de ciclos de reloj
    --constant CYCLE_COUNT : integer := 100000000;  -- Contador para 1 segundo
    
begin

process(clk, aresetn)
begin
    if aresetn = '0' then
        trigger <= '0';
        
    elsif rising_edge(clk) then
        last_val <= D_in;
        if edge_sel = '0' then  --Positive Slope cross_level_trigger
            if unsigned(last_val) < unsigned(thres_level) and unsigned(D_in) >= unsigned(thres_level) then
                trigger <= '1';
            else
                trigger <= '0';
            end if;
        else --Negative slope cross_level trigger
            if unsigned(last_val) > unsigned(thres_level) and unsigned(D_in) <= unsigned(thres_level) then
                trigger <= '1';
            else
                trigger <= '0';
            end if;
        end if;
    end if;
    
end process;

--led: process(clk, aresetn)
    
--    begin
--        if aresetn = '1' then
--            counter <= 0;
--            led_out <= '0';
--        elsif rising_edge(clk) then
--            if counter < CYCLE_COUNT - 1 then
--                counter <= counter + 1;
--                led_out <= '1';
--            else
--                counter <= 0;
--                led_out <= '0';
--            end if;
--        end if;
--    end process;
    
end Behavioral;

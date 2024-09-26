library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rng_pulse_trigger is
    Port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        pulse_in : in STD_LOGIC;
        indicator : out STD_LOGIC;
        pulse_trig  : out STD_LOGIC
    );
end rng_pulse_trigger;

architecture Behavioral of rng_pulse_trigger is
   signal flag: std_logic := '0';
   --signal count: integer := 0;
   
begin

    process(clk, pulse_in)
    begin
    
    if reset = '0' then
       -- count <= 0;
        flag <= '0';
    
    elsif rising_edge(clk) then
            
        if pulse_in = '1' and flag = '0' then
            --if flag = '0' then
            flag <= '1';
            pulse_trig <= '1';
               -- count <= count + 1;
        elsif flag = '1' and pulse_in = '1' then
                --flag <= '0';
            pulse_trig <= '0';
        else
            flag <= '0';
            pulse_trig <= '0';
        
        end if;
 
    end if;
    
    indicator <= pulse_in; 
    
    end process;

  --  pulse_trig <= pulse_signal;

end Behavioral;


library IEEE;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity expo_transf_Z is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pulse_trig : in STD_LOGIC;
           signalout : out STD_LOGIC_VECTOR (7 downto 0);
           enable_tx : out STD_LOGIC);
end expo_transf_Z;



architecture Behavioral of expo_transf_Z is

    constant Yinicio : integer := 253;
    constant alfa : integer := 968;
    --signal Yactual: integer;
   -- signal Ycambio: integer;

    type states_type is (S_rst, S0, S1, S2);
    signal current_s, next_s : states_type;
    signal counter : integer := 0;
    
begin
    transition: process(clk, reset)
           variable Yvector : std_logic_vector(19 downto 0);
	       variable Ypaso   : std_logic_vector(7 downto 0);
	       variable Yactual: integer;
	       variable Ycambio: integer;
    begin
        if reset='0' then
            --RESET CONDITION
            current_s <= S_rst;
            --Yvector := (others => '0');
            --Ycambio := 0;
           -- Yactual := Yinicio;
            
        elsif rising_edge(clk) then
        
            enable_tx <= '1';
            current_s <= next_s;
           
            if current_s = S_rst then
                Yvector := (others => '0');
                Ycambio := 0;
                Yactual := Yinicio;
                signalout <= std_logic_vector(to_unsigned(Yactual,8));
                
            elsif current_s = S0 then
                Yactual := Yinicio;
                signalout <= std_logic_vector(to_unsigned(Yactual,8));
                
            elsif current_s = S1 then
                Yactual := Yactual*alfa;
                Yvector := std_logic_vector(to_unsigned(Yactual,20));    
                Ypaso   := Yvector(17 downto 10);
                signalout <= Ypaso;
                Yactual := to_integer(unsigned(Ypaso));
                    
               if Ypaso = "00000000" then
                    current_s <= S2;
                
                end if;
                
            elsif current_s = S2 then
                signalout <= (others => '0');
            end if;
        end if;
    end process;

    states_logic : process(current_s, pulse_trig)
        
    begin
        case current_s is
        
            when S_rst =>
                --Yvector := (others => '0');
                --Ycambio := 0;
                --Yactual := Yinicio;
                --signalout <= std_logic_vector(to_unsigned(Yactual,8));
                next_s <= S1;
                
            when S0 =>
                --Yactual := Yinicio;
               -- signalout <= std_logic_vector(to_unsigned(Yactual,8));
                --next_s <= S1;
                if pulse_trig = '1' then
                    next_s <= S0;
                else
                    next_s <= S1;
                end if;
            
            when S1 =>
                if pulse_trig = '1' then
                    next_s <= S0;
               else
                    next_s <= S1;
              
                       -- Yactual := Yactual*alfa;
                       -- Yvector := std_logic_vector(to_unsigned(Yactual,20));    
                       -- Ypaso   := Yvector(17 downto 10);
                       -- signalout <= Ypaso;
                       -- Yactual := to_integer(unsigned(Ypaso));
                        --counter <= counter + 1;
                        --next_s <= S2;
                    --end if;
                end if;
            
            when S2 =>
                if pulse_trig = '1' then
                    next_s <= S0;
                else
                    next_s <=S2;
                end if;
                
            when others =>
                    next_s <= S2;
        
        end case;
    end process;

                end Behavioral;
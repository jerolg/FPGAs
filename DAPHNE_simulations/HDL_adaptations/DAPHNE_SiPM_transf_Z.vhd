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

entity SiPM_transf_Z is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           signalout : out STD_LOGIC_VECTOR (7 downto 0));
end SiPM_transf_Z;

architecture Behavioral of SiPM_transf_Z is

    type coeffs_arr is array (0 to 5) of integer;
    constant num_coeffs : coeffs_arr := (0, 1707164997, -3484358576, 2106642482, -588911742, 259462625);
    constant den_coeffs : coeffs_arr := (1073741824, -4228192258, 6506403651, -4878945731, 1782803988, -255811259);

    type data_arr is array (0 to 4095) of integer;
    signal t_arr : data_arr := (others => 0);
    signal y_arr : data_arr := (others => 0);

begin
    process(reset,clk)
begin
    if reset = '1' then
        t(61) <= 1; t(1999) <= 1; t(2699) <= 1;
        
    elsif rising_edge(clk) then 

    end if;
    end process;

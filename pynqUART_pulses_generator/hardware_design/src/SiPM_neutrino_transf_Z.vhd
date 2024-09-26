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

entity SiPM_neutrino_transf_Z is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           enable_tx : out STD_LOGIC;
           signalout : out STD_LOGIC_VECTOR (7 downto 0));
end SiPM_neutrino_transf_Z;

architecture Behavioral of SiPM_neutrino_transf_Z is

    type coeffs_arr is array (0 to 5) of integer;
    constant num_coeffs : coeffs_arr := (0, 426791262, -871089638, 526660627, -147227942, 64865662);  --Coeffs normalizados bajo division entera //4 por cumplimiento del rango integer 2^31
    constant den_coeffs : coeffs_arr := (268435456, -1057048066, 1626600907, -1219736435, 445700998, -63952822);

    type data_arr is array (0 to 4095) of integer;
    signal t_arr : data_arr := (others => 0);
    signal y_arr : data_arr := (others => 0);
    
begin
    process(reset,clk)
    


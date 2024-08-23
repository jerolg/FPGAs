----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.08.2024 20:33:59
-- Design Name: 
-- Module Name: trapezoidal_filter_conv - Behavioral
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

entity trapezoidal_filter_conv is
    generic (
    signal_width: integer := 8
    );
    Port (
    X_in : in std_logic_vector(signal_width-1 downto 0);
    M : in std_logic_vector(7 downto 0);
    Y_out: out std_logic_vector(7 downto 0)
    );
end trapezoidal_filter_conv;

architecture Behavioral of trapezoidal_filter_conv is
-----------------------------------------------------------
-----------------------------------------------------------
component substractor is
    generic(
        width : integer := 8
    );
    port (
        clk, reset : std_logic;
        A: in std_logic_vector(width-1 downto 0);
        B: in std_logic_vector(width-1 downto 0);
        --en: in std_logic;
        --cin: in std_logic; 
        subs : out std_logic_vector(width-1 downto 0)
    );
end component;
-----------------------------------------------------------
-----------------------------------------------------------
component adder is
    generic(
        width : integer := 8
    );
    port (
        clk, reset : std_logic;
        A_add: in std_logic_vector(width-1 downto 0);
        B_add: in std_logic_vector(width-1 downto 0);
        --en_add: in std_logic;
        --cin: in std_logic; 
        sum : out std_logic_vector(width-1 downto 0)
    );
end component;
-----------------------------------------------------------
-----------------------------------------------------------
component multiplier is
    generic(
        width : integer := 8
    );
    port (
        clk, reset : std_logic;
        A_mult: in std_logic_vector(width-1 downto 0);
        B_mult: in std_logic_vector(width-1 downto 0);
        --en_add: in std_logic;
        --cin: in std_logic; 
        mult : out std_logic_vector(width-1 downto 0)
    );
end component;
-----------------------------------------------------------
-----------------------------------------------------------
component delay is
    generic(
        width: integer := 8;
        delay_val: integer:= 0
    );
    port (
        clk, reset: in std_logic;
        val_in: in std_logic_vector(width-1 downto 0);
        val_out: out std_logic_vector(width-1 downto 0)
        --enable: out std_logic
    );
end component;
-----------------------------------------------------------
-----------------------------------------------------------
    signal K_int, L_int 
    signal X_kdelay
    signal a_K, a_KL, b, c, y
    signal prod

begin

trapezoidal_filter: for n in i to j generate

    subs_1: substractor
        generic map(width => 8)
        port map(A => X_in(n), B => X_in(n-K_int), subs => a_K(n));
    subs_2: substractor
        generic map(width => 8)
        port map(A => a_K(n), B => a_K(n-L_int), subs => a_KL(n));
    mult_1: multiplier
        generic map(width => 8)
        port map(A_mult => M, B_mult => a_KL(n), mult => prod(n));
    adder_1: adder
        generic map(width => 8)
        port map(A_add => a_KL(n), B_add => b(n-1), sum => b(n));
    adder_2: adder
        generic map(width => 8)
        port map(A_add => prod(n), B_add => b(n), sum => c(n));
    adder_3: adder
        generic map(width => 8)
        port map(A_add => c(n), B_add => y(n-1), sum => y(n));

end generate trapezoidal_filter;

end Behavioral;
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trapezoidal_shaper is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        X_in : in std_logic_vector(7 downto 0);

        K : in std_logic(7 downto 0);
        L : in std_logic(7 downto 0);
        M : in std_logic(7 downto 0);

        length : in std_logic_vector(31 downto 0);
        Y_out : out std_logic_vector(7 downto 0) 
    );
end trapezoidal_shaper;

architecture Behavioral of trapezoidal_shaper is

    type signal_arr is array (0 to to_integer(unsigned(length))-1) of std_logic_vector(7 downto 0); 
    signal X, Y, a, b, c: signal_arr;
    signal n: integer := X'length;
    signal n_count, out_count, in_count: integer := 0;
    signal K_int, L_int, M_int: integer;
    signal init_cond, init_flag : std_logic := '0';

begin

process(clk, reset)
begin
    if reset = '1' then
        X <= (others => "00000000");
        Y <= (others => "00000000");
        a <= (others => "00000000");
        b <= (others => "00000000");
        c <= (others => "00000000");
        n_count <= 0;
        init_cond <= 0;
    
    elsif rising_edge(clk) then

        if init_flag <= '1' then
--Valor inicial de n = max(K, L)----------------
            if n >= K_int or n >= L_int then
                if init_cond = '0' then
                    if n >= L_int then
                        if n >= K_int then
                            n_count <= K_int;
                            init_cond <= '1';
                        else
                        n_count <= L_int;
                        init_cond <= '1';

                        end if;
                    end if;
                end if;
            end if;
    ------------------------------------------------
    ------------------------------------------------
    --Filtro trapezoidal de la señal----------------
            if n_count <= n then

                a[n_count] <= X[n_count] - X[n_count-K] - X[n_count-L] + X[n_count-K-L];
                if n_count >= 0 then
                    b[n_count] <= b[n_count-1] + a[n_count];
                end if;
                c[n_count] <= b[n_count] + M*a[n_count];
                if n_count >= 0 then
                    Y[n_count] <= Y[n_count-1] + c[n_count];
                end if;

                n_count <= n_count + 1;
            end if;
        end if;
    end process;
------------------------------------------------
------------------------------------------------
in_and_out : process(reset, clk)
begin

    if reset = '1' then
        in_count <= 0;
        out_count <= 0;
        init_flag <= '0';

    elsif rising_edge(clk) then

        if in_count <= n then
            X[in_count] <= X_in;
            in_count <= in_count + 1;
            init_flag <= '0';
        else 
            init_flag < = '1';
        
        end if;

        if n_count >= n then
            if out_count <= Y'length then
                Y_out <= Y[out_count];
                out_count <= out_count + 1;
            end if;
        end if;
    end if;
    end process;


    


end Behavioral;

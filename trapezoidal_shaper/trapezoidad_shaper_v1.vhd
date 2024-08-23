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

entity trapezoidal_shaper_v1 is

    generic (
           width : integer := 255
    );
    
    Port (
        clk : in std_logic;
        reset : in std_logic;
        X_in : in std_logic_vector(7 downto 0);

        K : in std_logic_vector(7 downto 0);
        L : in std_logic_vector(7 downto 0);
        M : in std_logic_vector(7 downto 0);

        --length : in std_logic_vector(31 downto 0);
        Y_out : out std_logic_vector(7 downto 0);
        count : out std_logic_vector(7 downto 0)
       -- sig_count : out std_logic_vector(7 downto 0) 
    );
end trapezoidal_shaper_v1;

architecture Behavioral of trapezoidal_shaper_v1 is

    type signal_arr is array (0 to width-1) of integer; 
    signal X, Y, a, b, c: signal_arr;
    signal n: integer := width-1;
    signal n_count, out_count: integer := 0;
    signal in_count : integer := 1;
    signal K_int, L_int, M_int: integer;
    signal init_cond, init_flag : std_logic := '0';

begin

process(clk, reset)
begin
    if reset = '1' then
        X <= (others => 0);
        Y <= (others => 0);
        a <= (others => 0);
        b <= (others => 0);
        c <= (others => 0);
        n_count <= 0;
        in_count <= 0;
        init_flag <= '0';

        init_cond <= '0';
    
    elsif rising_edge(clk) then

        if in_count < n then
            X(in_count) <= to_integer(unsigned(X_in));
            in_count <= in_count + 1;
            init_flag <= '0';
        else 
            init_flag <= '1';
        
        end if;
        
        if init_flag <= '1' then
--Valor inicial de n = max(K, L)----------------
                if init_cond = '0' then
                   
                   -- if K_int >= L_int then
                   --    n_count <= K_int;
                   --     init_cond <= '1';
                   -- else
                   --    n_count <= L_int;
                   --     init_cond <= '1';

                   --end if;
                end if;
    ------------------------------------------------
    ------------------------------------------------
    --Filtro trapezoidal de la señal----------------
            if n_count <= n then

                a(n_count) <= X(n_count) - X(n_count-K_int) - X(n_count-L_int) + X(n_count-K_int-L_int);
                if n_count >= 0 then
                    b(n_count) <= b(n_count-1) + a(n_count);
                end if;
                c(n_count) <= b(n_count) + M_int*a(n_count);
                if n_count >= 0 then
                    Y(n_count) <= Y(n_count-1) + c(n_count);
                end if;

                n_count <= n_count + 1;
            end if;
        end if;
     end if;
        
        K_int <= to_integer(unsigned(K));
        L_int <= to_integer(unsigned(L)); 
        M_int <= to_integer(unsigned(M));
        count <= std_logic_vector(to_unsigned(in_count, 8));
       -- sig_count <= std_logic_vector(to_unsigned(in_count, 8));
    end process;
------------------------------------------------
------------------------------------------------
in_and_out : process(reset, clk)
begin

    if reset = '1' then
        out_count <= 0;
        init_flag <= '0';

    elsif rising_edge(clk) then

        if n_count >= n then
            if out_count <= Y'length then
                Y_out <= std_logic_vector(to_unsigned(Y(out_count), 8));
                out_count <= out_count + 1;
            end if;
        end if;
    end if;
    end process;


    


end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serial_tx is
    generic(
    baudrate : integer := 115200
    );
  Port (clk_zynq       : in std_logic;
        reset            : in std_logic;
        
        --- Control signals tx
        enable_tx      : in std_logic; 
        --ack_tx         : out std_logic;
        dato_tx        : in std_logic_vector(7 downto 0);
        
        --serial_clk_out
        serial_clk     : out std_logic;
        --ser_clk : out std_logic;
       -- ack : out std_logic;
        
        -- signal to tx 
        out_tx         : out std_logic);
end serial_tx;

architecture Behavioral of serial_tx is

signal contador : integer := 0;
signal contador_tx : integer := 0;
signal clk_int  : std_logic :='0';
signal clk_factor : integer;
signal dato_int : std_logic_vector(9 downto 0);
--signal enable_tx : std_logic := '0';

type estados_tx is (S0_init, S1_datos);
signal estado : estados_tx;

begin

-- reloj baudios 115200

process(clk_zynq, reset)
begin
if (reset = '0')then
   contador <= 0;
   clk_int  <= '0';
elsif rising_edge(clk_zynq) then
   if contador >= clk_factor then
      clk_int <= not clk_int;
      serial_clk <= not clk_int;
     -- ser_clk <= not clk_int;
      contador <= 0;
   else
      contador <= contador + 1;
   end if;
end if;

if baudrate=9600 then
    clk_factor <= 5208;
elsif baudrate=115200 then
    clk_factor <= 434;
end if;
end process;

process(clk_int, reset)
begin
  if reset = '1' then
     out_tx <= '1';
     estado <=S0_init;
     contador_tx <= 0; 
  elsif rising_edge(clk_int) then
     case estado is 
     
     when S0_init => 
     dato_int <= "11" & dato_tx; 
     contador_tx <= 0;  
     --ack_tx <= '0';
    -- ack<= '0';
     out_tx <= '1';           
     if enable_tx = '1' then
        estado <= S1_datos;
        out_tx <= '0';
     end if;  
     
     when S1_datos => 
         out_tx <= dato_int(contador_tx);
         --ack_tx <= '1';
        -- ack <= '1';
         if contador_tx >= 9 then
            estado <= S0_init;
         else
           contador_tx <=contador_tx + 1;
         end if;
         
      when others => 
         estado <= S0_init;
      end case;
   end if;
end process;

--enable: process(clk_zynq, rst, enable_tx)
--    begin
--    if rst = '1' then
--        enable_tx <= '0';
 --   elsif rising_edge(clk_zynq) then
 --       if dato_tx /= "00000000" then
  --          enable_tx <= '1';
  --      else
  --          enable_tx <= '0';
  --      end if;
 --   end if;
--end process enable;          
end Behavioral;

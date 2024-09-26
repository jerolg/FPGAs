library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity burned_data_nbits is
    generic( bits_length : integer := 8;
             byte_divisions : integer := 0;
             offset : integer := 0
             
    );
    
    Port( clk : in std_logic;
          reset : in std_logic;
          pulse_trig : in std_logic;
          signalout : out std_logic_vector(7 downto 0);
          enable_tx : out std_logic);
end burned_data_nbits;

architecture Behavioral of burned_data_nbits is
    type data_arr is array (0 to 999) of integer;
    signal data_array : data_arr :=
       (82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  87,  97, 107, 122, 138, 148, 163, 168, 173, 173,
       173, 173, 173, 173, 173, 178, 184, 189, 194, 194, 199, 199, 204,
       204, 214, 219, 230, 235, 240, 240, 245, 245, 250, 255, 255, 255,
       255, 255, 250, 245, 245, 240, 235, 230, 230, 224, 219, 214, 209,
       209, 204, 199, 194, 189, 184, 184, 178, 173, 168, 163, 158, 158,
       153, 148, 143, 138, 138, 138, 143, 143, 148, 148, 143, 143, 148,
       153, 158, 163, 173, 178, 178, 178, 184, 184, 189, 189, 189, 189,
       189, 184, 178, 178, 173, 168, 163, 163, 158, 153, 148, 143, 143,
       138, 133, 128, 122, 122, 117, 112, 107, 107, 102,  97,  92,  92,
        87,  82,  82,  76,  71,  71,  66,  61,  61,  56,  56,  51,  46,
        46,  41,  41,  36,  36,  31,  31,  31,  26,  26,  20,  20,  20,
        15,  15,  20,  26,  31,  31,  36,  36,  36,  36,  31,  31,  31,
        31,  26,  26,  26,  26,  20,  20,  20,  20,  26,  31,  36,  41,
        46,  56,  61,  66,  66,  71,  71,  66,  66,  66,  66,  61,  61,
        61,  61,  56,  56,  56,  51,  51,  51,  46,  46,  46,  41,  41,
        41,  36,  36,  36,  31,  31,  31,  31,  31,  31,  36,  41,  46,
        46,  46,  46,  46,  46,  46,  41,  41,  41,  41,  36,  36,  36,
        36,  31,  31,  31,  31,  26,  26,  26,  26,  26,  20,  20,  20,
        20,  15,  15,  15,  15,  15,  15,  10,  10,  10,  10,  10,  10,
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   0,   0,   0,
         0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
         0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
         0,   0,   0,   0,   5,   5,   5,   5,   5,   5,   5,   5,   5,
         5,   5,   5,   5,  10,  10,  10,  10,  10,  10,  10,  10,  10,
        10,  10,  15,  15,  15,  15,  15,  15,  15,  15,  15,  15,  20,
        20,  20,  20,  20,  20,  20,  20,  20,  26,  26,  26,  26,  26,
        26,  26,  26,  26,  31,  31,  36,  41,  51,  56,  61,  61,  66,
        66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  61,  61,  61,  61,  61,  61,  61,  61,
        61,  61,  61,  61,  61,  61,  61,  61,  61,  61,  61,  61,  61,
        61,  61,  61,  61,  61,  61,  61,  61,  61,  61,  61,  61,  61,
        61,  61,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  66,  66,  66,  71,  71,  71,  71,  71,
        71,  71,  71,  71,  71,  71,  71,  71,  71,  71,  71,  71,  71,
        71,  71,  71,  71,  71,  71,  71,  76,  76,  76,  76,  76,  76,
        76,  76,  76,  76,  76,  76,  76,  76,  76,  76,  76,  76,  76,
        76,  76,  76,  76,  76,  76,  76,  76,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  87,  92, 102, 107, 107, 112, 112,
       112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112,
       112, 112, 112, 112, 107, 107, 107, 107, 107, 107, 107, 107, 107,
       107, 102, 102, 102, 102, 102, 102, 102, 102, 102,  97,  97,  97,
        97,  97,  97,  97,  97,  97,  97,  92,  92,  92,  92,  92,  92,
        92,  92,  92,  92,  92,  92,  92,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,
        82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  82,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,
        87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87,  87);
        
    signal index : integer := data_array'length-1; -- Index that traverses the array
    signal signal_temp: std_logic_vector(bits_length-1 downto 0);
    --signal byte_div_count: integer := 0;

begin

    process(clk, reset, pulse_trig)
    begin
        if reset = '1' then
            --index <= 0;
            signalout <= (others => '0');
            
            
        elsif rising_edge(clk) then
            
----------------8 BITS SIGNAL RESOLUTION--------------------------------------------------
------------------------------------------------------------------------------------------
            if bits_length = 8 then

                enable_tx <= '1';
                
                if pulse_trig = '1' then
                    index <= 0;
                    signalout <= conv_std_logic_vector(data_array(index), 8);
                
                else
                    if index = data_array'length-1 then
                            signalout <= conv_std_logic_vector(offset, 8);
                    
                    else
                        signalout <= conv_std_logic_vector(data_array(index), 8);
                        index <= index + 1;  
                        
                    end if;
                            
                end if;
                
--------------- N BITS SIGNAL RESOLUTION (16, 32) ---------------------------------------- 
------------------------------------------------------------------------------------------
             elsif bits_length = 16 then
             
                enable_tx <= '1';
                
                if pulse_trig = '1' then
                    index <= 0;
                    signal_temp <= conv_std_logic_vector(data_array(index), bits_length);
                    
                    send_byte_sequence_max: for k in 0 to byte_divisions loop  --Se desencadena la señal cuando detecta un pulso
                        if k = 0 then
                            signalout <= signal_temp(15 downto 8);
                        elsif k = 1 then
                            signalout <= signal_temp(7 downto 0);
                        end if;
                        --AGREGAR MAS CONDICIONALES PARA k = 2,3,... PARA LONGITUDES DE PALABRA MAS GRANDES
                    end loop send_byte_sequence_max;
                    
                else
                    if index = data_array'length-1 then
                            signalout <= conv_std_logic_vector(offset, 8);  --Manda el valor del offset predefinido (defecto = 0)
                      
                    else
                        signal_temp <= conv_std_logic_vector(data_array(index), bits_length);
                        
                        send_byte_sequence: for j in 0 to byte_divisions loop  -- Envio de cada dato que compone la señal
                            if j = 0 then
                                signalout <= signal_temp(15 downto 8);
                            elsif j = 1 then
                                signalout <= signal_temp(7 downto 0);
                            end if;
                            
                            --AGREGAR MAS CONDICIONALES PARA j = 2,3,... PARA LONGITUDES DE PALABRA MAS GRANDES
                    end loop send_byte_sequence;
                        
                        index <= index + 1;  
                        
                    end if;
                            
                end if;
                
             end if;

    end if;  
    end process;

end Behavioral;

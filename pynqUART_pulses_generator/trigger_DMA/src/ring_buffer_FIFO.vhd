library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ring_buffer_FIFO is
    generic (
    -- Users to add parameters here
    RAM_WIDTH : natural;
    RAM_DEPTH : natural;
    -- User parameters ends
    -- Do not modify the parameters beyond this line
    
    -- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
    C_M_AXIS_TDATA_WIDTH : integer := 32;
    -- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
    C_M_START_COUNT : integer := 64
    );
    port (
    -- Users to add ports here
            --data_in     : in std_logic_vector(15 downto 0);
            decim_valid : in std_logic;
            
            --write port
            wr_en : in std_logic;
            wr_data : in std_logic_vector(RAM_WIDTH - 1 downto 0);

            --read port
            --rd_en : in std_logic;
           -- rd_valid : out std_logic; axis_tvalid
           
           -- rd_data : out std_logic_vector(RAM_WIDTH - 1 downto 0); stream_data_out

                -- Flags
            empty : out std_logic;
            empty_next : out std_logic;
            full : out std_logic;
            full_next : out std_logic;

            -- The number of elements in the FIFO
           -- fill_count : out integer range RAM_DEPTH - 1 downto 0;

            -- User ports ends
    -- Do not modify the ports beyond this line
    
    -- Global ports
    M_AXIS_ACLK : in std_logic;
    --
    M_AXIS_ARESETN : in std_logic;
    -- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted.
    M_AXIS_TVALID : out std_logic;
    -- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
    M_AXIS_TDATA : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
    -- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
    M_AXIS_TSTRB : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
    -- TLAST indicates the boundary of a packet.
    M_AXIS_TLAST : out std_logic;
    -- TREADY indicates that the slave can accept a transfer in the current cycle.
    M_AXIS_TREADY : in std_logic
    );
    end ring_buffer_FIFO;

    architecture implementation of ring_buffer_FIFO is
                                                                  
        
        -- function called clogb2 that returns an integer which has the  
        -- value of the ceiling of the log base 2.                              
        function clogb2 (bit_depth : integer) return integer is                  
        variable depth  : integer := bit_depth;                              
        variable count  : integer := 1;                                      
        begin                                                                  
        for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
             if (bit_depth <= 2) then                                          
               count := 1;                                                      
             else                                                              
               if(depth <= 1) then                                              
              count := count;                                                
            else                                                            
              depth := depth / 2;                                            
                 count := count + 1;                                            
            end if;                                                          
          end if;                                                            
          end loop;                                                            
          return(count);                                                      
        end;                                                                    
        
        -- WAIT_COUNT_BITS is the width of the wait counter.                      
        constant  WAIT_COUNT_BITS  : integer := clogb2(C_M_START_COUNT-1);              
                                                                                         
        -- In this example, Depth of FIFO is determined by the greater of                
        -- the number of input words and output words.                                    
        constant depth : integer := RAM_DEPTH -1;                              
                                                                                         
        -- bit_num gives the minimum number of bits needed to address 'depth' size of FIFO
        constant bit_num : integer := clogb2(depth);                                      
                                                                                                                                     
        signal read_pointer : integer range 0 to depth-1;                              
        
        -- AXI Stream internal signals
        --wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
        signal count : std_logic_vector(WAIT_COUNT_BITS-1 downto 0);
        --streaming data valid
        signal axis_tvalid : std_logic;
        --streaming data valid delayed by one clock cycle
        signal axis_tvalid_delay : std_logic;
        --Last of the streaming data
        signal axis_tlast : std_logic;
        --Last of the streaming data delayed by one clock cycle
        signal axis_tlast_delay : std_logic;
        --FIFO implementation signals
        signal stream_data_out : std_logic_vector(31 downto 0);
        signal tx_en : std_logic;
        --The master has issued all the streaming data stored in FIFO
        signal tx_done : std_logic;
        signal act      : std_logic;
        
        
        --Buffer principal
        type ram_type is array (0 to RAM_DEPTH + 4) of std_logic_vector(RAM_WIDTH-1 downto 0);
        signal ram : ram_type;
    
        subtype index_type is integer range ram_type'range;
        signal head : index_type;
        signal tail : index_type;
        
        signal empty_i : std_logic;
        signal full_i : std_logic;
        signal fill_count_i : integer range RAM_DEPTH - 1 downto 0;
        
        -- Increment and wrap
        procedure incr(signal index : inout index_type) is
        begin
          if index = index_type'high then
            index <= index_type'low;
          else
            index <= index + 1;
          end if;
        end procedure;

        begin
        -- I/O Connections assignments
        
        M_AXIS_TVALID <= axis_tvalid_delay;
        M_AXIS_TDATA <= stream_data_out;
        M_AXIS_TLAST <= axis_tlast_delay;
        M_AXIS_TSTRB <= (others => '1');

          -- Copy internal signals to output
        empty <= empty_i;
        full <= full_i;
       -- fill_count <= fill_count_i;
        
        -- Set the flags
        empty_i <= '1' when fill_count_i = 0 else '0';
        empty_next <= '1' when fill_count_i <= 1 else '0';
        full_i <= '1' when fill_count_i >= RAM_DEPTH - 1 else '0';
        full_next <= '1' when fill_count_i >= RAM_DEPTH - 2 else '0';
              
                                 
            -- Update the head pointer in write
        PROC_HEAD : process(M_AXIS_ACLK, M_AXIS_ARESETN)
        begin
            if rising_edge(M_AXIS_ACLK) then
            if M_AXIS_ARESETN = '0' then
                head <= 0;
            else
        
                if wr_en = '1' and full_i = '0' then
                incr(head);
                end if;
        
            end if;
            end if;
        end process;
        
        -- Update the tail pointer on read and pulse valid
        PROC_TAIL : process(M_AXIS_ACLK, M_AXIS_ARESETN)
        begin
        if rising_edge(M_AXIS_ACLK) then
            if M_AXIS_ARESETN = '0' then
            tail <= 0;
            axis_tvalid <= '0';
            else
            axis_tvalid <= '0';
        
            if M_AXIS_TREADY = '1' and empty_i = '0' then
                incr(tail);
                axis_tvalid <= '1';
            end if;
        
            end if;
        end if;
        end process; 

            -- Write to and read from the RAM
        PROC_RAM : process(M_AXIS_ACLK)
        begin
            if rising_edge(M_AXIS_ACLK) then
            ram(head) <= wr_data;
            stream_data_out <= "000000000000000000000000"&ram(tail);
            end if;
        end process;
  
        -- Update the fill count
        PROC_COUNT : process(head, tail)
        begin
            if head < tail then
            fill_count_i <= head - tail + RAM_DEPTH;
            else
            fill_count_i <= head - tail;
            end if;
        end process;
    
    
        axis_tlast <= '1' when (fill_count_i = 1) else '0';                    
                                                                                                     
        -- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
        -- to match the latency of M_AXIS_TDATA                                                        
        process(M_AXIS_ACLK)                                                                          
        begin                                                                                          
         if (rising_edge (M_AXIS_ACLK)) then                                                          
           if(M_AXIS_ARESETN = '0') then                                                              
             axis_tvalid_delay <= '0';                                                                
             axis_tlast_delay <= '0';                                                                
           else                                                                                      
             axis_tvalid_delay <= axis_tvalid;                                                        
             axis_tlast_delay <= axis_tlast;                                                          
           end if;                                                                                    
         end if;                                                                                      
        end process;                                                                                  
        
        end implementation;
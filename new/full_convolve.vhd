----------------------------------------------------------------------------------
-- Engineer: Landon Bates
-- 
-- Create Date: 02/10/2024 10:22:37 AM
-- Module Name: full_convolve - Behavioral
-- Project Name: Artificial Reverberation Project
-- Description: 
--  Convolves audio data from tdatai with a filter divided into seperate
--  FIR compiler IP sections. Audio is sampled from the tdatai port at 48 kHz.
--  The result of the convolution is written to the tdatao port. Both the tdatai
--  and tdata0 ports are assumed to contain 23 fractional bits.
--  
-- Dependencies:
--   synchronous reset
--   100 MHz clock
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity full_convolve is
  Port (clk : in std_logic;    -- 100 MHz
        rst : in std_logic;    -- synchronous
        tdatai : in std_logic_vector(23 downto 0); -- 23 fractional bits
        tdatao : out std_logic_vector(23 downto 0) -- 23 fractional bits
        );
end full_convolve;

architecture Behavioral of full_convolve is

-- FIR Compiler IP Instances
COMPONENT f1
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT f2
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT f3
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT f4
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT f5
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT f6
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT f7
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
  );
END COMPONENT;

COMPONENT f8
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_data_tvalid : IN STD_LOGIC;
    s_axis_data_tready : OUT STD_LOGIC;
    s_axis_data_tdata : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(47 DOWNTO 0) 
  );
END COMPONENT;

-- tvalid signal for all FIR Compiler IP components
signal valid : std_logic := '0';

-- s_axis_tdata signals for FIR Compiler IP components
signal idata1 : std_logic_vector(23 downto 0) := (others => '0');
signal idata2 : std_logic_vector(23 downto 0) := (others => '0');
signal idata3 : std_logic_vector(23 downto 0) := (others => '0');
signal idata4 : std_logic_vector(23 downto 0) := (others => '0');
signal idata5 : std_logic_vector(23 downto 0) := (others => '0');
signal idata6 : std_logic_vector(23 downto 0) := (others => '0');
signal idata7 : std_logic_vector(23 downto 0) := (others => '0');
signal idata8 : std_logic_vector(23 downto 0) := (others => '0');

-- m_axis_data_tdata signals for FIR Compiler components
signal odata1 : std_logic_vector(47 downto 0) := (others => '0');
signal odata2 : std_logic_vector(47 downto 0) := (others => '0');
signal odata3 : std_logic_vector(47 downto 0) := (others => '0');
signal odata4 : std_logic_vector(47 downto 0) := (others => '0');
signal odata5 : std_logic_vector(47 downto 0) := (others => '0');
signal odata6 : std_logic_vector(47 downto 0) := (others => '0');
signal odata7 : std_logic_vector(47 downto 0) := (others => '0');
signal odata8 : std_logic_vector(47 downto 0) := (others => '0');

-- counter signals
signal count : integer := 0;
signal freq_count : integer := 0;
signal read_count : natural := 17;

-- signal to hold sum of FIR Compiler outputs
signal data_out : std_logic_vector(47 downto 0) := (others => '0');

-- block memory IP component
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(23 DOWNTO 0) 
  );
END COMPONENT;

-- block memory signals
signal wea : std_logic_vector(0 downto 0) := "1";
signal addra : std_logic_vector(13 downto 0) := (others => '0');
signal dina : std_logic_vector(23 downto 0) := (others => '0');
signal douta : std_logic_vector(23 downto 0) := (others => '0');
signal address : integer := 0;

begin

-- block memory IP port map
buff1 : blk_mem_gen_0
    port map(
        clka => clk,
        wea => wea,
        addra => addra,
        dina => dina,
        douta => douta
    );

-- FIR Compiler IP port maps
filter1 : f1
port map(
    aclk => clk,
    s_axis_data_tvalid => valid,
    s_axis_data_tready => open,
    s_axis_data_tdata => idata1,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => odata1
);

filter2 : f2
port map(
    aclk => clk,
    s_axis_data_tvalid => valid,
    s_axis_data_tready => open,
    s_axis_data_tdata => idata2,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => odata2
);

filter3 : f3
port map(
    aclk => clk,
    s_axis_data_tvalid => valid,
    s_axis_data_tready => open,
    s_axis_data_tdata => idata3,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => odata3
);

filter4 : f4
port map(
    aclk => clk,
    s_axis_data_tvalid => valid,
    s_axis_data_tready => open,
    s_axis_data_tdata => idata4,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => odata4
);

filter5 : f5
port map(
    aclk => clk,
    s_axis_data_tvalid => valid,
    s_axis_data_tready => open,
    s_axis_data_tdata => idata5,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => odata5
);

filter6 : f6
port map(
    aclk => clk,
    s_axis_data_tvalid => valid,
    s_axis_data_tready => open,
    s_axis_data_tdata => idata6,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => odata6
);

filter7 : f7
port map(
    aclk => clk,
    s_axis_data_tvalid => valid,
    s_axis_data_tready => open,
    s_axis_data_tdata => idata7,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => odata7
);

filter8 : f8
port map(
    aclk => clk,
    s_axis_data_tvalid => valid,
    s_axis_data_tready => open,
    s_axis_data_tdata => idata8,
    m_axis_data_tvalid => open,
    m_axis_data_tdata => odata8
);

process(clk)
begin
    if rising_edge(clk) then
    
        valid <= '0';    -- set FIR Compiler valid to 0
        wea <= "0";      -- set block mem valid to 0
        
        if freq_count > 2083 then   -- generate frequency of 48 kHz
            -- set block mem write address
            addra <= std_logic_vector(to_unsigned(count, 14));
            dina <= tdatai; -- load audio input data to be written to block mem
            wea <= "1";     -- write data to block mem
            idata1 <= tdatai;  -- load audio sample to first FIR block
            freq_count <= 0;   -- reset freq counter
            count <= count + 1; -- incrememnt sample counter
            read_count <= 0;    -- reset read counter
        else
            freq_count <= freq_count + 1; -- increment frequency counter
        end if;
        
        if count >= 16384 then
            count <= 0;   -- reset sample counter
        end if;
        
        -- This statement reads audio values to each FIR block at locations
        -- determined by the function read address = (sample_count - 2048) mod 16384.
        -- The block mem has a read delay of 2 clock cycles, so there has to be a
        -- break inbetween each memory read.
        if read_count = 3 then
            address <= (count-2048) mod 16384;
        elsif read_count = 9 then
            idata2 <= douta;
            address <= (count-4096) mod 16384;
        elsif read_count = 12 then
            idata3 <= douta;
            address <= (count-6144) mod 16384;
        elsif read_count = 15 then
            idata4 <= douta;
            address <= (count-8192) mod 16384;
        elsif read_count = 18 then
            idata5 <= douta;
            address <= (count-10240) mod 16384;
        elsif read_count = 21 then
            idata6 <= douta;
            address <= (count-12288) mod 16384;
        elsif read_count = 24 then
            idata7 <= douta;
            address <= (count-14366) mod 16384;
        elsif read_count = 27 then
            idata8 <= douta;
            valid <= '1';  -- set FIR block valid to 1 once each new sample is read
        end if;            -- from block mem
        
        addra <= std_logic_vector(to_unsigned(address, 14));
        
        if read_count < 28 then
            read_count <= read_count + 1; -- increment read counter
        end if;
    end if;
    
    if falling_edge(clk) then  -- sum the outputs of each FIR block
        data_out <= std_logic_vector(signed(odata1) + signed(odata2) 
                                 + signed(odata3) + signed(odata4)
                                 + signed(odata5) + signed(odata6)
                                 + signed(odata7) + signed(odata8));
    end if;
    
    if rst = '0' then   -- reset counters
        freq_count <= 0;
        read_count <= 28;
        count <= 0;
    end if;
end process;

tdatao <= data_out(40 downto 17); -- output first 23 fractional bits of data_out

end Behavioral;

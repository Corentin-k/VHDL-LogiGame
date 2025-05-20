library IEEE;
use IEEE.std_logic_1164.all;

entity bufferUAL is

port (
	e1 : in std_logic_vector (7 downto 0);
    reset : in std_logic;
   
    clock : in std_logic;

    
    MEM_CACHE_1_out_enable : out std_logic;
    MEM_CACHE_1_out        : out std_logic_vector(7 downto 0);
    
    MEM_CACHE_2_out_enable : out std_logic;
    MEM_CACHE_2_out        : out std_logic_vector(7 downto 0);

    Buffer_A               : out std_logic_vector(3 downto 0);
    Buffer_A_enable        : out std_logic;

    Buffer_B               : out std_logic_vector(3 downto 0);
    Buffer_B_enable        : out std_logic;
);
end  bufferUAL;

architecture bufferUAL_Arch of bufferUAL is

begin

    BufferMemCache1Proc: process(clock, reset)
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            MEM_CACHE_1_out_enable <= '0';
            MEM_CACHE_1_out <= (others => '0');
        elsif rising_edge(clock) and enable ='1' then
                MEM_CACHE_1_out_enable <= '1';
                MEM_CACHE_1_out <= e1;
        end if;
        
    end process BufferMemCache1Proc;

    BufferMemCache2Proc: process(clock, reset)
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            MEM_CACHE_2_out_enable <= '0';
            MEM_CACHE_2_out <= (others => '0');
        elsif rising_edge(clock) and enable ='1' then
                MEM_CACHE_2_out_enable <= '1';
                MEM_CACHE_2_out <= e1;
        end if;
        
    end process BufferMemCache2Proc;

    BufferAProc: process(clock, reset)
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            Buffer_A_enable <= '0';
            Buffer_A <= (others => '0');
        elsif rising_edge(clock) and enable ='1' then
                Buffer_A_enable <= '1';
                Buffer_A <= e1;
        end if;
        
    end process BufferAProc;

    BufferBProc: process(clock, reset)
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            Buffer_B_enable <= '0';
            Buffer_B <= (others => '0');
        elsif rising_edge(clock) and enable ='1' then
                Buffer_B_enable <= '1';
                Buffer_B <= e1;
        end if;
        
    end process BufferBProc;
end bufferUAL_Arch;


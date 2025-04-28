library IEEE;
use IEEE.std_logic_1164.all;

entity bufferNbits is
generic (
	N : integer := 4
);
port (
	e1 : in std_logic_vector (N-1 downto 0);
    reset : in std_logic;
   
    clock : in std_logic;
    s1 : out std_logic_vector (N-1 downto 0);
    enable : in std_logic 
);
end  bufferNbits;

architecture bufferNbits_Arch of bufferNbits is
	    
begin
	 
    BufferNbitsProc: process(clock, reset)        
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            s1 <= (others => '0');
        elsif rising_edge(clock) and enable ='1' then
                s1 <= e1;
        end if;
        
    end process BufferNbitsProc;

end bufferNbits_Arch;


library IEEE;
use IEEE.std_logic_1164.all;

entity bufferNbits is
generic (
	N : integer := 4
);
port (
	e1 : in std_logic_vector (N-1 downto 0);
    reset : in std_logic;
    preset : in std_logic;
    clock : in std_logic;
    s1 : out std_logic_vector (N-1 downto 0)
);
end  bufferNbits;

architecture bufferNbits_Arch of bufferNbits is
	    
begin
	
    -- process explicite MyBufferNbitsProc 
    -- Reset asynchrone sur niveau haut
    -- Preset synchrone sur niveau haut
    -- Bufferisation sur front montant de l’horloge d’entrée


   
    BufferNbitsProc: process(clock, reset)        
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            s1 <= (others => '0');
        elsif rising_edge(clock) then
            -- Preset synchrone sur niveau haut
            if preset = '1' then
                s1 <= (others => '1');
            else 
            -- Bufferisation sur front montant de l’horloge d’entrée
                s1 <= e1;
            end if;
        end if;
        
    end process BufferNbitsProc;

end bufferNbits_Arch;


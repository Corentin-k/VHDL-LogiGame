-- filepath: mem_instructions.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_instructions is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        instruction     : in  unsigned(6 downto 0); -- 7 bits pour 128 instructions 
        donnee : out std_logic_vector(9 downto 0)
    );
end mem_instructions;

architecture mem_instructions_arch of mem_instructions is
    type table_memoire is array (0 to 127) of std_logic_vector(9 downto 0);
    signal memoire : table_memoire := (
            -- Multiplication
        0 => "0000000000", -- Charger A dans Buffer_A
        1 => "0000011100", -- Charger B dans Buffer_B 
        2 => "1111000011", -- Multiplier et sortir S

        -- (A+B) xnor A
        3 => "0000000000", -- Charger A_IN dans Buffer_A
        4 => "0000011100", -- Charger B_IN dans Buffer_B
        5 => "1101111000", -- A+B sans retenue, stocker S dans MEM_CACHE_1
        6 => "0000100000", -- nop, charger MEM_CACHE_1 → Buffer_B
        7 => "0111111100", -- A xor B, stocker S dans MEM_CACHE_2
        8 => "0000001100", -- nop, charger MEM_CACHE_2 → Buffer_A
        9 => "0011000011", -- not A (A=Buffer_A), sortie S

       -- RES_OUT_3 = (A0 and B1) or (A1 and B0) (RES_OUT_3 sur le bit de poids faible)

       10 => "0000000000", -- Charger A_IN dans Buffer_A
        11 => "0000011100", -- Charger B_IN dans Buffer_B
        12 => "0101111000", -- A0 and B1, stocker S dans MEM_CACHE_1
        13 => "0101111100", -- A1 and B0, stocker S dans MEM_CACHE_2
        14 => "0000000100", -- Charger MEM_CACHE_1 dans Buffer_A
        15 => "0000101000", -- Charger MEM_CACHE_2 dans Buffer_B
        16 => "0110000011", -- OR, sortie S

        others => (others => '0')
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            donnee <= memoire(to_integer(instruction));
        end if;
    end process;

    
end mem_instructions_arch;
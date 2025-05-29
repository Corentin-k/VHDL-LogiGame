-- filepath: mem_instructions.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_instructions is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        instruction : in std_logic_vector(6 downto 0);-- 7 bits pour 128 instructions 
        donnee : out std_logic_vector(9 downto 0)
    );
end mem_instructions;

architecture mem_instructions_arch of mem_instructions is
    type table_memoire is array (0 to 127) of std_logic_vector(9 downto 0);
    signal memoire : table_memoire := (
            -- A*B
        0 => "0000000000", --  A → Buffer_A
        1 => "0000011100", --  B → Buffer_B 
        2 => "1111000011", -- Multiplier et sortir S

        -- (A+B) xnor A
        3 => "0000000000", --  A_IN → Buffer_A
        4 => "0000011100", --  B_IN → Buffer_B
        5 => "1101111000", -- A+B sans retenue,  S → MEM_CACHE_1
        6 => "0000100000", -- NOP, MEM_CACHE_1 → Buffer_B
        7 => "0111111100", -- A xor B,  S → MEM_CACHE_2
        8 => "0000001100", -- NOP, MEM_CACHE_2 → Buffer_A
        9 => "0011000011", -- not A (A=Buffer_A), sortie S

       -- (A0 and B1) or (A1 and B0)

       10 => "0000000000", --  A_IN → Buffer_A
        11 => "0000011100", --  B_IN → Buffer_B
        12 => "0101111000", -- A0 and B1,  S → MEM_CACHE_1
        13 => "0101111100", -- A1 and B0,  S dans MEM_CACHE_2
        14 => "0000000100", --  MEM_CACHE_1 → Buffer_A
        15 => "0000101000", --  MEM_CACHE_2 → Buffer_B
        16 => "0110000011", -- A OR B, sortie S
        

        -- LFSR 4 bits (X⁴ + X³ + 1), début à l'adresse 17
    17 => "0000000111", -- no-op ; SEL_ROUTE=0111 = B_IN → Buffer_B
    18 => "0010111000", -- S = B      ; SEL_ROUTE=1110 = S → MEM_CACHE_1 (on initialise à sw="1011")

    19 => "0000000100", -- no-op ; SEL_ROUTE=0001 = MEM_CACHE_1 → Buffer_A
    20 => "1001000000", -- shift_left A, SR_OUT_L = bit3
    21 => "0000001010", -- no-op ; SEL_ROUTE=1010 = SR_OUT_L → Buffer_B
    22 => "0000111100", -- no-op ; SEL_ROUTE=1111 = Buffer_B → MEM_CACHE_2

    23 => "0000000100", -- no-op ; MEM_CACHE_1 → Buffer_A
    24 => "1001000000", -- shift_left A, SR_OUT_L = bit2
    25 => "0000001010", -- no-op ; SR_OUT_L → Buffer_B
    26 => "0011111100", -- S = A xor B  ; S → MEM_CACHE_2

    27 => "0000000100", -- no-op ; MEM_CACHE_1 → Buffer_A
    28 => "1000000000", -- shift_right A (prépare A≫1)
    29 => "0000110000", -- no-op ; SEL_ROUTE=1100 = MEM_CACHE_2 → Buffer_B (feedback)
    30 => "1001000000", -- shift_left A avec SR_IN_R = feedback
    31 => "0000011000", -- no-op ; SEL_ROUTE=1100 = Buffer_A → MEM_CACHE_1 (nouvel état)
    32 => "0000000011", -- no-op ; RES_OUT = S

        others => (others => '0')
    );
   function slv_to_integer(slv : std_logic_vector) return integer is
    variable result : integer := 0;
begin
    for i in slv'range loop
        result := result * 2;
        if slv(i) = '1' then
            result := result + 1;
        end if;
    end loop;
    return result;
end function;
    
    begin
    process(clk)
    begin
        if rising_edge(clk) then
            donnee <= memoire(slv_to_integer(instruction));
        end if;
    end process;

   
    
end mem_instructions_arch;
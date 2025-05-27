library IEEE;
use IEEE.std_logic_1164.all;
-- pour SEL_FCT et SEL_ROUTE
entity buffer_cmd is

port (
	e1 : in std_logic_vector (3 downto 0);
    reset : in std_logic;
    clock : in std_logic;
    s1 : out std_logic_vector (3 downto 0)

);
end  buffer_cmd;

architecture buffer_cmd_arch of buffer_cmd is
	    
begin
	 
    process(clock, reset)
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            s1 <= (others => '0');
        elsif rising_edge(clock) then
                s1 <= e1;
        end if;
        
    end process;
   
end buffer_cmd_arch;


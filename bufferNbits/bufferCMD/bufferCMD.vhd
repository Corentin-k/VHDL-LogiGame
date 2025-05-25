library IEEE;
use IEEE.std_logic_1164.all;

entity buffer_cmd is

port (
	e1 : in std_logic_vector (3 downto 0);
    reset : in std_logic;
    clock : in std_logic;
    SEL_FCT : out std_logic_vector (3 downto 0);
    SEL_ROUTE : out std_logic_vector (3 downto 0)
);
end  buffer_cmd;

architecture buffer_cmd_arch of buffer_cmd is
	    
begin
	 
    BufferSelFctProc: process(clock, reset)
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            SEL_FCT <= (others => '0');
        elsif rising_edge(clock) then
                SEL_FCT <= e1;
        end if;
        
    end process BufferSelFctProc;

    BufferSelRouteProc: process(clock, reset)
    begin
        -- Reset asynchrone sur niveau haut
        if reset = '1' then
            SEL_ROUTE <= (others => '0');
        elsif rising_edge(clock) then
                SEL_ROUTE <= e1;
        end if;
        
    end process BufferSelRouteProc;

end buffer_cmd_arch;


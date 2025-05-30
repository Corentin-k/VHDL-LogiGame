library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity minuteur is 
    port (
        clk      : in std_logic;
        reset    : in std_logic;
        start    : in std_logic;
        sw_level : in std_logic_vector(1 downto 0);
        time_out : out std_logic
    );
end minuteur;

architecture minuteur_arch of minuteur is
    signal counter     : unsigned(26 downto 0) := (others => '0');
    signal running     : std_logic := '0';
    signal timeout_resultat : std_logic := '0';
    signal limit       : unsigned(26 downto 0);
begin

    -- Affectation concurrente de limit (toujours à jour)
    with sw_level select
        limit <= to_unsigned(100_000_000-1, 27) when "00",
                 to_unsigned(50_000_000-1, 27)  when "01",
                 to_unsigned(25_000_000-1, 27)  when "10",
                 to_unsigned(12_500_000-1, 27)  when others;

    process(clk, reset)
    begin
        if reset = '1' then
            counter     <= (others => '0');
            running     <= '0';
            timeout_resultat <= '0';
        elsif rising_edge(clk) then
            if start = '1' and running = '0' then
                running     <= '1';
                counter     <= (others => '0');
                timeout_resultat <= '0';
            elsif running = '1' then
                if counter < limit then
                    counter <= counter + 1;
                else
                    timeout_resultat <= '1';
                    running     <= '0';
                end if;
            else
                timeout_resultat <= '0';
            end if;
        end if;
    end process;

    time_out <= timeout_resultat;

end minuteur_arch;
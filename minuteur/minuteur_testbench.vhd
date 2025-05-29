library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity minuteur_tb is
end minuteur_tb;

architecture minuteur_tb_arch of minuteur_tb is
    signal clk_sim      : std_logic := '0';
    signal reset_sim    : std_logic := '0';
    signal start_sim    : std_logic := '0';
    signal sw_level_sim : std_logic_vector(1 downto 0) := "11";
    signal time_out_sim : std_logic;

    component minuteur
        port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            start    : in  std_logic;
            sw_level : in  std_logic_vector(1 downto 0);
            time_out : out std_logic
        );
    end component;

    function slv_to_str(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
    begin
        for i in slv'range loop
            result(i - slv'low + 1) := character'VALUE(std_ulogic'image(slv(i)));
        end loop;
        return result;
    end function;
begin

    minuteur_inst: minuteur
        port map (
            clk      => clk_sim,
            reset    => reset_sim,
            start    => start_sim,
            sw_level => sw_level_sim,
            time_out => time_out_sim
        );

    -- Génération de l'horloge 100 MHz (période 10 ns)
    clk_process: process
    begin
        while now < 0.2 sec loop
            clk_sim <= '0'; wait for 5 ns;
            clk_sim <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Stimulus principal
    minuteur_proc: process
    begin
        -- Reset initial
        reset_sim <= '1';
        wait for 20 ns;
        reset_sim <= '0';

        -- Lancer le minuteur niveau "11" (0,125s)
        sw_level_sim <= "11";
        start_sim <= '1';
        wait for 10 ns;
        start_sim <= '0';

        -- Attendre plus que le timeout (0,2s)
        wait for 0.2 sec;

        wait;
    end process;

    -- Affichage à chaque front d'horloge
    affichage: process(clk_sim)
    begin
        if rising_edge(clk_sim) then
            if time_out_sim = '1' then
                report ">>> TIMEOUT déclenché à t=" & time'image(now);
            end if;
         end if;
    end process;

end minuteur_tb_arch;
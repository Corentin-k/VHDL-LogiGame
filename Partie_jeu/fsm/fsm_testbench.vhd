library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_tb is
end fsm_tb;

architecture fsm_tb_arch of fsm_tb is

    -- Composant à tester
    component fsm is
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            start      : in  std_logic;
            sw_level   : in  std_logic_vector(1 downto 0);
            btn_r      : in  std_logic;
            btn_g      : in  std_logic;
            btn_b      : in  std_logic;
            led_color  : out std_logic_vector(2 downto 0);
            score      : out std_logic_vector(3 downto 0);
            game_over  : out std_logic
        );
    end component;

    -- Signaux de test
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    signal start      : std_logic := '0';
    signal sw_level   : std_logic_vector(1 downto 0) := "00";
    signal btn_r      : std_logic := '0';
    signal btn_g      : std_logic := '0';
    signal btn_b      : std_logic := '0';
    signal led_color  : std_logic_vector(2 downto 0);
    signal score      : std_logic_vector(3 downto 0);
    signal game_over  : std_logic;

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instanciation du FSM
    uut: fsm
        port map (
            clk        => clk,
            reset      => reset,
            start      => start,
            sw_level   => sw_level,
            btn_r      => btn_r,
            btn_g      => btn_g,
            btn_b      => btn_b,
            led_color  => led_color,
            score      => score,
            game_over  => game_over
        );

    -- Génération de l'horloge
    clk_process : process
    begin
        while now < 2 ms loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    -- Stimuli principaux
    stim_proc: process
    begin
        -- Reset initial
        reset <= '1';
        wait for 30 ns;
        reset <= '0';
        wait for 20 ns;

        -- Démarrage du jeu
        start <= '1';
        wait for 20 ns;
        start <= '0';
        wait for 100 ns;

        -- Simule une bonne réponse (rouge)
        -- On suppose que led_color = "100" (rouge) à ce moment
        btn_r <= '1';
        wait for 20 ns;
        btn_r <= '0';
        wait for 100 ns;

        -- Simule une bonne réponse (vert)
        -- On suppose que led_color = "010" (vert) à ce moment
        btn_g <= '1';
        wait for 20 ns;
        btn_g <= '0';
        wait for 100 ns;

        -- Simule une mauvaise réponse (timeout)
        wait for 200 ns;

        -- Redémarrage du jeu après game_over
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 40 ns;
        start <= '1';
        wait for 20 ns;
        start <= '0';

        wait for 500 ns;
        wait;
    end process;

end fsm_tb_arch;

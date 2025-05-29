library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity fsm_tb is
end fsm_tb;

architecture fsm_tb_arch of fsm_tb is

 
    component fsm
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
    signal clk_sim       : std_logic := '0';
    signal reset_sim       : std_logic := '1';
    signal start_sim       : std_logic := '0';
    signal sw_level_sim    : std_logic_vector(1 downto 0) := "00";
    signal btn_r_sim       : std_logic := '0';
    signal btn_g_sim       : std_logic := '0';
    signal btn_b_sim       : std_logic := '0';
    signal led_color_sim   : std_logic_vector(2 downto 0);
    signal score_sim       : std_logic_vector(3 downto 0);
    signal game_over_sim   : std_logic;

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    -- Instanciation de la FSM
    uut: fsm
        port map (
            clk        => clk_sim ,
            reset      => reset_sim ,
            start      => start_sim ,
            sw_level   => sw_level_sim ,
            btn_r      => btn_r_sim ,
            btn_g      => btn_g_sim ,
            btn_b      => btn_b_sim ,
            led_color  => led_color_sim ,
            score      => score_sim ,
            game_over  => game_over_sim 
        );

    
    clk_process : process
    begin
        while now < 2 ms loop
            clk_sim <= '0';
            wait for clk_period/2;
            clk_sim <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    
    stim_proc: process
    begin
    -- Reset initial
    reset_sim  <= '1';
    wait for 30 ns;
    reset_sim  <= '0';
    wait for 20 ns;

    -- Start le jeu
    start_sim  <= '1';
    wait for clk_period;
    start_sim  <= '0';
    wait for 100 ns;

    report "APRES START : score=" & integer'image(to_integer(unsigned(score_sim))) &
           " led_color=" & std_logic'image(led_color_sim(2)) & std_logic'image(led_color_sim(1)) & std_logic'image(led_color_sim(0)) &
           " game_over=" & std_logic'image(game_over_sim);

    -- 1er round : bonne réponse
    if led_color_sim = "100" then
        btn_r_sim <= '1';
    elsif led_color_sim = "010" then
        btn_g_sim <= '1';
    else
        btn_b_sim <= '1';
    end if;
    wait for clk_period;
    btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0';
    wait for 100 ns;

    report "APRES 1ere REPONSE : score=" & integer'image(to_integer(unsigned(score_sim))) &
           " led_color=" & std_logic'image(led_color_sim(2)) & std_logic'image(led_color_sim(1)) & std_logic'image(led_color_sim(0)) &
           " game_over=" & std_logic'image(game_over_sim);

    -- 2e round : bonne réponse (la couleur devrait changer)
    if led_color_sim = "100" then
        btn_r_sim <= '1';
    elsif led_color_sim = "010" then
        btn_g_sim <= '1';
    else
        btn_b_sim <= '1';
    end if;
    wait for clk_period;
    btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0';
    wait for 100 ns;

    report "APRES 2e REPONSE : score=" & integer'image(to_integer(unsigned(score_sim))) &
           " led_color=" & std_logic'image(led_color_sim(2)) & std_logic'image(led_color_sim(1)) & std_logic'image(led_color_sim(0)) &
           " game_over=" & std_logic'image(game_over_sim);

    -- 2e round : mauvaise réponse (appuie sur un bouton faux)
    btn_r_sim <= '1'; -- volontairement faux (sauf si la couleur est rouge)
    wait for clk_period;
    btn_r_sim <= '0';
    wait for 100 ns;

    report "APRES MAUVAISE REPONSE : score=" & integer'image(to_integer(unsigned(score_sim))) &
           " led_color=" & std_logic'image(led_color_sim(2)) & std_logic'image(led_color_sim(1)) & std_logic'image(led_color_sim(0)) &
           " game_over=" & std_logic'image(game_over_sim);

    -- 3e round : laisse passer le temps (timeout)
    wait for 200 ms; -- assez long pour déclencher le timeout

    report "APRES TIMEOUT : score=" & integer'image(to_integer(unsigned(score_sim))) &
           " led_color=" & std_logic'image(led_color_sim(2)) & std_logic'image(led_color_sim(1)) & std_logic'image(led_color_sim(0)) &
           " game_over=" & std_logic'image(game_over_sim);

    for i in 1 to 16 loop
        if led_color_sim = "100" then
            btn_r_sim <= '1';
        elsif led_color_sim = "010" then
            btn_g_sim <= '1';
        else
            btn_b_sim <= '1';
        end if;
        wait for clk_period;
        btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0';
        wait for 100 ns;
        report "SCORE=" & integer'image(to_integer(unsigned(score_sim))) &
               " led_color=" & std_logic'image(led_color_sim(2)) & std_logic'image(led_color_sim(1)) & std_logic'image(led_color_sim(0)) &
               " game_over=" & std_logic'image(game_over_sim);
    end loop;

    wait;
end process;

end fsm_tb_arch;
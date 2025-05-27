
library ieee;
use ieee.std_logic_1164.all;

entity verif_resultat_tb is
end verif_resultat_tb;

architecture  verif_resultat_tb_arch of verif_resultat_tb is
    signal clk_sim       : std_logic := '0';
    signal reset_sim     : std_logic := '0';
    signal timeout_sim   : std_logic := '0';
    signal led_color_sim : std_logic_vector(2 downto 0) := "000";
    signal btn_r_sim     : std_logic := '0';
    signal btn_g_sim     : std_logic := '0';
    signal btn_b_sim     : std_logic := '0';
    signal valid_hit_sim : std_logic;

    component verif_resultat
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            timeout   : in  std_logic;
            led_color : in  std_logic_vector(2 downto 0);
            btn_r     : in  std_logic;
            btn_g     : in  std_logic;
            btn_b     : in  std_logic;
            valid_hit : out std_logic
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
    verif_resultat_inst: verif_resultat
        port map (
            clk       => clk_sim,
            reset     => reset_sim,
            timeout   => timeout_sim,
            led_color => led_color_sim,
            btn_r     => btn_r_sim,
            btn_g     => btn_g_sim,
            btn_b     => btn_b_sim,
            valid_hit => valid_hit_sim
        );

    -- Clock generation
    clk_process: process
    begin
        while now < 240 ns loop
            clk_sim <= '0'; wait for 5 ns;
            clk_sim <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

  
test_proc: process
begin
    -- Reset
    reset_sim <= '1';
    wait for 10 ns;
    reset_sim <= '0';
    wait for 10 ns;

    -- Test 1 : Bon bouton (rouge)
    led_color_sim <= "100"; btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0'; timeout_sim <= '0';
    wait for 10 ns;
    btn_r_sim <= '1';
    wait for 10 ns;
    btn_r_sim <= '0';
    wait for 10 ns;

    -- Test 2 : Mauvais bouton (vert alors que rouge attendu)
    led_color_sim <= "100"; btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0'; timeout_sim <= '0';
    wait for 10 ns;
    btn_g_sim <= '1';
    wait for 10 ns;
    btn_g_sim <= '0';
    wait for 10 ns;

    -- Test 3 : Bon bouton (vert)
    led_color_sim <= "010"; btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0'; timeout_sim <= '0';
    wait for 10 ns;
    btn_g_sim <= '1';
    wait for 10 ns;
    btn_g_sim <= '0';
    wait for 10 ns;

    -- Test 4 : Mauvais bouton (bleu alors que vert attendu)
    led_color_sim <= "010"; btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0'; timeout_sim <= '0';
    wait for 10 ns;
    btn_b_sim <= '1';
    wait for 10 ns;
    btn_b_sim <= '0';
    wait for 10 ns;

    -- Test 5 : Bon bouton (bleu)
    led_color_sim <= "001"; btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0'; timeout_sim <= '0';
    wait for 10 ns;
    btn_b_sim <= '1';
    wait for 10 ns;
    btn_b_sim <= '0';
    wait for 10 ns;

    -- Test 6 : Mauvais bouton (rouge alors que bleu attendu)
    led_color_sim <= "001"; btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0'; timeout_sim <= '0';
    wait for 10 ns;
    btn_r_sim <= '1';
    wait for 10 ns;
    btn_r_sim <= '0';
    wait for 10 ns;

    -- Test 7 : Timeout sans appui
    led_color_sim <= "010"; btn_r_sim <= '0'; btn_g_sim <= '0'; btn_b_sim <= '0'; timeout_sim <= '0';
    wait for 10 ns;
    timeout_sim <= '1';
    wait for 10 ns;
    timeout_sim <= '0';
    wait for 10 ns;

    wait;
end process;

    -- Affichage
    monitor: process(clk_sim)
    begin
        if rising_edge(clk_sim) then
            report "t=" & time'image(now) &
                   " | led_color=" & slv_to_str(led_color_sim) &
                   " | btn_r=" & std_logic'image(btn_r_sim) &
                   " | btn_g=" & std_logic'image(btn_g_sim) &
                   " | btn_b=" & std_logic'image(btn_b_sim) &
                   " | timeout=" & std_logic'image(timeout_sim) &
                   " | valid_hit=" & std_logic'image(valid_hit_sim);
        end if;
    end process;

end  verif_resultat_tb_arch;
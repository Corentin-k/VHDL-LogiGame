
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity score_compteur_tb is
end score_compteur_tb;

architecture score_compteur_tb_arch of score_compteur_tb is
    signal clk_sim       : std_logic := '0';
    signal reset_sim     : std_logic := '0';
    signal valid_hit_sim : std_logic := '0';
    signal score_sim         : std_logic_vector(3 downto 0);
    signal game_over_sim     : std_logic;

    component score_compteur
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            valid_hit : in  std_logic;
            score     : out std_logic_vector(3 downto 0);
            game_over : out std_logic
        );
    end component;
begin

    score_process: score_compteur
        port map (
            clk       => clk_sim,
            reset     => reset_sim,
            valid_hit => valid_hit_sim,
            score     => score_sim,
            game_over => game_over_sim
        );

    clk_process: process
    begin
        while now < 2 us loop
            clk_sim <= '0'; wait for 5 ns;
            clk_sim <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

 
    stim_proc: process
    begin
        -- Reset
        reset_sim <= '1';
        wait for 20 ns;
        reset_sim <= '0';

        -- 5 bonnes réponses
        for i in 1 to 5 loop
            valid_hit_sim <= '1';
            wait for 10 ns;
            valid_hit_sim <= '0';
            wait for 10 ns;
        end loop;

        -- 2 mauvaises réponses
        valid_hit_sim <= '0';
        wait for 30 ns;
        valid_hit_sim <= '0';
        wait for 30 ns;

        -- 10 bonnes réponses pour atteindre 15
        for i in 1 to 10 loop
            valid_hit_sim <= '1';
            wait for 10 ns;
            valid_hit_sim <= '0';
            wait for 10 ns;
        end loop;

        -- Encore une bonne réponse
        valid_hit_sim <= '1';
        wait for 10 ns;
        valid_hit_sim <= '0';
        wait for 10 ns;

        wait;
    end process;

    affichage: process(clk_sim)
    begin
        if rising_edge(clk_sim) then
            
                report "score=" & integer'image(to_integer(unsigned(score_sim)))
                    & " | game_over=" & std_logic'image(game_over_sim)
                    & " | valid_hit=" & std_logic'image(valid_hit_sim);
       
        end if;
    end process;

end  score_compteur_tb_arch;
-- Créer un composant VHDL qui valide si le joueur appuie sur le bon bouton dans le temps imparti.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity score_compteur is
    port (
        clk       : in  std_logic; -- horloge système
        reset     : in  std_logic; --remise à zéro du score
        valid_hit : in  std_logic; -- indiquant la réussite (1) ou l’échec (0)
        score     : out std_logic_vector(3 downto 0); -- score courant codé sur 4 bits
        game_over : out std_logic -- signal indiquant la fin du jeu
    );
end score_compteur;

architecture score_compteur_arch of score_compteur is
    signal score_reg : unsigned(3 downto 0) := (others => '0');
    signal game_over_resultat : std_logic := '0';
begin

     process(clk, reset)
    begin
        if reset = '1' then
            score_reg          <= (others => '0');
            game_over_resultat <= '0';

        elsif rising_edge(clk) then
            if game_over_resultat = '0' then
                if valid_hit = '1' then
                    if score_reg = to_unsigned(15, 4) then
                        -- Si on était déjà à 15, on signale game over
                        game_over_resultat <= '1';
                    else
                        -- Sinon, on incrémente
                        score_reg <= score_reg + 1;
                        if score_reg = to_unsigned(14, 4) then
                            -- On vient d’atteindre 15 → game over aussi
                            game_over_resultat <= '1';
                        end if;
                    end if;

                elsif valid_hit = '0' then
                    -- Faute : arrêt immédiat, on garde le score
                    game_over_resultat <= '1';
                end if;
            end if;
        end if;
    end process;

    score     <= std_logic_vector(score_reg);
    game_over <= game_over_resultat;

end score_compteur_arch;
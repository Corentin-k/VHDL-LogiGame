library ieee;
use ieee.std_logic_1164.all;

entity verif_resultat is
    port (
        clk       : in  std_logic; -- horloge système
        reset     : in  std_logic; -- réinitialisation du module
        timeout   : in  std_logic; -- signal de fin de délai
        led_color : in  std_logic_vector(2 downto 0); -- couleur affichée sur LD3 (3 bits, R=100, G=010, B=001)
        btn_r     : in  std_logic; -- boutons de réponse (BTN1, BTN2, BTN3)
        btn_g     : in  std_logic;
        btn_b     : in  std_logic;
        valid_hit : out std_logic -- passe à '1' si la bonne réponse a été donnée dans les temps
    );
end verif_resultat;

architecture verif_resultat_arch of verif_resultat is
    signal user_pressed : std_logic := '0';
    signal valid_hit_reg : std_logic := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' or timeout = '1' then
            user_pressed <= '0';
            valid_hit_reg <= '0';
        elsif rising_edge(clk) then
            if user_pressed = '0' then
                if led_color = "100" and btn_r = '1' then
                    valid_hit_reg <= '1';
                    user_pressed <= '1';
                elsif led_color = "010" and btn_g = '1' then
                    valid_hit_reg <= '1';
                    user_pressed <= '1';
                elsif led_color = "001" and btn_b = '1' then
                    valid_hit_reg <= '1';
                    user_pressed <= '1';
                else
                    valid_hit_reg <= '0';
                end if;
            else
                valid_hit_reg <= '0';
            end if;
        end if;
    end process;
    valid_hit <= valid_hit_reg;
end verif_resultat_arch;
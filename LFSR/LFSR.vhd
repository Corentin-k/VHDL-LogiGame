library ieee;
use ieee.std_logic_1164.all;

-- Objectif :
-- Synthétiser puis simuler un registre à décalage à rétroaction linéaire (LFSR) sur 4 bits basé sur le polynôme :
-- X4 + X3 + 1
-- Ce LFSR génère une valeur pseudo-aléatoire à chaque exécution, qui pourra être utilisée comme stimulus couleur (ex : modulo 3 pour obtenir rouge, vert ou bleu).

entity lfsr is
    port(
        CLK100MHZ : in std_logic;  -- horloge principale (100 MHz)
        reset : in std_logic;  -- réinitialisation du registre à une valeur initiale non nulle «1011»
        enable : in std_logic;  -- active l’évolution du LFSR à chaque front montant
        rnd : out std_logic_vector(3 downto 0)  -- vecteur de 4 bits représentant la valeur pseudo-aléatoire courante
    );
    end lfsr;
architecture lfsr_arch of lfsr is
    signal resultat : std_logic_vector(3 downto 0) := "1011";
begin
    process(CLK100MHZ, reset)
    begin
        if reset = '1' then
            resultat <= "1011"; -- valeur initiale non nulle
        elsif rising_edge(CLK100MHZ) then
            if enable = '1' then
                 resultat <= resultat(2 downto 0) & (resultat(3) xor resultat(2));
            end if;
        end if;
    end process;
    rnd <= resultat;
end lfsr_arch;

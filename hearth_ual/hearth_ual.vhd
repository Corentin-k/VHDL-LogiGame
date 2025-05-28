library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity hearth_ual is
    port(
        A        : in  std_logic_vector(3 downto 0);
        B        : in  std_logic_vector(3 downto 0);
        SR_IN_L  : in  std_logic;                    -- bit de retenue d'entrée pour décalage à droite
        SR_IN_R  : in  std_logic;                    -- bit de retenue d'entrée pour décalage à gauche et addition

        SEL_FCT  : in  std_logic_vector(3 downto 0); -- SEL_FCT est le code de la fonction à réaliser

        SR_OUT_L : out std_logic;                    -- bit de retenue de sortie gauche
        SR_OUT_R : out std_logic;                    -- bit de retenue de sortie droite
        S        : out std_logic_vector(7 downto 0)   -- résultat ALU 8 bits
    );
end hearth_ual;

architecture hearth_ual_arch of hearth_ual is
begin
    myUALProcess : process(A, B, SR_IN_L, SR_IN_R, SEL_FCT)
        -- Variables internes
        variable grand_A         : std_logic_vector(7 downto 0);
        variable grand_B         : std_logic_vector(7 downto 0);
        variable carry_in_left   : std_logic;
        variable carry_in_right  : std_logic;
        variable carry_out_left  : std_logic;
        variable carry_out_right : std_logic;
        variable resultat        : std_logic_vector(7 downto 0);
    begin

        -- Extension de signe pour A et B (4 bits à 8 bits)
        grand_A(7 downto 4) := (others => A(3));
        grand_A(3 downto 0) := A;
        grand_B(7 downto 4) := (others => B(3));
        grand_B(3 downto 0) := B;
        
        -- Récupération des retenues d'entrée
        carry_in_left  := SR_IN_L;
        carry_in_right := SR_IN_R;
        
        -- Valeurs par défaut
        carry_out_left  := '0';
        carry_out_right := '0';
        resultat        := (others => '0');

        case SEL_FCT is

            when "0000" => -- nop (no operation) S = 0 | SR_OUT_L = 0 et SR_OUT_R = 0
                null;
            when "0001" => -- S = A | SR_OUT_L = 0 et SR_OUT_R = 0
                resultat      := "0000" & A;
            when "0010" => -- S = B | SR_OUT_L = 0 et SR_OUT_R = 0
                resultat      := "0000" & B;
            when "0011" => -- S = not A | SR_OUT_L = 0 et SR_OUT_R = 0
                resultat      := "0000" & not A;
            when "0100" => -- S = not B | SR_OUT_L = 0 et SR_OUT_R = 0
                resultat      := "0000" & not B;
            when "0101" => -- S = A and B | SR_OUT_L = 0 et SR_OUT_R = 0
                resultat      := "0000" & (A and B);
            when "0110" => -- S = A or B | SR_OUT_L = 0 et SR_OUT_R = 0
                resultat      := "0000" & (A or B);
            when "0111" => -- S = A xor B | SR_OUT_L = 0 et SR_OUT_R = 0
                resultat      := "0000" & (A xor B);
            when "1000" => -- S = Déc. droite A sur 4 bits (avec SR_IN_L) | SR_IN_L pour le bit entrant et SR_OUT_R pour le bit sortant
                resultat(2 downto 0) := A(3 downto 1);
                resultat(3)          := carry_in_left;
                carry_out_right      := A(0);
            when "1001" => -- S = Déc. gauche A sur 4 bits (avec SR_IN_R) | SR_IN_R pour le bit entrant et SR_OUT_L pour le bit sortant
                resultat(3 downto 1) := A(2 downto 0);
                resultat(0)          := carry_in_right;
                carry_out_left       := A(3);
            when "1010" => -- S = Déc. droite B sur 4 bits (avec SR_IN_L) | SR_IN_L pour le bit entrant et SR_OUT_R pour le bit sortant
                resultat(2 downto 0) := B(3 downto 1);
                resultat(3)          := carry_in_left;
                carry_out_right      := B(0);
            when "1011" => -- S = Déc. gauche B sur 4 bits (avec SR_IN_R) | SR_IN_R pour le bit entrant et SR_OUT_L pour le bit sortant
                resultat(3 downto 1) := B(2 downto 0);
                resultat(0)          := carry_in_right;
                carry_out_left       := B(3);
           
            when "1100" =>  -- S = A + B avec retenue d'entrée (SR_IN_R)
                resultat      := grand_A + grand_B + ("0000000" & carry_in_right);
            when "1101" =>  -- S = A + B sans retenue d'entrée
                resultat      := grand_A + grand_B;
            when "1110" =>  -- S = A - B (soustraction binaire)
                resultat      := grand_A - grand_B;
            when "1111" =>  -- S = A * B (multiplication binaire)
                resultat      := A * B;
            when others =>
                resultat      := (others => '0');
        end case;
        -- Assignation des sorties
        S        <= resultat;
        SR_OUT_L <= carry_out_left;
        SR_OUT_R <= carry_out_right;
    end process myUALProcess;
end hearth_ual_arch;

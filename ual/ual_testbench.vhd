-- Testbench complet corrigé pour Hearth_UAL avec affichage en décimal

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ual_testbench is
end entity;

architecture behavior of ual_testbench is

    component Hearth_UAL is
        port (
            A        : in  std_logic_vector(3 downto 0);
            B        : in  std_logic_vector(3 downto 0);
            SR_IN_L  : in  std_logic;
            SR_IN_R  : in  std_logic;
            SEL_FCT  : in  std_logic_vector(3 downto 0);
            SR_OUT_L : out std_logic;
            SR_OUT_R : out std_logic;
            S        : out std_logic_vector(7 downto 0)
        );
    end component;

    signal A_s, B_s      : std_logic_vector(3 downto 0) := (others => '0');
    signal SR_IN_L_s     : std_logic := '0';
    signal SR_IN_R_s     : std_logic := '0';
    signal SEL_s         : std_logic_vector(3 downto 0) := (others => '0');
    signal SR_OUT_L_s    : std_logic;
    signal SR_OUT_R_s    : std_logic;
    signal S_s           : std_logic_vector(7 downto 0);

begin

    uut: Hearth_UAL
        port map (
            A        => A_s,
            B        => B_s,
            SR_IN_L  => SR_IN_L_s,
            SR_IN_R  => SR_IN_R_s,
            SEL_FCT  => SEL_s,
            SR_OUT_L => SR_OUT_L_s,
            SR_OUT_R => SR_OUT_R_s,
            S        => S_s
        );

    stim_proc: process
        procedure display_case(name : string) is
        begin
            report "Test: " & name & " | A=" & integer'image(to_integer(unsigned(A_s))) &
                   " B=" & integer'image(to_integer(unsigned(B_s))) &
                   " SR_IN_L=" & std_logic'image(SR_IN_L_s) &
                   " SR_IN_R=" & std_logic'image(SR_IN_R_s) &
                   " SEL_FCT=" & integer'image(to_integer(unsigned(SEL_s))) &
                   " S=" & integer'image(to_integer(unsigned(S_s))) &
                   " SR_OUT_L=" & std_logic'image(SR_OUT_L_s) &
                   " SR_OUT_R=" & std_logic'image(SR_OUT_R_s);
        end procedure;

        procedure test_case(
            signal_name : string;
            sel_val     : std_logic_vector(3 downto 0);
            a_val, b_val : std_logic_vector(3 downto 0);
            sr_in_l, sr_in_r : std_logic;
            expected_S  : std_logic_vector(7 downto 0);
            expected_L, expected_R : std_logic := '0'
        ) is
        begin
            SEL_s <= sel_val;
            A_s <= a_val;
            B_s <= b_val;
            SR_IN_L_s <= sr_in_l;
            SR_IN_R_s <= sr_in_r;
            wait for 10 ns;
            display_case(signal_name);
            assert S_s = expected_S report signal_name & ": S incorrect" severity error;
            assert SR_OUT_L_s = expected_L report signal_name & ": SR_OUT_L incorrect" severity error;
            assert SR_OUT_R_s = expected_R report signal_name & ": SR_OUT_R incorrect" severity error;
        end procedure;

    begin

        test_case("NOP",        "0000", "0000", "0000", '0', '0', (others => '0'));
        test_case("S=A",        "0001", "0010", "0000", '0', '0', "00000010");
        test_case("S=B",        "0010", "0000", "0011", '0', '0', "00000011");
        test_case("S=not A",    "0011", "0101", "0000", '0', '0', "00001010");
        test_case("S=not B",    "0100", "0000", "1001", '0', '0', "00000110");
        test_case("S=A and B",  "0101", "0110", "0101", '0', '0', "00000100");
        test_case("S=A or B",   "0110", "0100", "0011", '0', '0', "00000111");
        test_case("S=A xor B",  "0111", "0111", "0010", '0', '0', "00000101");

        test_case("Shift droit A", "1000", "1010", "0000", '1', '0', "00001101", '0', '0');
        SR_IN_L_s <= '0';

        test_case("Shift gauche A", "1001", "1100", "0000", '0', '1', "00001001", '1', '0');
        SR_IN_R_s <= '0';

        test_case("Shift droit B", "1010", "0000", "0110", '1', '0', "00001011", '0', '0');
        SR_IN_L_s <= '0';

        test_case("Shift gauche B", "1011", "0000", "0011", '0', '1', "00000111", '0', '0');
        SR_IN_R_s <= '0';

        test_case("Addition A+B+SR_IN_R", "1100", "0010", "0011", '0', '1', "00000110");
        SR_IN_R_s <= '0';

        test_case("Addition A+B", "1101", "0100", "0010", '0', '0', "00000110");
        test_case("Soustraction A-B", "1110", "0111", "0011", '0', '0', "00000100");

        report "Tous les tests passés avec succès." severity note;
        wait;

    end process;

end architecture behavior;
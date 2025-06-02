library ieee;
use ieee.std_logic_1164.all;

entity top_level_tb is
end top_level_tb;

architecture top_level_tb_arch of top_level_tb is

    -- Composant à tester
    component top_level
        port (
            CLK100MHZ : in std_logic;
            sw        : in std_logic_vector(3 downto 0);
            btn       : in std_logic_vector(3 downto 0);
            led       : out std_logic_vector(3 downto 0);
            led0_r, led0_g, led0_b : out std_logic;
            led1_r, led1_g, led1_b : out std_logic;
            led2_r, led2_g, led2_b : out std_logic;
            led3_r, led3_g, led3_b : out std_logic
        );
    end component;

    -- Signaux de test
    signal clk  : std_logic := '0';
    signal sw   : std_logic_vector(3 downto 0) := (others => '0');
    signal btn  : std_logic_vector(3 downto 0) := (others => '0');
    signal led  : std_logic_vector(3 downto 0);
    signal led0_r, led0_g, led0_b : std_logic;
    signal led1_r, led1_g, led1_b : std_logic;
    signal led2_r, led2_g, led2_b : std_logic;
    signal led3_r, led3_g, led3_b : std_logic;

    function to_string(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
    begin
        for i in slv'range loop
            result(slv'length - (i - slv'low)) := character'VALUE(std_ulogic'image(slv(i)));
        end loop;
        return result;
    end function;

begin

    -- Instanciation du top-level
    top_level_inst: top_level
        port map (
            CLK100MHZ => clk,
            sw        => sw,
            btn       => btn,
            led       => led,
            led0_r    => led0_r, led0_g => led0_g, led0_b => led0_b,
            led1_r    => led1_r, led1_g => led1_g, led1_b => led1_b,
            led2_r    => led2_r, led2_g => led2_g, led2_b => led2_b,
            led3_r    => led3_r, led3_g => led3_g, led3_b => led3_b
        );

    -- Génération de l'horloge
    clk_process : process
    begin
        while now < 4000 ns loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    stim_proc : process
    begin

        report " Test du top_level" severity note;
        -- Initialisation
        sw <= "1111"; -- A = 3, B = 3
     
        wait for 20 ns;
        report "----------------------------";
        report "Appuie sur le bouton 0 pour réinitialiser" severity note;
        btn <= "0001";
        wait for 1000 ns;
        btn <= "0000";
        wait for 100 ns;
        report "BTN 0 reset : " 
               & std_ulogic'image(led(3))
            & std_ulogic'image(led(2))
             & std_ulogic'image(led(1))
             & std_ulogic'image(led(0))
             & std_ulogic'image(led3_g)
             & std_ulogic'image(led2_g)
             & std_ulogic'image(led1_g)
             & std_ulogic'image(led0_g)
            & " | sw=" & to_string(sw);

        report "----------------------------";    
        report "Appuie sur le bouton 1 pour tester la premiere fonction : " severity note;

        wait for 300 ns;
        btn <= "0010";
        wait for 500 ns;
        btn <= "0000";
        wait for 100 ns;


        report "A*B : " 
               & std_ulogic'image(led(3))
            & std_ulogic'image(led(2))
             & std_ulogic'image(led(1))
             & std_ulogic'image(led(0))
             & std_ulogic'image(led3_g)
             & std_ulogic'image(led2_g)
             & std_ulogic'image(led1_g)
             & std_ulogic'image(led0_g)
            & " | sw=" & to_string(sw);

        report "----------------------------";    
        report "Appuie sur le bouton 2 pour tester la deuxieme fonction : " severity note;
    
        wait for 300 ns;
        btn <= "0100";
        wait for 500 ns;
        btn <= "0000";
        wait for 100 ns;
        
        report "(A + B) xnor  A =" 
                & std_ulogic'image(led(3))
            & std_ulogic'image(led(2))
             & std_ulogic'image(led(1))
             & std_ulogic'image(led(0))
             & std_ulogic'image(led3_g)
             & std_ulogic'image(led2_g)
             & std_ulogic'image(led1_g)
             & std_ulogic'image(led0_g)
            & " | sw=" & to_string(sw);

        report "----------------------------";    
        report "Appuie sur le bouton 3 pour tester la troisieme fonction : " severity note;

        wait for 300 ns;
        btn <= "1000";
        wait for 500 ns;
        btn <= "0000";
        wait for 100 ns;

        report "(A0 and  B1) or (A1 and B0) ="
            & std_ulogic'image(led(3))
            & std_ulogic'image(led(2))
             & std_ulogic'image(led(1))
             & std_ulogic'image(led(0))
             & std_ulogic'image(led3_g)
             & std_ulogic'image(led2_g)
             & std_ulogic'image(led1_g)
             & std_ulogic'image(led0_g)
            & " | sw=" & to_string(sw);

        assert false report "Fin de simulation à 5000 ns" severity failure;
    end process;

end top_level_tb_arch;
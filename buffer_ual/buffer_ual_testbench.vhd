library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity buffer_ual_tb is
end buffer_ual_tb;

architecture tb_arch of buffer_ual_tb is

    component buffer_ual
        generic (N : integer := 4);
        port (
            e1     : in  std_logic_vector(N-1 downto 0);
            reset  : in  std_logic;
            clock  : in  std_logic;
            enable : in  std_logic;
            s1     : out std_logic_vector(N-1 downto 0)
        );
    end component;

    signal clk_sim    : std_logic := '0';
    signal reset_sim    : std_logic := '0';
    signal enable_sim1    : std_logic := '1';
    signal enable_sim2    : std_logic := '0';
    signal e_sim1    : std_logic_vector(3 downto 0) := (others => '0');
    signal e_sim2    : std_logic_vector(2 downto 0) := (others => '0');
    signal s1_sim1   : std_logic_vector(3 downto 0);
    signal s1_sim2   : std_logic_vector(2 downto 0);

begin

    -- Buffer avec enable actif
    buf1 : buffer_ual
        generic map (N => 4)
        port map (
            e1     => e_sim1,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => '1',
            s1     => s1_sim1
        );

    -- Buffer avec enable inactif
    buf2 : buffer_ual
        generic map (N => 3)
        port map (
            e1     => e_sim2,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => enable_sim2,
            s1     => s1_sim2
        );

    -- Génération de l'horloge
    clk_process : process
    begin
        while now < 200 ns loop
            clk_sim <= '0'; wait for 5 ns;
            clk_sim <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Stimulus
    stim_proc : process
    begin
       
        report "Buffer 4 bits sans enable : " severity note;

        -- Test buffer avec enable actif
        e_sim1 <= "1010";
        wait for 10 ns;
        report "e1_sim:" & integer'image(to_integer(unsigned(e_sim1))) severity note;
        report "s1_sim1: " & integer'image(to_integer(unsigned(s1_sim1))) severity note;

        e_sim1 <= "0101";
        wait for 10 ns;
        report "e1_sim:" & integer'image(to_integer(unsigned(e_sim1))) severity note;
        report "s1_sim1: " & integer'image(to_integer(unsigned(s1_sim1))) severity note;

        report "-------------------------------" severity note;
        -- Test buffer avec enable inactif (doit rester à 0)
        report "Buffer 3 bits avec enable : " severity note;
        e_sim2 <= "111";
         report "e2_sim:" & integer'image(to_integer(unsigned(e_sim2))) severity note;
        report "s2_sim1: " & integer'image(to_integer(unsigned(s1_sim2))) severity note;

        wait for 10 ns;
        e_sim2 <= "001";
        wait for 10 ns;
        report "e2_sim:" & integer'image(to_integer(unsigned(e_sim2))) severity note;
        report "Valeur de s1_sim2: " & integer'image(to_integer(unsigned(s1_sim2)))  severity note;
        
        report ">>> Activation de enable ! "severity note;
        -- Désactive enable sur buf1, la sortie doit rester inchangée
        enable_sim2 <= '1';
        e_sim2 <= "111";
        wait for 10 ns;
        enable_sim2 <= '0';
        report "e2_sim:" & integer'image(to_integer(unsigned(e_sim2))) severity note;
        report "Valeur de s1_sim2 après activation enable: " & integer'image(to_integer(unsigned(s1_sim2))) severity note;
       
        wait for 10 ns;

        report ">>> Remodification de la valeur sans activer enable ! "severity note;
        wait for 10 ns;
        e_sim2 <= "001";
        wait for 10 ns;
        report "e2_sim:" & integer'image(to_integer(unsigned(e_sim2))) severity note;
        report "Valeur de s1_sim2: " & integer'image(to_integer(unsigned(s1_sim2)))  severity note;

        wait for 10 ns;
       wait;
    end process;

end tb_arch;
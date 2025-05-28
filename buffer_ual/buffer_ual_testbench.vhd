library ieee;
use ieee.std_logic_1164.all;

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

    function slv_to_str(slv : std_logic_vector) return string is
        variable result : string(1 to slv'length);
    begin
        for i in slv'range loop
            result(i - slv'low + 1) := character'VALUE(std_ulogic'image(slv(i)));
        end loop;
        return result;
    end function;

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
       

        -- Test buffer avec enable actif
        e_sim1 <= "1010";
        wait for 10 ns;
        e_sim1 <= "0101";
        wait for 10 ns;

        report "Valeur de s1_sim1: " & slv_to_str(s1_sim1) severity note;

        -- Test buffer avec enable inactif (doit rester à 0)
        e_sim2 <= "111";
        wait for 10 ns;
        e_sim2 <= "001";
        wait for 10 ns;
        report "Valeur de s1_sim2: " & slv_to_str(s1_sim2) severity note;
        
        -- Désactive enable sur buf1, la sortie doit rester inchangée
        enable_sim2 <= '1';
        e_sim2 <= "101";
        wait for 10 ns;
        report "Valeur de s1_sim2 après activation enable: " & slv_to_str(s1_sim2) severity note;
       

        assert false report "Fin de simulation" severity failure;
    end process;

end tb_arch;
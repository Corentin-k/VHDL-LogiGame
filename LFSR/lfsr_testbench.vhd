

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr_tb is
end lfsr_tb;

architecture lfsr_tb_arch of lfsr_tb is
    signal clk_sim    : std_logic := '0';
    signal reset_sim  : std_logic := '0';
    signal enable_sim : std_logic := '0';
    signal rnd_sim    : std_logic_vector(3 downto 0);

    component lfsr
        port (
            CLK100MHZ : in std_logic;
            reset     : in std_logic;
            enable    : in std_logic;
            rnd       : out std_logic_vector(3 downto 0)
        );
    end component;
begin

    lfsr_inst: lfsr
        port map (
            CLK100MHZ => clk_sim,
            reset     => reset_sim,
            enable    => enable_sim,
            rnd       => rnd_sim
        );

   clk_process: process
    begin
        while now < 5000 ns loop
            clk_sim <= '0'; wait for 5 ns;
            clk_sim <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    process_lfsr: process
    begin

        reset_sim <= '1';
        enable_sim <= '0';
        wait for 20 ns;
        reset_sim <= '0';
        enable_sim <= '1';

        wait for 300 ns;

        enable_sim <= '0';
        wait for 20 ns;

        reset_sim <= '1';
        enable_sim <= '0';
        wait for 20 ns;
        reset_sim <= '0';
        enable_sim <= '1';

        wait for 300 ns;

        enable_sim <= '0';
        wait for 20 ns;

        wait;
    end process;
  affichage: process(clk_sim)
    begin
        if rising_edge(clk_sim) and enable_sim = '1' then
            report "rnd = " & integer'image(to_integer(unsigned(rnd_sim)));
        end if;
end process;

end lfsr_tb_arch;
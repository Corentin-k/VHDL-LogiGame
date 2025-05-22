

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ghdl -a lfsr.vhd lfsr_tb.vhd
-- ghdl -e lfsr_tb
-- ghdl -r lfsr_tb --vcd=lfsr_tb.vcd
-- gtkwave lfsr_tb.vcd

entity lfsr_tb is
end lfsr_tb;

architecture lfsr_tb_arch of lfsr_tb is
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal enable : std_logic := '0';
    signal rnd    : std_logic_vector(3 downto 0);

    component LFSR
        port (
            CLK100MHZ : in std_logic;
            reset     : in std_logic;
            enable    : in std_logic;
            rnd       : out std_logic_vector(3 downto 0)
        );
    end component;
begin
    
    LFSR_test: LFSR
        port map (
            CLK100MHZ => clk,
            reset     => reset,
            enable    => enable,
            rnd       => rnd
        );

   
    clk_process: process
    begin
        while now < 5000 ns loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process;

    procLFSR: process
    begin
        
        reset <= '1';
        enable <= '0';
        wait for 20 ns;
        reset <= '0';
        enable <= '1';

        wait for 300 ns;

        enable <= '0';
        wait for 20 ns;

        reset <= '1';
        enable <= '0';
        wait for 20 ns;
        reset <= '0';
        enable <= '1';

        wait for 300 ns;

        enable <= '0';
        wait for 20 ns;

        wait;
    end process;
  monitor: process(clk)
    begin
        if rising_edge(clk) and enable = '1' then
            report "rnd = " & integer'image(to_integer(unsigned(rnd)));
        end if;
end process;

end lfsr_tb_arch;
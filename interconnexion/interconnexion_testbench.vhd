-- Testbench pour l'entité interconnexion
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity interconnexion_testbench is
end interconnexion_testbench;

architecture interconnexion_testbench_arch of interconnexion_testbench is

    component interconnexion is
        port(
            SEL_ROUTE              : in  std_logic_vector(3 downto 0);
            A_IN                   : in  std_logic_vector(3 downto 0);
            B_IN                   : in  std_logic_vector(3 downto 0);
            S                      : in  std_logic_vector(7 downto 0);
            MEM_CACHE_1_in         : in  std_logic_vector(7 downto 0);
            MEM_CACHE_1_out_enable : out std_logic;
            MEM_CACHE_1_out        : out std_logic_vector(7 downto 0);
            MEM_CACHE_2_in         : in  std_logic_vector(7 downto 0);
            MEM_CACHE_2_out_enable : out std_logic;
            MEM_CACHE_2_out        : out std_logic_vector(7 downto 0);
            Buffer_A               : out std_logic_vector(3 downto 0);
            Buffer_A_enable        : out std_logic;
            Buffer_B               : out std_logic_vector(3 downto 0);
            Buffer_B_enable        : out std_logic;
            SEL_OUT                : in  std_logic_vector(1 downto 0);
            RES_OUT                : out std_logic_vector(7 downto 0)
        );
    end component;

    signal SEL_ROUTE_sim              : std_logic_vector(3 downto 0) := (others => '0');
    signal A_IN_sim                   : std_logic_vector(3 downto 0) := (others => '0');
    signal B_IN_sim                   : std_logic_vector(3 downto 0) := (others => '0');
    signal S_sim                      : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_1_in_sim         : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_1_out_enable_sim : std_logic;
    signal MEM_CACHE_1_out_sim        : std_logic_vector(7 downto 0);
    signal MEM_CACHE_2_in_sim         : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_2_out_enable_sim : std_logic;
    signal MEM_CACHE_2_out_sim        : std_logic_vector(7 downto 0);
    signal Buffer_A_sim               : std_logic_vector(3 downto 0);
    signal Buffer_A_enable_sim        : std_logic;
    signal Buffer_B_sim               : std_logic_vector(3 downto 0);
    signal Buffer_B_enable_sim        : std_logic;
    signal SEL_OUT_sim                : std_logic_vector(1 downto 0) := (others => '0');
    signal RES_OUT_sim                : std_logic_vector(7 downto 0);

begin
    UUT: interconnexion
        port map (
            SEL_ROUTE              => SEL_ROUTE_sim,
            A_IN                   => A_IN_sim,
            B_IN                   => B_IN_sim,
            S                      => S_sim,
            MEM_CACHE_1_in         => MEM_CACHE_1_in_sim,
            MEM_CACHE_1_out_enable => MEM_CACHE_1_out_enable_sim,
            MEM_CACHE_1_out        => MEM_CACHE_1_out_sim,
            MEM_CACHE_2_in         => MEM_CACHE_2_in_sim,
            MEM_CACHE_2_out_enable => MEM_CACHE_2_out_enable_sim,
            MEM_CACHE_2_out        => MEM_CACHE_2_out_sim,
            Buffer_A               => Buffer_A_sim,
            Buffer_A_enable        => Buffer_A_enable_sim,
            Buffer_B               => Buffer_B_sim,
            Buffer_B_enable        => Buffer_B_enable_sim,
            SEL_OUT                => SEL_OUT_sim,
            RES_OUT                => RES_OUT_sim
        );

    stimulus: process
    begin
        -- Test routage A_IN vers Buffer_A
        A_IN_sim <= "1010";
        SEL_ROUTE_sim <= "0000";
        wait for 10 ns;
        
        -- Test S vers MEM_CACHE_1_out
        S_sim <= "00000001";
        SEL_ROUTE_sim <= "1110";
        wait for 10 ns;
    

        -- Test S vers RES_OUT via SEL_OUT
        SEL_ROUTE_sim <= "0000";
        S_sim <= "00000011";
        
        SEL_OUT_sim <= "11";
        wait for 10 ns;
      
        wait;
    end process;

end interconnexion_testbench_arch;
-- Testbench pour l'entité interconnexion
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity interconnexion_tb is
end interconnexion_tb;

architecture interconnexion_tb_arch of interconnexion_tb is

    component  interconnexion 
    port(
       
        SEL_ROUTE : in std_logic_vector(3 downto 0); -- Sélecteur de route
        
        A_IN      : in std_logic_vector(3 downto 0); -- Entrée A
        B_IN      : in std_logic_vector(3 downto 0); -- Entrée B
        S         : in std_logic_vector(7 downto 0); -- Entrée S
        
       
        MEM_CACHE_1_in: in std_logic_vector(7 downto 0); -- Mémoire cache 1
        MEM_CACHE_1_out_enable : out std_logic; -- Signal d'activation pour MEM_CACHE_1_ou
        MEM_CACHE_1_out : out std_logic_vector(7 downto 0); -- Sortie vers MEM_CACHE_1_out

        MEM_CACHE_2_in : in std_logic_vector(7 downto 0); -- Mémoire cache 2
        MEM_CACHE_2_out_enable : out std_logic; -- Signal d'activation pour MEM_CACHE_2_out_enable
        MEM_CACHE_2_out : out std_logic_vector(7 downto 0); -- Sortie vers MEM_CACHE_2_out
        
        Buffer_A  : out std_logic_vector(3 downto 0); -- Sortie vers Buffer A
        Buffer_A_enable : out std_logic; -- Signal d'activation pour Buffer A
        
        Buffer_B  : out std_logic_vector(3 downto 0); -- Sortie vers Buffer B
        Buffer_B_enable : out std_logic; -- Signal d'activation pour Buffer B

        SEL_OUT : in std_logic_vector(1 downto 0); -- Sélecteur de sortie
        RES_OUT : out std_logic_vector(7 downto 0); -- Sortie
        ready   : out std_logic
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
    signal ready_sim                  : std_logic;
begin
    interconnexion_inst: interconnexion
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
            RES_OUT                => RES_OUT_sim,
            ready   => ready_sim 
        );
    process
    begin

        -- Test routage A_IN vers Buffer_A
        report "---------------------------";
        report "Test routage A_IN vers Buffer_A"  severity note;
        A_IN_sim <= "1010";
        SEL_ROUTE_sim <= "0000";
        wait for 10 ns;
        report "SEL_ROUTE = " & integer'image(to_integer(unsigned(SEL_ROUTE_sim)))
                & " A_IN = " & integer'image(to_integer(unsigned(A_IN_sim))) 
                & " Buffer_A: " & integer'image(to_integer(unsigned(Buffer_A_sim)));

        -- Test S vers MEM_CACHE_1_out
        report "---------------------------";
        report "Test S vers MEM_CACHE_1_out"  severity note;
        S_sim <= "00000001";
        SEL_ROUTE_sim <= "1110";
        wait for 10 ns;
        report "SEL_ROUTE = " & integer'image(to_integer(unsigned(SEL_ROUTE_sim)))
               & " S = " & integer'image(to_integer(unsigned(S_sim))) 
               & " MEM_CACHE_1_out: " & integer'image(to_integer(unsigned(MEM_CACHE_1_out_sim)));

        -- Test S vers RES_OUT
        report "---------------------------";
        report "Test S vers RES_OUT"  severity note;
        SEL_ROUTE_sim <= "0000";
        S_sim <= "00000011";
        
        SEL_OUT_sim <= "11";
        wait for 10 ns;
        report "SEL_ROUTE = " & integer'image(to_integer(unsigned(SEL_ROUTE_sim)))
               & " S = " & integer'image(to_integer(unsigned(S_sim))) & 
               " RES_OUT: " & integer'image(to_integer(unsigned(RES_OUT_sim))) & 
               " ready (le calcul est effectué)= " & std_logic'image(ready_sim);
        wait;
    end process;

end interconnexion_tb_arch;
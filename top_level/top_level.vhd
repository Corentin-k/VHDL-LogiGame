library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use ieee.numeric_std.all; -- tu peux garder cette ligne si tu fais des opérations arithmétiques, sinon tu peux la retirer

entity top_level is
    Port (
        CLK100MHZ : in STD_LOGIC;
        sw : in STD_LOGIC_VECTOR(3 downto 0);
        btn : in STD_LOGIC_VECTOR(3 downto 0);

        led : out STD_LOGIC_VECTOR(3 downto 0);

        led0_r : out STD_LOGIC; led0_g : out STD_LOGIC; led0_b : out STD_LOGIC;                
        led1_r : out STD_LOGIC; led1_g : out STD_LOGIC; led1_b : out STD_LOGIC;
        led2_r : out STD_LOGIC; led2_g : out STD_LOGIC; led2_b : out STD_LOGIC;                
        led3_r : out STD_LOGIC; led3_g : out STD_LOGIC; led3_b : out STD_LOGIC
    );
end top_level;

architecture top_level_arch of top_level is

    
    
    type state_t is (IDLE, FUNCT_1, FUNCT_2, FUNCT_3);
    signal FSM_Main : state_t := IDLE; -- Etat de départ

    signal MyCounter : std_logic_vector(6 downto 0) := (others => '0');


    signal RES_OUT_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal ready_reg   : std_logic := '0';
    signal btn_prev : std_logic_vector(3 downto 0) := (others => '0');
    signal ready_prev : std_logic := '0';
    signal calcul_en_cours : std_logic := '0';

    signal reset_sim : std_logic;
    signal addr_sim : std_logic_vector(6 downto 0) := (others => '0');
    signal instr_sim : std_logic_vector(9 downto 0);

    signal RES_OUT_sim : std_logic_vector(7 downto 0);

    -- Signaux pour les buffers 8 bits
    signal MEM_CACHE_1_in_sim, MEM_CACHE_2_in_sim : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_1_out_sim, MEM_CACHE_2_out_sim : std_logic_vector(7 downto 0);
    signal MEM_CACHE_1_enable_sim, MEM_CACHE_2_enable_sim : std_logic := '0';

    -- Buffers 4 bits
    signal Buffer_A_sim, Buffer_B_sim : std_logic_vector(3 downto 0);
    signal Buffer_A_enable_sim, Buffer_B_enable_sim : std_logic := '0';
    signal bufferA_out, bufferB_out : std_logic_vector(3 downto 0);
    signal SR_IN_L_sim, SR_IN_R_sim : std_logic:= '0';

    signal SEL_FCT_sim   : std_logic_vector(3 downto 0);
    signal SEL_ROUTE_sim : std_logic_vector(3 downto 0);
    signal SEL_OUT_sim   : std_logic_vector(1 downto 0);

    -- Registres
    signal SEL_FCT_reg   : std_logic_vector(3 downto 0);
    signal SEL_ROUTE_reg : std_logic_vector(3 downto 0);
    signal SEL_OUT_reg   : std_logic_vector(1 downto 0);
    signal SR_IN_L_reg, SR_IN_R_reg : std_logic;

    -- UAL
    signal S_sim : std_logic_vector(7 downto 0);
    signal SR_OUT_L_sim, SR_OUT_R_sim : std_logic;

    signal SR_OUT_L_vec, SR_OUT_R_vec : std_logic_vector(0 downto 0);
    signal SR_IN_L_vec, SR_IN_R_vec   : std_logic_vector(0 downto 0);

    -- Interconnexion
    signal A_IN_sim, B_IN_sim : std_logic_vector(3 downto 0) := (others => '0');

    signal ready_sim : std_logic;

    -- ==========================================================================
    -- Déclaration des composants
    -- ==========================================================================
    component mem_instructions
        port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            instruction : in  std_logic_vector(6 downto 0); -- CORRIGÉ : plus de unsigned
            donnee     : out std_logic_vector(9 downto 0)
        );
    end component;

    component hearth_ual
        port(
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

    component interconnexion
        port(
            SEL_ROUTE : in std_logic_vector(3 downto 0);
            A_IN      : in std_logic_vector(3 downto 0);
            B_IN      : in std_logic_vector(3 downto 0);
            S         : in std_logic_vector(7 downto 0);
            MEM_CACHE_1_in: in std_logic_vector(7 downto 0);
            MEM_CACHE_1_out_enable : out std_logic;
            MEM_CACHE_1_out : out std_logic_vector(7 downto 0);
            MEM_CACHE_2_in : in std_logic_vector(7 downto 0);
            MEM_CACHE_2_out_enable : out std_logic;
            MEM_CACHE_2_out : out std_logic_vector(7 downto 0);
            Buffer_A  : out std_logic_vector(3 downto 0);
            Buffer_A_enable : out std_logic;
            Buffer_B  : out std_logic_vector(3 downto 0);
            Buffer_B_enable : out std_logic;
            SEL_OUT : in std_logic_vector(1 downto 0);
            RES_OUT : out std_logic_vector(7 downto 0);
            ready   : out std_logic
        );
    end component;

    component buffer_ual is
        generic (
            N : integer := 4  
        );
        port (
            e1 : in std_logic_vector (N-1 downto 0);
            reset : in std_logic;
            clock : in std_logic;
            enable : in std_logic;
            s1 : out std_logic_vector (N-1 downto 0)
        );
    end  component; 
    
    -- Fonction d'incrémentation sans unsigned
    function slv_inc(slv : std_logic_vector) return std_logic_vector is
        variable tmp : integer := 0;
        variable res : std_logic_vector(slv'range);
    begin
        for i in slv'range loop
            tmp := tmp * 2;
            if slv(i) = '1' then
                tmp := tmp + 1;
            end if;
        end loop;
        tmp := tmp + 1;
        for i in slv'reverse_range loop
            if (tmp mod 2) = 1 then
                res(i) := '1';
            else
                res(i) := '0';
            end if;
            tmp := tmp / 2;
        end loop;
        return res;
    end function;

begin

    -- Buffer A
    buffer_A_inst : buffer_ual
        generic map (N => 4)
        port map (
            e1 => Buffer_A_sim,
            reset => reset_sim,
            clock => CLK100MHZ ,
            enable => Buffer_A_enable_sim,
            s1 => bufferA_out
        );
    -- Buffer B
    buffer_B_inst : buffer_ual
        generic map (N => 4)
        port map (
            e1 => Buffer_B_sim,
            reset => reset_sim,
            clock => CLK100MHZ ,
            enable => Buffer_B_enable_sim,
            s1 => bufferB_out
        );
    -- Mémoire cache 1
    mem_cache_1_inst : buffer_ual
        generic map (N => 8)
        port map (
            e1     => MEM_CACHE_1_in_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ ,
            enable => MEM_CACHE_1_enable_sim,
            s1     => MEM_CACHE_1_out_sim
        );
    -- Mémoire cache 2
    mem_cache_2_inst : buffer_ual
        generic map (N => 8)
        port map (
            e1     => MEM_CACHE_2_in_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ ,
            enable => MEM_CACHE_2_enable_sim,
            s1     => MEM_CACHE_2_out_sim
        );

    -- ==========================================================================
    -- Buffers de commande (pour signaux de contrôle)
    -- ==========================================================================
    buffer_cmd_fct : buffer_ual
        generic map (N => 4)
        port map (
            e1     => SEL_FCT_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ ,
            enable => '1',
            s1     => SEL_FCT_reg
        );

    buffer_cmd_route : buffer_ual
        generic map (N => 4)
        port map (
            e1     => SEL_ROUTE_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ ,
            enable => '1',
            s1     => SEL_ROUTE_reg
        );

    buffer_cmd_out : buffer_ual
        generic map (N => 2)
        port map (
            e1     => SEL_OUT_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ ,
            enable => '1',
            s1     => SEL_OUT_reg
        );

    -- ==========================================================================
    -- Buffers pour les retenues (SR_IN_L / SR_IN_R)
    -- ==========================================================================
    buffer_sr_in_l : buffer_ual
        generic map (N => 1)
        port map (
            e1     => SR_OUT_L_vec,
            reset  => reset_sim,
            clock  => CLK100MHZ ,
            enable => '1',
            s1     => SR_IN_L_vec
        );

    buffer_sr_in_r : buffer_ual
        generic map (N => 1)
        port map (
            e1     => SR_OUT_R_vec,
            reset  => reset_sim,
            clock  => CLK100MHZ ,
            enable => '1',
            s1     => SR_IN_R_vec
        );

    -- ==========================================================================
    -- UAL
    -- ==========================================================================
    alu_inst : hearth_ual
        port map (
            A        => bufferA_out,
            B        => bufferB_out,
            SR_IN_L  => SR_IN_L_vec(0),
            SR_IN_R  => SR_IN_R_vec(0),
            SEL_FCT  => SEL_FCT_reg,
            SR_OUT_L => SR_OUT_L_sim,
            SR_OUT_R => SR_OUT_R_sim,
            S        => S_sim
        );

    -- ==========================================================================
    -- Mémoire d'instructions
    -- ==========================================================================
    mem_inst : mem_instructions
        port map (
            clk        => CLK100MHZ ,
            reset      => reset_sim,
            instruction=> addr_sim, -- CORRIGÉ : plus de conversion vers unsigned
            donnee     => instr_sim
        );

    -- ==========================================================================
    -- Interconnexion
    -- ==========================================================================

    reset_sim <= btn(0);
    

    interco_inst : interconnexion
        port map (
            SEL_ROUTE              => SEL_ROUTE_reg,
            A_IN                   => sw,
            B_IN                   => sw,
            S                      => S_sim,
            MEM_CACHE_1_in         => MEM_CACHE_1_out_sim,
            MEM_CACHE_1_out_enable => MEM_CACHE_1_enable_sim,
            MEM_CACHE_1_out        => MEM_CACHE_1_in_sim,
            MEM_CACHE_2_in         => MEM_CACHE_2_out_sim,
            MEM_CACHE_2_out_enable => MEM_CACHE_2_enable_sim,
            MEM_CACHE_2_out        => MEM_CACHE_2_in_sim,
            Buffer_A               => Buffer_A_sim,
            Buffer_A_enable        => Buffer_A_enable_sim,
            Buffer_B               => Buffer_B_sim,
            Buffer_B_enable        => Buffer_B_enable_sim,
            SEL_OUT                => SEL_OUT_reg,
            RES_OUT                => RES_OUT_sim,
            ready   => ready_sim
        );

    process(instr_sim)
    begin
            SEL_FCT_sim   <= instr_sim(9 downto 6);
            SEL_ROUTE_sim <= instr_sim(5 downto 2);
            SEL_OUT_sim   <= instr_sim(1 downto 0);
    end process;

    process(CLK100MHZ, reset_sim)
    begin
        if reset_sim = '1' then
            RES_OUT_reg      <= (others => '0');
            ready_reg        <= '0';
            btn_prev         <= (others => '0');
            ready_prev       <= '0';
            calcul_en_cours  <= '0';
        elsif rising_edge(CLK100MHZ) then
            -- Détection du front montant sur un bouton (nouveau calcul)
            if ((btn(1) = '1' and btn_prev(1) = '0') or
                (btn(2) = '1' and btn_prev(2) = '0') or
                (btn(3) = '1' and btn_prev(3) = '0')) then
                ready_reg        <= '0'; -- Nouveau calcul en cours, on remet ready à zéro
                calcul_en_cours  <= '1'; -- On autorise la capture du prochain résultat
            end if;

            -- Capture du résultat UNIQUEMENT sur front montant de ready_sim ET si un calcul était en cours
            if (ready_sim = '1' and ready_prev = '0' and calcul_en_cours = '1') then
                RES_OUT_reg      <= RES_OUT_sim;
                ready_reg        <= '1';
                calcul_en_cours  <= '0'; -- On bloque la capture jusqu'à un nouveau calcul
            end if;

            btn_prev   <= btn;        -- mémorise l'état courant pour le prochain cycle
            ready_prev <= ready_sim;  -- mémorise l'état courant de ready_sim
        end if;
    end process;

    SR_OUT_L_vec(0) <= SR_OUT_L_sim;
    SR_OUT_R_vec(0) <= SR_OUT_R_sim;

    -- Gestion des 3 algorithmes
    MyAlgoProc : process (btn(3 downto 0),CLK100MHZ)
    begin
        if (btn(0)= '1') then
            MyCounter <= (others => '0');
            led0_r <= '0';
            FSM_Main <= IDLE;
        elsif rising_edge(CLK100MHZ) then
            case FSM_Main is 
                when IDLE =>
                        if (btn(1) = '1') then
                            MyCounter <= (others => '0');
                            FSM_Main <= FUNCT_1; 
                            led0_r <= '0';
                    
                        elsif (btn(2) = '1') then
                            MyCounter <= "0000011";
                            FSM_Main <= FUNCT_2; 
                            led0_r <= '0';
                        elsif(btn(3) = '1') then
                            MyCounter <= "0001010";--0001010
                            FSM_Main <= FUNCT_3; 
                            led0_r <= '0';
                    
                        else
                            MyCounter <= (others => '0');
                            FSM_Main <= IDLE; 
                            led0_r <= '0';
                        end if;
                when FUNCT_1 =>
                    if(btn(1) = '1') then
                        FSM_Main <= FUNCT_1;
                        if ready_sim = '1' then 
                            MyCounter <= MyCounter;
                            led0_r <= '1';
                        else
                            addr_sim <= MyCounter;
                            MyCounter <= slv_inc(MyCounter);
                            led0_r <= '0';
                        end if;
                    else
                        MyCounter <= (others => '0');
                        led0_r <= '0';
                        FSM_Main <= IDLE; 
                    end if;
                when FUNCT_2 =>
                    if (btn(2) = '1') then
                        FSM_Main <= FUNCT_2;
                        if ready_sim = '1' then 
                            MyCounter <= MyCounter;
                            led0_r <= '1';
                        else
                            addr_sim <= MyCounter;
                            MyCounter <= slv_inc(MyCounter);
                            led0_r <= '0';
                        end if;
                    else
                        MyCounter <= (others => '0');
                        led0_r <= '0';
                        FSM_Main <= IDLE; 
                    end if;
                when FUNCT_3 =>
                    if (btn(3) = '1') then
                        FSM_Main <= FUNCT_3;
                        if ready_sim = '1' then 
                            MyCounter <= MyCounter;
                            led0_r <= '1';
                        else
                            addr_sim <= MyCounter;
                            MyCounter <= slv_inc(MyCounter);
                            led0_r <= '0';
                        end if;
                    else
                        MyCounter <= (others => '0');
                        led0_r <= '0';
                        FSM_Main <= IDLE; 
                    end if;
                when others =>
                    FSM_Main <= IDLE;
                end case;
        end if;
   
    end process MyAlgoProc;

     -- Affichage du résultat sur les LED vertes
    led0_g <= RES_OUT_reg(0);
    led1_g <= RES_OUT_reg(1);
    led2_g <= RES_OUT_reg(2);
    led3_g <= RES_OUT_reg(3);

    led <= RES_OUT_reg(7 downto 4);

end top_level_arch;

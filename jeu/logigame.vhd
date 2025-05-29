library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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

    -- Signaux internes
    signal reset_sim : std_logic;
    signal addr_sim : std_logic_vector(6 downto 0) := (others => '0');
    signal instr_sim : std_logic_vector(9 downto 0);

    signal RES_OUT_sim : std_logic_vector(7 downto 0);

    -- Buffers 8 bits
    signal MEM_CACHE_1_in_sim, MEM_CACHE_2_in_sim : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_1_out_sim, MEM_CACHE_2_out_sim : std_logic_vector(7 downto 0);
    signal MEM_CACHE_1_enable_sim, MEM_CACHE_2_enable_sim : std_logic := '0';

    -- Buffers 4 bits
    signal Buffer_A_sim, Buffer_B_sim : std_logic_vector(3 downto 0);
    signal Buffer_A_enable_sim, Buffer_B_enable_sim : std_logic := '0';
    signal bufferA_out, bufferB_out : std_logic_vector(3 downto 0);

    -- Retenues
    signal SR_IN_L_vec, SR_IN_R_vec : std_logic_vector(0 downto 0);
    signal SR_OUT_L_vec, SR_OUT_R_vec : std_logic_vector(0 downto 0);
    signal SR_OUT_L_sim, SR_OUT_R_sim : std_logic;

    -- Commandes
    signal SEL_FCT_sim   : std_logic_vector(3 downto 0);
    signal SEL_ROUTE_sim : std_logic_vector(3 downto 0);
    signal SEL_OUT_sim   : std_logic_vector(1 downto 0);

    signal SEL_FCT_reg   : std_logic_vector(3 downto 0);
    signal SEL_ROUTE_reg : std_logic_vector(3 downto 0);
    signal SEL_OUT_reg   : std_logic_vector(1 downto 0);

    -- UAL
    signal S_sim : std_logic_vector(7 downto 0);

    -- Interconnexion
    signal ready_sim : std_logic;

    -- Résultat affiché
    signal RES_OUT_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal ready_reg   : std_logic := '0';
    signal btn_prev : std_logic_vector(3 downto 0) := (others => '0');
    signal ready_prev : std_logic := '0';
    signal calcul_en_cours : std_logic := '0';

    -- Signaux pour la FSM
    signal led_color_sig : std_logic_vector(2 downto 0);
    signal score_sig     : std_logic_vector(3 downto 0);
    signal game_over_sig : std_logic;

    -- Déclaration du composant FSM
    component fsm
        port (
            clk        : in std_logic;
            reset      : in std_logic;
            start      : in std_logic;
            sw_level   : in std_logic_vector(1 downto 0);
            btn_r      : in std_logic;
            btn_g      : in std_logic;
            btn_b      : in std_logic;
            led_color  : out std_logic_vector(2 downto 0);
            score      : out std_logic_vector(3 downto 0);
            game_over  : out std_logic
        );
    end component;

begin

    -- Reset global
    reset_sim <= btn(0);

    -- ==========================================================================
    -- Buffers de données
    -- ==========================================================================
    buffer_A_inst : buffer_ual
        generic map (N => 4)
        port map (
            e1 => Buffer_A_sim,
            reset => reset_sim,
            clock => CLK100MHZ,
            enable => Buffer_A_enable_sim,
            s1 => bufferA_out
        );

    buffer_B_inst : buffer_ual
        generic map (N => 4)
        port map (
            e1 => Buffer_B_sim,
            reset => reset_sim,
            clock => CLK100MHZ,
            enable => Buffer_B_enable_sim,
            s1 => bufferB_out
        );

    mem_cache_1_inst : buffer_ual
        generic map (N => 8)
        port map (
            e1     => MEM_CACHE_1_in_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ,
            enable => MEM_CACHE_1_enable_sim,
            s1     => MEM_CACHE_1_out_sim
        );

    mem_cache_2_inst : buffer_ual
        generic map (N => 8)
        port map (
            e1     => MEM_CACHE_2_in_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ,
            enable => MEM_CACHE_2_enable_sim,
            s1     => MEM_CACHE_2_out_sim
        );

    -- ==========================================================================
    -- Buffers de commande
    -- ==========================================================================
    buffer_cmd_fct : buffer_ual
        generic map (N => 4)
        port map (
            e1     => SEL_FCT_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ,
            enable => '1',
            s1     => SEL_FCT_reg
        );

    buffer_cmd_route : buffer_ual
        generic map (N => 4)
        port map (
            e1     => SEL_ROUTE_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ,
            enable => '1',
            s1     => SEL_ROUTE_reg
        );

    buffer_cmd_out : buffer_ual
        generic map (N => 2)
        port map (
            e1     => SEL_OUT_sim,
            reset  => reset_sim,
            clock  => CLK100MHZ,
            enable => '1',
            s1     => SEL_OUT_reg
        );

    -- ==========================================================================
    -- Buffers pour les retenues
    -- ==========================================================================
    buffer_sr_in_l : buffer_ual
        generic map (N => 1)
        port map (
            e1     => SR_OUT_L_vec,
            reset  => reset_sim,
            clock  => CLK100MHZ,
            enable => '1',
            s1     => SR_IN_L_vec
        );

    buffer_sr_in_r : buffer_ual
        generic map (N => 1)
        port map (
            e1     => SR_OUT_R_vec,
            reset  => reset_sim,
            clock  => CLK100MHZ,
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
            clk        => CLK100MHZ,
            reset      => reset_sim,
            instruction=> addr_sim,
            donnee     => instr_sim
        );

    -- ==========================================================================
    -- Interconnexion
    -- ==========================================================================
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
            ready                  => ready_sim
        );

    -- ==========================================================================
    -- Décodage de l'instruction
    -- ==========================================================================
    process(instr_sim)
    begin
        SEL_FCT_sim   <= instr_sim(9 downto 6);
        SEL_ROUTE_sim <= instr_sim(5 downto 2);
        SEL_OUT_sim   <= instr_sim(1 downto 0);
    end process;

    -- ==========================================================================
    -- Gestion du résultat et du ready
    -- ==========================================================================
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
                ready_reg        <= '0';
                calcul_en_cours  <= '1';
            end if;

            -- Capture du résultat sur front montant de ready_sim
            if (ready_sim = '1' and ready_prev = '0' and calcul_en_cours = '1') then
                RES_OUT_reg      <= RES_OUT_sim;
                ready_reg        <= '1';
                calcul_en_cours  <= '0';
            end if;

            btn_prev   <= btn;
            ready_prev <= ready_sim;
        end if;
    end process;

    -- Routage des retenues
    SR_OUT_L_vec(0) <= SR_OUT_L_sim;
    SR_OUT_R_vec(0) <= SR_OUT_R_sim;

    -- ==========================================================================
    -- Instanciation de la FSM principale du jeu
    -- ==========================================================================
    fsm_inst : fsm
        port map (
            clk        => CLK100MHZ,
            reset      => reset_sim,
            start      => btn(0),                      -- bouton start
            sw_level   => sw(3 downto 2),              -- niveau de difficulté (2 bits)
            btn_r      => btn(1),                      -- bouton rouge
            btn_g      => btn(2),                      -- bouton vert
            btn_b      => btn(3),                      -- bouton bleu
            led_color  => led_color_sig,               -- couleur stimulus (vers LED RVB)
            score      => score_sig,                   -- score courant
            game_over  => game_over_sig                -- signal de fin de partie
        );

    -- ==========================================================================
    -- Routage des sorties FSM vers les LEDs physiques
    -- ==========================================================================
    -- Exemple : affichage de la couleur sur LD3 (à adapter selon ton câblage)
    led3_r <= led_color_sig(2);
    led3_g <= led_color_sig(1);
    led3_b <= led_color_sig(0);

    -- Affichage du score sur les 4 premières LEDs
    led <= score_sig;

    -- Affichage du game_over (exemple : allumer toutes les LEDs si game_over)
    -- if game_over_sig = '1' then
    --     led <= (others => '1');
    -- end if;

    -- ==========================================================================
    -- Affichage du résultat sur les LEDs
    -- ==========================================================================
    led0_r <= RES_OUT_reg(7);
    led1_r <= RES_OUT_reg(6);
    led2_r <= RES_OUT_reg(5);
    led3_r <= RES_OUT_reg(4);

    led0_b <= RES_OUT_reg(3);
    led1_b <= RES_OUT_reg(2);
    led2_b <= RES_OUT_reg(1);
    led3_b <= RES_OUT_reg(0);

    led <= RES_OUT_reg(7 downto 4);

end top_level_arch;

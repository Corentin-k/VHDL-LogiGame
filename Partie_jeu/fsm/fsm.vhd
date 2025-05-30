library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
    port (
        clk        : in  std_logic;                      -- horloge système (100 MHz)
        reset      : in  std_logic;                      -- remise à zéro globale
        start      : in  std_logic;                      -- bouton de démarrage
        sw_level   : in  std_logic_vector(1 downto 0);   -- niveau de difficulté
        btn_r      : in  std_logic;                      -- bouton rouge
        btn_g      : in  std_logic;                      -- bouton vert
        btn_b      : in  std_logic;                      -- bouton bleu
        led_color  : out std_logic_vector(2 downto 0);   -- couleur affichée sur LD3
        score      : out std_logic_vector(3 downto 0);   -- score courant
        game_over  : out std_logic                       -- signal de fin de partie
    );
end fsm;

architecture fsm_arch of fsm is

    -- États de l’automate
    type state_t is (IDLE, NEW_ROUND, WAIT_RESPONSE, END_GAME);
    signal state, next_state : state_t := IDLE;

    -- Signaux de contrôle
    signal lfsr_enable_reg : std_logic := '0';
    signal minuteur_start  : std_logic := '0';

    -- Signaux inter-modules
    signal lfsr_out        : std_logic_vector(3 downto 0) := "1011";
    signal timeout_sig     : std_logic;
    signal valid_hit_sig   : std_logic;
    signal score_sig       : std_logic_vector(3 downto 0);
    signal internal_go     : std_logic;

    -- Couleur issue du LFSR
    signal led_color_sig   : std_logic_vector(2 downto 0) := "100"; -- rouge par défaut

    
    signal new_round_done  : std_logic := '0';

    -- Composants externes
    component lfsr is
        port(
            CLK100MHZ : in  std_logic;
            reset     : in  std_logic;
            enable    : in  std_logic;
            rnd       : out std_logic_vector(3 downto 0)
        );
    end component;

    component minuteur is
        port(
            clk      : in  std_logic;
            reset    : in  std_logic;
            start    : in  std_logic;
            sw_level : in  std_logic_vector(1 downto 0);
            time_out : out std_logic
        );
    end component;

    component score_compteur is
        port(
            clk       : in  std_logic;
            reset     : in  std_logic;
            valid_hit : in  std_logic;
            score     : out std_logic_vector(3 downto 0);
            game_over : out std_logic
        );
    end component;

    component verif_resultat is
        port(
            clk       : in  std_logic;
            reset     : in  std_logic;
            timeout   : in  std_logic;
            led_color : in  std_logic_vector(2 downto 0);
            btn_r     : in  std_logic;
            btn_g     : in  std_logic;
            btn_b     : in  std_logic;
            valid_hit : out std_logic
        );
    end component;

begin

    -- Instanciation des composants
    lfsr_inst : lfsr
        port map (
            CLK100MHZ => clk,
            reset     => reset,
            enable    => lfsr_enable_reg,
            rnd       => lfsr_out
        );

    minuteur_inst : minuteur
        port map (
            clk      => clk,
            reset    => reset,
            start    => minuteur_start,
            sw_level => sw_level,
            time_out => timeout_sig
        );

    score_compteur_inst : score_compteur
        port map (
            clk       => clk,
            reset     => reset,
            valid_hit => valid_hit_sig,
            score     => score_sig,
            game_over => internal_go
        );

    verif_resultat_inst : verif_resultat
        port map (
            clk       => clk,
            reset     => reset,
            timeout   => timeout_sig,
            led_color => led_color_sig,
            btn_r     => btn_r,
            btn_g     => btn_g,
            btn_b     => btn_b,
            valid_hit => valid_hit_sig
        );

    -- Décodage couleur à partir du LFSR
    process(clk, reset)
    begin
        if reset = '1' then
            led_color_sig <= "000";
        elsif rising_edge(clk) then
            case lfsr_out(1 downto 0) is
                when "00" => led_color_sig <= "100";
                when "01" => led_color_sig <= "010";
                when "10" => led_color_sig <= "001";
                when "11" => led_color_sig <= "001";
                when others => null; 
            end case;
        end if;
    end process;



    -- FSM synchrone
    process(clk, reset)
    begin
        if reset = '1' then
            state           <= IDLE;
            lfsr_enable_reg <= '0';
            minuteur_start  <= '0';
            new_round_done  <= '0';
        elsif rising_edge(clk) then
            state <= next_state;

            -- Activation unique du LFSR et timer à chaque NEW_ROUND
            if state = NEW_ROUND and new_round_done = '0' then
                lfsr_enable_reg <= '1';
                minuteur_start  <= '1';
                new_round_done  <= '1';
            else
                lfsr_enable_reg <= '0';
                minuteur_start  <= '0';
            end if;

            if state = WAIT_RESPONSE then
                new_round_done <= '0';
            end if;
        end if;
    end process;


    process(state, start, valid_hit_sig, timeout_sig, internal_go)
    begin
        next_state <= state;
        case state is
            when IDLE =>
                if start = '1' then
                    next_state <= NEW_ROUND;
                end if;
            when NEW_ROUND =>
                next_state <= WAIT_RESPONSE;
            when WAIT_RESPONSE =>
                if valid_hit_sig = '1' then
                    next_state <= NEW_ROUND;
                elsif timeout_sig = '1' or internal_go = '1' then
                    next_state <= END_GAME;
                end if;
            when END_GAME =>
                next_state <= END_GAME;
        end case;
    end process;


    -- Sorties
   
    led_color <= led_color_sig;
    score     <= score_sig;
    game_over <= '1' when state = END_GAME else '0';

end architecture fsm_arch;

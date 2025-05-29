library ieee;
use ieee.std_logic_1164.all;
-- Réaliser un contrôleur de jeu VHDL pilotant la logique globale de LogiGame :
-- Génération pseudo-aléatoire du stimulus
-- Lancement du timer en fonction du niveau de difficulté
-- Vérification de la réponse du joueur
-- Incrément du score ou fin de partie
entity fsm is
    port (
        clk        : in  std_logic; -- horloge système (100 MHz)
        reset      : in  std_logic; -- remise à zéro globale
        start      : in  std_logic; -- bouton de démarrage
        sw_level   : in  std_logic_vector(1 downto 0); -- niveau de difficulté
        btn_r      : in  std_logic; -- bouton rouge
        btn_g      : in  std_logic; -- bouton vert
        btn_b      : in  std_logic; -- bouton bleu
        led_color  : out std_logic_vector(2 downto 0); -- couleur affichée sur LD3
        score      : out std_logic_vector(3 downto 0); -- score courant
        game_over  : out std_logic -- signal de fin de partie
    );
end fsm;

architecture fsm_arch of fsm is

    -- Déclaration des états
    type state_t is (IDLE, NEW_ROUND, WAIT_RESPONSE, END_GAME);
    --   IDLE : attente du signal start
    --   NEW_ROUND : génère un nouveau stimulus et démarre le timer
    --   WAIT_RESPONSE : attend une réponse correcte ou un timeout
    --   END_GAME : verrouille le jeu en cas de défaite ou score maximal

    signal state, next_state : state_t := IDLE;

 
    signal lfsr_enable      : std_logic := '0'; -- signal d'activation du LFSR
    signal lfsr_enable_reg : std_logic := '0';
    signal minuteur_start   : std_logic := '0'; -- signal de démarrage du minuteur
    signal valid_hit_sig    : std_logic; -- signal de validation de la réponse
    signal timeout_sig      : std_logic; -- signal de timeout
    signal game_over_sig    : std_logic; -- signal de fin de jeu
    signal led_color_sig    : std_logic_vector(2 downto 0); -- couleur du stimulus (3 bits)
    signal score_sig        : std_logic_vector(3 downto 0); -- score du joueur (4 bits)
    signal lfsr_out         : std_logic_vector(3 downto 0); -- sortie du LFSR
    signal bad_response      : std_logic;

    -- Déclaration des composants
    component lfsr is
            port(
            CLK100MHZ : in std_logic;  -- horloge principale (100 MHz)
            reset : in std_logic;  -- réinitialisation du registre à une valeur initiale non nulle «1011»
            enable : in std_logic;  -- active l’évolution du LFSR à chaque front montant
            rnd : out std_logic_vector(3 downto 0)  -- vecteur de 4 bits représentant la valeur pseudo-aléatoire courante
        );
    end component;

    component minuteur is
        port (
        clk      : in std_logic;
        reset    : in std_logic;
        start    : in std_logic;
        sw_level : in std_logic_vector(1 downto 0);
        time_out : out std_logic
    );
    end component;

    component score_compteur is
         port (
        clk       : in  std_logic; -- horloge système
        reset     : in  std_logic; --remise à zéro du score
        valid_hit : in  std_logic; -- indiquant la réussite (1) ou l’échec (0)
        score     : out std_logic_vector(3 downto 0); -- score courant codé sur 4 bits
        game_over : out std_logic -- signal indiquant la fin du jeu
    );
    end component;

    component verif_resultat is
        port (
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

    lfsr_inst : lfsr
    port map (
        CLK100MHZ    => clk,
        reset  => reset,
        enable => lfsr_enable_reg,
        rnd    => lfsr_out
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
            game_over => game_over_sig
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

   
    -- FSM principal
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            lfsr_enable_reg <= '0';
        elsif rising_edge(clk) then
            state <= next_state;
            -- Active lfsr_enable_reg pendant un cycle à chaque NEW_ROUND
            if next_state = NEW_ROUND then
                lfsr_enable_reg <= '1';
            else
                lfsr_enable_reg <= '0';
            end if;
        end if;
    end process;

    process(state, start, valid_hit_sig, timeout_sig, game_over_sig)
    begin
        -- Valeurs par défaut
        lfsr_enable    <= '0';
        minuteur_start <= '0';

        case state is
            when IDLE =>  
                if start = '1' then
                    next_state <= NEW_ROUND;
                else
                    next_state <= IDLE;
                end if;

            when NEW_ROUND =>  
                lfsr_enable    <= '1';
                minuteur_start <= '1';
                next_state     <= WAIT_RESPONSE;

           when WAIT_RESPONSE =>
                if valid_hit_sig = '1' then
                    if game_over_sig = '1' then
                        next_state <= END_GAME;
                    else
                        next_state <= NEW_ROUND;
                    end if;
                elsif timeout_sig = '1' or bad_response = '1' then
                    next_state <= END_GAME;
                else
                    next_state <= WAIT_RESPONSE;
                end if;

            when END_GAME =>
                next_state <= END_GAME;
        end case;
    end process;

    -- Ajoute ce process dans l'architecture fsm_arch
process(lfsr_out)
begin
    case lfsr_out(1 downto 0) is
        when "00" => led_color_sig <= "100"; -- rouge
        when "01" => led_color_sig <= "010"; -- vert
        when others => led_color_sig <= "001"; -- bleu
    end case;
end process;
   
    
    score     <= score_sig;
    game_over <= '1' when state = END_GAME else game_over_sig;
    led_color <= led_color_sig;


end fsm_arch;
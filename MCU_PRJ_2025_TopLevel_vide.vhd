library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MCU_PRJ_2021_TopLevel is
    Port (
        CLK100MHZ : in STD_LOGIC;
        sw : in STD_LOGIC_VECTOR(3 downto 0); --sélection du niveau de difficulté
        btn : in STD_LOGIC_VECTOR(3 downto 0); -- boutons de contrôle et réponse (start, rouge, vert, bleu)


        led : out STD_LOGIC_VECTOR(3 downto 0); --sortie score (4 bits)

        --LED RVB pour affichage du stimulus
        led0_r : out STD_LOGIC; led0_g : out STD_LOGIC; led0_b : out STD_LOGIC;                
        led1_r : out STD_LOGIC; led1_g : out STD_LOGIC; led1_b : out STD_LOGIC;
        led2_r : out STD_LOGIC; led2_g : out STD_LOGIC; led2_b : out STD_LOGIC;                
        led3_r : out STD_LOGIC; led3_g : out STD_LOGIC; led3_b : out STD_LOGIC
    );
end MCU_PRJ_2021_TopLevel;

architecture MCU_PRJ_2021_TopLevel_Arch of MCU_PRJ_2021_TopLevel is


    -- Instanciation du contrôleur principal (FSM)
    component fsm
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            start      : in  std_logic;
            sw_level   : in  std_logic_vector(1 downto 0);
            btn_r      : in  std_logic;
            btn_g      : in  std_logic;
            btn_b      : in  std_logic;
            led_color  : out std_logic_vector(2 downto 0);
            score      : out std_logic_vector(3 downto 0);
            game_over  : out std_logic
        );
    end component;

    -- Importation de tous les composants: Heart_UAL, interconnexion, bufferCMD et bufferUAL
    component Hearth_UAL
      port (
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
      port (
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

    component bufferCMD is

        port (
            e1 : in std_logic_vector (3 downto 0);
            reset : in std_logic;
            clock : in std_logic;
            SEL_FCT : out std_logic_vector (3 downto 0);
            SEL_ROUTE : out std_logic_vector (3 downto 0);
        );
    end  component;

    component bufferUAL is
        port (
            e1 : in std_logic_vector (7 downto 0);
            reset : in std_logic;
        
            clock : in std_logic;

            
            MEM_CACHE_1_out_enable : in std_logic;
            MEM_CACHE_1_out        : out std_logic_vector(7 downto 0);
            
            MEM_CACHE_2_out_enable : in std_logic;
            MEM_CACHE_2_out        : out std_logic_vector(7 downto 0);

            Buffer_A               : out std_logic_vector(3 downto 0);
            Buffer_A_enable        : in std_logic;

            Buffer_B               : out std_logic_vector(3 downto 0);
            Buffer_B_enable        : in std_logic;
        );
    end  component;
    
    -- Signaux d'interconnexion
    signal A_sim, B_sim      : std_logic_vector(3 downto 0) := (others => '0');
    signal SR_IN_L_sim     : std_logic := '0';
    signal SR_IN_R_sim     : std_logic := '0';
    signal SEL_sim         : std_logic_vector(3 downto 0) := (others => '0');
    signal SR_OUT_L_sim    : std_logic;
    signal SR_OUT_R_sim    : std_logic;
    signal S_sim           : std_logic_vector(7 downto 0);
    signal SEL_ROUTE_sim   : std_logic_vector(3 downto 0) := (others => '0');
    signal MEM_CACHE_1_in_sim         : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_1_out_enable_sim : std_logic;
    signal MEM_CACHE_1_out_sim        : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_2_in_sim         : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_2_out_enable_sim : std_logic;
    signal MEM_CACHE_2_out_sim        : std_logic_vector(7 downto 0) := (others => '0');
    signal Buffer_A_sim               : std_logic_vector(3 downto 0) := (others => '0');
    signal Buffer_A_enable_sim        : std_logic;
    signal Buffer_B_sim               : std_logic_vector(3 downto 0) := (others => '0');
    signal Buffer_B_enable_sim        : std_logic;
    signal RES_OUT_sim                : std_logic_vector(7 downto 0) := (others => '0');

    
    type state_t is (s_Idle, s_Funct_1, s_Funct_2, s_Funct_3);
    signal FSM_Main : state_t := s_Idle; -- Etat de départ

    signal MyCounter1 : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');

begin
    -- Port mapping des composants
    Hearth_UAL_test: Hearth_UAL
        port map (
            A        => A_sim,
            B        => B_sim,
            SR_IN_L  => SR_IN_L_sim,
            SR_IN_R  => SR_IN_R_sim,
            SEL_FCT  => SEL_sim,
            SR_OUT_L => SR_OUT_L_sim,
            SR_OUT_R => SR_OUT_R_sim,
            S        => S_sim
        );
    interconnexion_test: interconnexion
        port map (
            SEL_ROUTE              => SEL_ROUTE_sim,
            A_IN                   => A_sim,
            B_IN                   => B_sim,
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
            SEL_OUT                => (others => '0'),
            RES_OUT                => RES_OUT_sim
        );
    bufferCMD_test: bufferCMD
        port map (
            e1 => btn(3 downto 0),
            reset => btn(0),
            clock => CLK100MHZ,
            SEL_FCT => SEL_sim,
            SEL_ROUTE => SEL_ROUTE_sim
        );
    bufferUAL_test: bufferUAL
        port map (
            e1 => S_sim,
            reset => btn(0),
            clock => CLK100MHZ,
            MEM_CACHE_1_out_enable => MEM_CACHE_1_out_enable_sim,
            MEM_CACHE_1_out        => MEM_CACHE_1_out_sim,
            MEM_CACHE_2_out_enable => MEM_CACHE_2_out_enable_sim,
            MEM_CACHE_2_out        => MEM_CACHE_2_out_sim,
            Buffer_A               => Buffer_A_sim,
            Buffer_A_enable        => Buffer_A_enable_sim,
            Buffer_B               => Buffer_B_sim,
            Buffer_B_enable        => Buffer_B_enable_sim
        );
    -- Gestion des L

    -- Gestion des 3 algorithmes
    MyAlgoProc : process (btn(3 downto 0),CLK100MHZ)
    begin
    if (btn(0)= '1') then
        MyCounter1 <= (others => '0');
        led0_q <= '0';
        FSM_Main <= s_Idle;
    elsif rising_edge(CLK100MHZ) then
    case FSM_Main is 
       when s_Idle =>
            if(btn(3) = '1') then
                MyCounter1 <= "1000000";FSM_Main <= s_Funct_3; led0_g <= '0';
            elsif (btn(2) = '1') then
                MyCounter1 <= "0100000";FSM_Main <= s_Funct_2; led0_g <= '0';
            elsif (btn(1) = '1') then
                MyCounter1 <= (others => '0');FSM_Main <= s_Funct_1; led0_g <= '0';
            else
                MyCounter1 <= (others => '0');FSM_Main <= s_Idle; led0_g <= '0';
            end if;
         when s_Funct_1 =>
                if(btn(1) = '1') then
                    FSM_Main <= s_Funct_1;
                    if MyCounter1= 3 then 
                        MyCounter1 <= MyCounter1;
                        led0_g <= '1';
                    else
                        MyCounter1 <= MyCounter1 + 1;
                        led0_g <= '0';
                    end if;
                else
                    MyCounter1 <= (others => '0');led0_g <= '0';
                    FSM_Main <= s_Idle; 
                end if;
            when s_Funct_2 =>
                if (btn(2) = '1') then
                    FSM_Main <= s_Funct_2;
                    if MyCounter1=37 then 
                        MyCounter1 <= MyCounter1;
                        led0_g <= '1';
                    else
                        MyCounter1 <= MyCounter1 + 1;
                        led0_g <= '0';
                    end if;
                else
                    MyCounter1 <= (others => '0');led0_g <= '0';
                    FSM_Main <= s_Idle; 
                end if;
            when s_Funct_3 =>
                if (btn(3) = '1') then
                    FSM_Main <= s_Funct_3;
                    if MyCounter1= 73 then 
                        MyCounter1 <= MyCounter1;
                        led0_g <= '1';
                    else
                        MyCounter1 <= MyCounter1 + 1;
                        led0_g <= '0';
                    end if;
                else
                    MyCounter1 <= (others => '0');led0_g <= '0';
                    FSM_Main <= s_Idle; 
                end if;
            when others =>
                FSM_Main <= s_Idle;
        end case;
    end if;
end process MyAlgoProc;


                    

end MCU_PRJ_2021_TopLevel_Arch;

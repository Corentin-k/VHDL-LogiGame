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


                    

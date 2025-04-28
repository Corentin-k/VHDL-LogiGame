
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sel_route_entity is
    port(
        -- SEL_ROUTE permet de définir le transfert de données qui sera effectué lors du prochain cycle horloge (prochain front montant de l’horloge).
        SEL_ROUTE : in std_logic_vector(3 downto 0); -- Sélecteur de route
        
        A_IN      : in std_logic_vector(3 downto 0); -- Entrée A
        B_IN      : in std_logic_vector(3 downto 0); -- Entrée B
        S         : in std_logic_vector(7 downto 0); -- Entrée S
        
        -- La mémoire MEM_SEL_FCT permet de mémoriser la fonction arithmétique ou logique à réaliser.
        -- Elle est systématiquement chargée à chaque front montant d’horloge.
        MEM_CACHE_1 : in std_logic_vector(7 downto 0); -- Mémoire cache 1
        MEM_CACHE_2 : in std_logic_vector(7 downto 0); -- Mémoire cache 2
        
        -- Les mémoires Buffer_A, Buffer_B permettent de stocker les données directement liées au cœur de l’UAL, c'est-à-dire à la sous-fonction arithmétique et logique. 
        -- Elles seront chargées (activées sur front montant de l’entrée clk) suivant les valeurs de l’entrée SEL_ROUTE
        Buffer_A  : out std_logic_vector(3 downto 0); -- Sortie vers Buffer A
        Buffer_A_enable : out std_logic; -- Signal d'activation pour Buffer A
        
        Buffer_B  : out std_logic_vector(3 downto 0); -- Sortie vers Buffer B
        Buffer_B_enable : out std_logic; -- Signal d'activation pour Buffer B

        SEL_OUT : in std_logic_vector(1 downto 0); -- Sélecteur de sortie
        RES_OUT : out std_logic_vector(7 downto 0); -- Sortie 


    );
end sel_route_entity;




architecture sel_route_arch of sel_route_entity is
begin

    selRouteProcess : process(SEL_ROUTE, A_IN, B_IN, S, MEM_CACHE_1, MEM_CACHE_2) 
    begin


        case SEL_ROUTE is

            when "0000" =>  -- Stockage de l'entrée A_IN dans Buffer_A
                Buffer_A <=A_IN;
                Buffer_A_enable <= '1'; 

                Buffer_B <='0';
                Buffer_B_enable <= '0'; 

            when "0001" => -- Stockage de MEM_CACHE_1 dans Buffer_A (4 bits de poids faibles)
                Buffer_A <= MEM_CACHE_1(3 downto 0);
                Buffer_A_enable <= '1'; 

                Buffer_B <='0';
                Buffer_B_enable <= '0'; 

            when "0010" => -- Stockage de MEM_CACHE_1 dans Buffer_A (4 bits de poids forts)
                Buffer_A <= MEM_CACHE_1(7 downto 4);
                Buffer_A_enable <= '1'; 
                
                Buffer_B <='0';
                Buffer_B_enable <= '0'; 


            when "0011" => -- Stockage de MEM_CACHE_2 dans Buffer_A (4 bits de poids faibles)
                Buffer_A <= MEM_CACHE_2(3 downto 0);
                Buffer_A_enable <= '1';

                Buffer_B <='0';
                Buffer_B_enable <= '0'; 


            when "0100" => -- Stockage de MEM_CACHE_2 dans Buffer_A (4 bits de poids forts)
                Buffer_A <= MEM_CACHE_2(7 downto 4);
                Buffer_A_enable <= '1'; 

                Buffer_B <='0';
                Buffer_B_enable <= '0'; 

            when "0101" => -- Stockage de S dans Buffer_A (4 bits de poids faibles)
                Buffer_A <= S(3 downto 0);
                Buffer_A_enable <= '1'; 

                Buffer_B <='0';
                Buffer_B_enable <= '0'; 

            when "0110" => -- Stockage de S dans Buffer_A (4 bits de poids forts)
                Buffer_A <= S(7 downto 4);
                Buffer_A_enable <= '1'; 

                Buffer_B <='0';
                Buffer_B_enable <= '0'; 


            when "0111" => -- Stockage de l'entrée B_IN dans Buffer_B
                Buffer_B <=b_IN;
                Buffer_B_enable <= '1'; 
                
                Buffer_A <='0';
                Buffer_A_enable <= '0'; 


            when "1000" => -- Stockage de MEM_CACHE_1 dans Buffer_B (4 bits de poids faibles)
                Buffer_B <= MEM_CACHE_1(3 downto 0);
                Buffer_B_enable <= '1'; 

                Buffer_A <='0';
                Buffer_A_enable <= '0'; 

            when "1001" => -- Stockage de MEM_CACHE_1 dans Buffer_B (4 bits de poids forts)
                Buffer_B <= MEM_CACHE_1(7 downto 4);
                Buffer_B_enable <= '1'; 

                Buffer_A <='0';
                Buffer_A_enable <= '0'; 

            when "1010" => -- Stockage de MEM_CACHE_2 dans Buffer_B (4 bits de poids faibles)
                Buffer_B <= MEM_CACHE_2(3 downto 0);
                Buffer_B_enable <= '1'; 

                Buffer_A <='0';
                Buffer_A_enable <= '0'; 

            when "1011" => -- Stockage de MEM_CACHE_2 dans Buffer_B (4 bits de poids forts)
                Buffer_B <= MEM_CACHE_2(7 downto 4);
                Buffer_B_enable <= '1';

                Buffer_A <='0';
                Buffer_A_enable <= '0'; 

            when "1100" => -- Stockage de S dans Buffer_B (4 bits de poids faibles)
                Buffer_B <= S(3 downto 0);
                Buffer_B_enable <= '1'; 

                Buffer_A <='0';
                Buffer_A_enable <= '0'; 

            when "1101" => -- Stockage de S dans Buffer_B (4 bits de poids forts)
                Buffer_B <= S(7 downto 4);
                Buffer_B_enable <= '1'; 

                Buffer_A <='0';
                Buffer_A_enable <= '0'; 

            when "1110" => -- Stockage de S dans MEM_CACHE_1
                S=> MEM_CACHE_1(3 downto 0);

            when "1111" => -- Stockage de S dans MEM_CACHE_2
                S=> MEM_CACHE_2(3 downto 0);
            

            end case;
    end process selRouteProcess;

    selOutProcess : process(SEL_OUT, S, MEM_CACHE_1, MEM_CACHE_2)
    begin
        case SEL_OUT is
            when "00" =>  -- Aucune sortie 
                RES_OUT <= '0';
            when "01" => -- Sortie vers MEM_CACHE_1
                RES_OUT <= MEM_CACHE_1;
            when "10" => -- Sortie vers MEM_CACHE_2
                RES_OUT <= MEM_CACHE_2;
            when "11" => -- Sortie vers S
                RES_OUT <= S;
        end case;
    end process selOutProcess;
end sel_route_arch;
    

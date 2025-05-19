# Rapport VHDL : LogicGame

# Par :
  - Corentin KERVAGORET
  - Arnaud GRIVEL
  - Mathias BENOIT


# Introduction

Ce projet a pour but de réaliser un mini jeu sur un microcontroleur: ARTY A7. Le but est ainsi de réaliser un Megamin sur ce controleur utilsant les huit LEDs de la carte.
Il nous a permis de consolider nos compétences en VHDL par la conception d'un coeur de microcontroleur.

![alt text](./img/71YKkVSeLqL.webp)


# 1. Réalisation d'un ALU 


L'ALU  (Arithmetic and Logic Unit) est l'unité de calcul du microcontroleur. Il est capable de réaliser des opérations arithmétiques et logiques sur des entiers de 8 bits.
Elle est composée de plusieurs unités fonctionnelles, chacune étant responsable d'une opération spécifique. L'ALU est contrôlée par un signal de sélection qui détermine quelle opération doit être effectuée sur les entrées.

L'entité Hearth_UAL:

```vhdl
entity Hearth_UAL is
    port(
        A        : in  std_logic_vector(3 downto 0);
        B        : in  std_logic_vector(3 downto 0);
        SR_IN_L  : in  std_logic;                    -- bit de retenue d'entrée pour décalage à droite
        SR_IN_R  : in  std_logic;                    -- bit de retenue d'entrée pour décalage à gauche et addition

        SEL_FCT  : in  std_logic_vector(3 downto 0); -- SEL_FCT est le code de la fonction à réaliser

        SR_OUT_L : out std_logic;                    -- bit de retenue de sortie gauche
        SR_OUT_R : out std_logic;                    -- bit de retenue de sortie droite
        S        : out std_logic_vector(7 downto 0)   -- résultat ALU 8 bits
    );
end Hearth_UAL;
```


L'ALU est capable de réaliser les opérations suivantes :
- nop
- A
- B
- not A
- not B
- A and B
- A or B
- A xor B
- Décalage à droite de A
- Décalage à gauche de A
- Décalage à droite de B
- Décalage à gauche de B
- A+B avec retenue d'entrée
- A+B
- A-B
- A*B



On a également créé des variables internes pour :

- Étendre A et B de 4 à 8 bits (grand_A, grand_B)

- Stocker les retenues d’entrée et de sortie (carry_in_left, carry_out_right, etc.)

- Construire le résultat 8 bits (resultat)

```vhdl
 -- Variables internes
        variable grand_A         : std_logic_vector(7 downto 0);
        variable grand_B         : std_logic_vector(7 downto 0);
        variable carry_in_left   : std_logic;
        variable carry_in_right  : std_logic;
        variable carry_out_left  : std_logic;
        variable carry_out_right : std_logic;
        variable resultat        : std_logic_vector(7 downto 0);
```

Pour valider le bon fonctionnement de l’ALU, nous avons développé un [testbench](./ual/ual_testbench.vhd) VHDL complet. 
Pour ce faire nous avons utilisé des procédures en VHDL pour balayer toutes les combinaisons possibles de l'ALU : `display_case(name:string)` et `test_case(name:string)`

```vhdl
procedure display_case(name : string) is
begin
    report "Test: " & name & " | A=" & integer'image(to_integer(unsigned(A_sim))) &
            " B=" & integer'image(to_integer(unsigned(B_sim))) &
            " SR_IN_L=" & std_logic'image(SR_IN_L_sim) &
            " SR_IN_R=" & std_logic'image(SR_IN_R_sim) &
            " SEL_FCT=" & integer'image(to_integer(unsigned(SEL_sim))) &
            " S=" & integer'image(to_integer(unsigned(S_sim))) &
            " SR_OUT_L=" & std_logic'image(SR_OUT_L_sim) &
            " SR_OUT_R=" & std_logic'image(SR_OUT_R_sim);
end procedure;
```
```vhdl
procedure test_case(
    signal_name : string;
    sel_val     : std_logic_vector(3 downto 0);
    a_val, b_val : std_logic_vector(3 downto 0);
    sr_in_l, sr_in_r : std_logic;
    expected_S  : std_logic_vector(7 downto 0);
    expected_L, expected_R : std_logic := '0'
) is
begin
    SEL_sim <= sel_val;
    A_sim <= a_val;
    B_sim <= b_val;
    SR_IN_L_sim <= sr_in_l;
    SR_IN_R_sim <= sr_in_r;
    wait for 10 ns;
    display_case(signal_name);
    assert S_s = expected_S report signal_name & ": S incorrect" severity error;
    assert SR_OUT_L_s = expected_L report signal_name & ": SR_OUT_L incorrect" severity error;
    assert SR_OUT_R_s = expected_R report signal_name & ": SR_OUT_R incorrect" severity error;
end procedure;
```

# 2. Réalisation de l'interconnexion


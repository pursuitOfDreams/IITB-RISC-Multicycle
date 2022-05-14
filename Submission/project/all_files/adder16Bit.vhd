library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder16Bit is
    port(
        a,b : in std_logic_vector( 15 downto 0);
        cin : in std_logic;
        s : out std_logic_vector(15 downto 0);
		  cout: out std_logic
    );
end adder16Bit;

architecture arc of adder16Bit is 

    component adder_logic
        port(
            G1,P1 :in std_logic;
            G2,P2 :in std_logic;
            G,P :out std_logic
        );
    end component;
	 
	 signal bx: std_logic_vector( 15 downto 0);
    signal G0,P0 : std_logic_vector (15 downto 0);
    signal G1,P1 : std_logic_vector (15 downto 0);
    signal G2,P2 : std_logic_vector (15 downto 0);
    signal G3,P3 : std_logic_vector (15 downto 0);
    signal G4,P4 : std_logic_vector (15 downto 0);
    signal c : std_logic_vector ( 16 downto 0);

begin
    
    c(0) <= cin;

    -- level 0

	
	bxor : for I in 15 downto 0 generate
		bx(I) <= cin xor b(I);
	end generate bxor;
	
    level0 : for i in 15 downto 0 generate
        G0(i) <= a(i) and bx(i);
        P0(i) <= a(i) and bx(i);
    end generate level0;

    cp0 : for I in 0 to 0 generate 
        G1(I) <= G0(I);
        P1(I) <= P0(I);
    end generate cp0;


    -- level 1
    level1: for I in 15 downto 1 generate
        GP1: adder_logic port map (G1 => G0(I), P1 => P0(I), G2 => G0(I-1), P2 => P0(I-1), G => G1(I), P => P1(I));
    end generate level1;


    cp1 : for I in 0 to 1 generate 
        G2(I) <= G1(I);
        P2(I) <= P1(I);
    end generate cp1;

     -- level 2
    level2: for I in 15 downto 2 generate
        GP2: adder_logic port map (G1 => G1(I), P1 => P1(I), G2 => G1(I-2), P2 => P1(I-2), G => G2(I), P => P2(I));
    end generate level2;


    cp2 : for I in 0 to 3 generate 
        G3(I) <= G2(I);
        P3(I) <= P2(I);
    end generate cp2;

     -- level 3
    level3: for I in 15 downto 4 generate
        GP3: adder_logic port map (G1 => G2(I), P1 => P2(I), G2 => G2(I-4), P2 => P2(I-4), G => G3(I), P => P3(I));
    end generate level3;


    cp3 : for I in 0 to 7 generate 
        G4(I) <= G3(I);
        P4(I) <= P3(I);
    end generate cp3;

    -- level4
    level4: for I in 15 downto 8 generate
        GP4: adder_logic port map (G1 => G3(I), P1 => P3(I), G2 => G3(I-8), P2 => P3(I-8), G => G4(I), P => P4(I));
    end generate level4;


    --final computation
    final : for I in 15 downto 0 generate
		c(I+1) <= G4(I) or (P4(I) and cin);
		s(I) <= P0(I) xor c(I);
	end generate final;

	cout <= c(16);

end arc;
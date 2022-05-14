library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_logic is
    port
		(
			G1,P1 : in std_logic;
			G2,P2 : in std_logic;
			G,P : out std_logic
		);
end adder_logic;

architecture behave of adder_logic is 
    signal temp : std_logic;
begin
    temp <=  P1 and G2;
    G <= temp or G1;
	P <= P1 and P2;
end behave;
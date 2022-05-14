library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux2x1 is
port(
	i0: in std_logic;
	i1: in std_logic;
	sel: in std_logic;
	output: out std_logic
);
end Mux2x1;

architecture arc of Mux2x1 is
begin
	
	output <= (i0 and (not sel)) or (i1 and sel);
	
end arc;
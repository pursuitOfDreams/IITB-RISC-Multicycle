library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nand16 is
    port(
        a,b: in std_logic_vector( 15 downto 0);
        output: out std_logic_vector( 15 downto 0)
    );
end nand16;


architecture behave of nand16 is

begin
    nand1: for I in 15 downto 0 generate
        output(I) <= a(I) nand b(I);
    end generate nand1;
end behave ; -- behave
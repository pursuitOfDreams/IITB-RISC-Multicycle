library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SE6 is 
    port(
        input : in std_logic_vector(5 downto 0);
        output: out std_logic_vector( 15 downto 0)
    );
end SE6;

architecture SE6_Arc of SE6 is 

begin
    output (5 downto 0) <= input( 5 downto 0);

    u: for i in 15 downto 6 generate
        output(i) <= input(5);
    end generate u;
end SE6_Arc;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RAM is
    port(
        address, input: in std_logic_vector(15 downto 0);
        write_ena : in std_logic;
        clk : in std_logic;
        output: out std_logic_vector(15 downto 0)
    );
end RAM;

architecture behave of RAM is
    type memory is array (0 to 2**16-1) of std_logic_vector(15 downto 0);
    signal ram_array : memory := (others => "0000000000000000");

begin

    process(clk)
        begin 
            if (rising_edge(clk)) then
                if (write_ena= '1') then
                    ram_array ((to_integer(unsigned(address)))) <= input;
                end if;
                output <=  ram_array ((to_integer(unsigned(address))));
            end if;
    end process;
end behave ; -- behave
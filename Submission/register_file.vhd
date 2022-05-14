library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is 
    port(
        clk : in std_logic;
        input : in std_logic_vector( 15 downto 0);
        ra1_sel, ra2_sel : in std_logic_vector(2 downto 0);
        write_ena : in std_logic;
        write_at : in std_logic_vector( 2 downto 0);
        out1 ,out2 : out std_logic_vector( 15 downto 0)
    );
end register_file;

architecture behave of register_file is
    type reg_file is array (0 to 7) of std_logic_vector( 15 downto 0);
    signal registers : reg_file := (others => "0000000000000000");
begin

    process (clk)
    begin
       if rising_edge(clk) then
          if (write_ena = '1') then
             registers (to_integer(unsigned(write_at))) <= input;
          end if;
            out1 <= registers (to_integer(unsigned(ra1_sel)));
            out2 <= registers (to_integer(unsigned(ra2_sel)));
       end if;
     end process;
end behave ; -- behave
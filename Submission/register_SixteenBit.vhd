library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_SixteenBit is
  port(
    output        : out std_logic_vector( 15 downto 0);
    input       : in  std_logic_vector( 15 downto 0);
    write_ena : in  std_logic;
    clk         : in  std_logic
    );
end register_SixteenBit;


architecture arch of register_SixteenBit is
  signal reg1 : std_logic_vector( 15 downto 0) := (others => '0');
begin
  output <= reg1;
  regFile : process (clk) is
  begin
    if rising_edge(clk) then

      if write_ena = '1' then
        reg1 <= input; 
      end if;
    end if;
  end process;

end arch;
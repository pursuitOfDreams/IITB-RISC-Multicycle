library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port(
        alu_a, alu_b : in std_logic_vector( 15 downto 0);
        operation : in std_logic_vector( 1 downto 0);
        alu_output: out std_logic_vector( 15 downto 0);
        carry, zero: out std_logic
    );
end alu;

architecture behave of alu is

    component nand16
        port(
            a,b: in std_logic_vector( 15 downto 0);
            output: out std_logic_vector( 15 downto 0)
        );
    end component;

    component adder16Bit
        port(
            a,b : in std_logic_vector( 15 downto 0);
            cin : in std_logic;
            s : out std_logic_vector(15 downto 0);
				cout: out std_logic
        );
    end component;

    component SE6
        port(
            input : in std_logic_vector(5 downto 0);
            output: out std_logic_vector( 15 downto 0)
        );
    end component;
    
    signal temp_n, temp_a, temp_s : std_logic_vector( 15 downto 0);
	 signal c_a, c_s: std_logic;
begin
    N1: nand16 port map (alu_a,alu_b,temp_n);
    A1: adder16Bit port map (alu_a,alu_b,'0',temp_a,c_a);
    S1: adder16Bit port map (alu_a,alu_b,'1',temp_s,c_s);

    process(operation, temp_A, temp_s, temp_n)
        begin
            if (operation = "00") then
				ALU_output <= temp_a(15 downto 0);
				carry <= c_a;
				zero <= not (temp_a(0) or temp_a(1) or temp_a(2) or temp_a(3) or temp_a(4) or temp_a(5) or temp_a(6) or temp_a(7) or temp_a(8) or temp_a(9) or temp_a(10) or temp_a(11) or temp_a(12) or temp_a(13) or temp_a(14) or temp_a(15));
			else 
				if (operation = "01") then
					ALU_output <= temp_a(15 downto 0);
					carry <= '0';
					zero <= not (temp_n(0) or temp_n(1) or temp_n(2) or temp_n(3) or temp_n(4) or temp_n(5) or temp_n(6) or temp_n(7) or temp_n(8) or temp_n(9) or temp_n(10) or temp_n(11) or temp_n(12) or temp_n(13) or temp_n(14) or temp_n(15));
				else 
					ALU_output <= temp_s(15 downto 0);
					carry <= c_s;
					
					zero <= not (temp_s(0) or temp_s(1) or temp_s(2) or temp_s(3) or temp_s(4) or temp_s(5) or temp_s(6) or temp_s(7) or temp_s(8) or temp_s(9) or temp_s(10) or temp_s(11) or temp_s(12) or temp_s(13) or temp_s(14) or temp_s(15));
				
				end if;
			end if;
    end process;
end behave ; -- behave
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_path is 
    port(
        clk, rst: in std_logic; -- clock variables
        pc_in , ir_in, mem_din, t1_in, t2_in, t3_in, alu_a, alu_b, mem_add, rf_d3: out std_logic_vector( 15 downto 0);

        pc_out, ir_out, mem_do, t1_out, t2_out, t3_out, rf_d1, rf_d2, alu_out : in std_logic_vector( 15 downto 0);
	
		ir_wen, pc_wen, t1_wen, t2_wen, t3_wen, rf_wen, mem_wen, c_wen, z_wen : out std_logic; -- update controls
        c_out, z_out, alu_c, alu_z: in std_logic;
		
        rf_a1, rf_a2, rf_a3 : out std_logic_vector(2 downto 0);
        alu_oper: out std_logic_vector( 1 downto 0);
        state_out : out std_logic_vector( 4 downto 0)
    );

    -- mem_do : memory data out
    -- rf_d1 : register file data 1
    -- rf_d2 : register file data 2
end control_path;

architecture behave of control_path is

    component SE6
        port(
            input : in std_logic_vector(5 downto 0);
            output: out std_logic_vector( 15 downto 0)
        );
    end component;
    type FSMStates is ( S0, S01, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, S20, S21,S22,S23,S24);
    signal state: FSMStates;
    signal se9: std_logic_vector( 15 downto 0);
    signal sig: std_logic_vector( 15 downto 0);

    constant ADD : std_logic_vector(3 downto 0) := "0001";
    constant ADC : std_logic_vector(3 downto 0) := "0001";
    constant ADZ : std_logic_vector(3 downto 0) := "0001";
    constant ADL : std_logic_vector(3 downto 0) := "0001";
    constant ADI : std_logic_vector(3 downto 0) := "0000";
    constant NDU : std_logic_vector(3 downto 0) := "0010";
    constant NDC : std_logic_vector(3 downto 0) := "0010";
    constant NDZ : std_logic_vector(3 downto 0) := "0010";
    constant LHI : std_logic_vector(3 downto 0) := "0000";
    constant LW : std_logic_vector(3 downto 0) :=  "0101";
    constant SW : std_logic_vector(3 downto 0) :=  "0111";
    constant LM : std_logic_vector(3 downto 0) :=  "1101";
    constant SM : std_logic_vector(3 downto 0) :=  "1100";
    constant BEQ : std_logic_vector(3 downto 0) := "1000";
    constant JAL : std_logic_vector(3 downto 0) := "1000";
    constant JLR : std_logic_vector(3 downto 0) := "1001";
    constant JRI : std_logic_vector(3 downto 0) := "1011";

    begin

        process(clk ,state, pc_out, ir_out, mem_do, t1_out, t2_out, t3_out, alu_out, rf_d1, rf_d2, c_out, z_out, alu_c, alu_z)
            variable op_code: std_logic_vector( 15 downto 12);
            variable nxt_state: FSMStates;
            variable temp : std_logic := '0';
            variable pc: std_logic_vector ( 15 downto 0);
            variable tc1: std_logic_vector( 2 downto 0);
            begin
                nxt_state := state;
                
                case state is 

                    when S0 =>
                        state_out <= "11111";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';
                        nxt_state := S1;

                    when S01 =>
                        state_out <= "00000";
                        mem_add <= pc_out;
                        ir_in <= mem_do;
                        ir_wen <='1';
                        op_code := mem_do(15 downto 12);
                        -- case op_code is
                        --     when "0000" => 
                        --         nxt_state := S2;
                        --     when "0001" =>
                        --         nxt_state := S2;
                        --     when "0010" =>
                        --         nxt_state := S2;
                        --     when "0011" =>
                        --         nxt_state := S2;
                        --     when "0100" =>
                        --         nxt_state := S2;
                        --     when "0101" =>
                        --         nxt_state := S2;
                        --     when "0110" =>
                        --         nxt_state := S2;
                        --     when "0111" =>
                        --         nxt_state := S2;
                        --     when "1000" =>
                        --         nxt_state :=  ;
                        --     when "1001" =>
                        --         nxt_state := ; 
                        --     when "1100" =>
                        --         nxt_state := ;
                        -- end case;
                        
                        nxt_state := S1;
                        
                    when S1 =>
                        state_out <= "00001";
                        
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '1';
                        pc_wen <= '1';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';

                        rf_a1 <= "111";
                        mem_add <= rf_d1;
                        alu_a <= rf_d1;
                        alu_b <= (0 => '1', others => '0');
                        alu_oper <= "00"; -- 00 for addition
                        pc_in  <= alu_out;
                        
                        ir_in <= mem_do;
                        op_code := mem_do(15 downto 12);
                        
                        if(op_code = ADD or op_code  = ADC or op_code = ADZ or op_code = ADL or op_code = NDU or op_code = NDC or op_code = NDZ ) then
                            nxt_state := S2;
                        elsif op_code =LW or op_code =SW  then -- LW AND SW
                            nxt_state := S5;
                        elsif op_code = JAL then -- JAL
                            nxt_state := S14;
                        elsif op_code =LHI then -- LHI
                            nxt_state := S3;
                        elsif op_code = ADI  then -- ADI
                            nxt_state := S4;
                        elsif op_code = JLR then -- JLR
                            nxt_state := S19;
                        elsif op_code = LM then
                            nxt_state := S20;
                        elsif op_code = SM then
                            nxt_state := S20;
                        else
                            nxt_state := S0;
                        end if;



                        
                    when S2 =>
                        state_out <= "00010";

                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '1';
                        t2_wen <= '1';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';


                        rf_a1 <= ir_out(11 downto 9);
                        rf_a2 <= ir_out(8 downto 6);
                        t1_in <= rf_d1;
                        t2_in <= rf_d2;

                        if (op_code = "0001" or op_code ="0010") then-- ADC OR NDC
                            if (ir_out(0) = '0' and ir_out(1) ='0') then
                                nxt_state := S7;

                            elsif (ir_out(0) = '0' and ir_out(1) ='1') then -- FOR ADC AND NDC
                                if (c_out = '1') then
                                    nxt_state := S7;
                                else
                                    nxt_state := S21; --buffer state -----------------------------------------------------------------------
                                end if;
                            elsif (ir_out(0) = '1' and ir_out(1) ='0')  then -- FOR ADZ AND NDZ
                                if (z_out = '1') then
                                    nxt_state := S7;
                                else
                                    nxt_state := S21;
                                end if;
                            elsif (ir_out(0) = '1' and ir_out(1) ='1' and op_code ="0001" ) then -- FOR adl
                                nxt_state := S9;
                            else
                                nxt_state :=  S0;
                            end if;
                        end if;
                    

                    when S3 =>
                        state_out <= "00011";
                        
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '1';
                        mem_wen <= '0';

                        
                        sig (15 downto 7) <= ir_out(8 downto 0);
                        se1: for i in 6 downto 0 loop
                            sig(i) <= '0';
                        end loop se1;
                        rf_d3 <= sig;
                        rf_a3 <= ir_out (11 downto 9);

                        nxt_state := S21;
                    

                    when S4 =>
                        state_out <= "00100";
                        
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '1';
                        t2_wen <= '1';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';


                        rf_a1 <= ir_out (11 downto 9);
                        t1_in <= rf_d1;
                        sig (5 downto 0) <= ir_out(5 downto 0);
                            
                        se2: for i in 15 downto 6 loop
                            sig(i) <= ir_out(5);
                        end loop se2;
                        
                        t2_in <= sig;
                        nxt_state := S7;

                    when S5 =>
                        state_out <= "00110";
                        
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '1';
                        t2_wen <= '1';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';


                        rf_a1 <= ir_out( 8 downto 6);
                        t1_in <= rf_d1;
                        t2_in (5 downto 0) <= ir_out(5 downto 0);
                            
                        se3: for i in 15 downto 6 loop
                            t2_in(i) <= ir_out(5);
                        end loop se3;
                        
                        nxt_state := S7;
                        
                    when S6 =>
                        state_out <= "00110";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '1';
                        
                        if t3_out(7-to_integer(unsigned(t2_out))) ='1' then
                            rf_a1 <= t2_out( 2 downto 0);
                            mem_din <= rf_d1;
                            mem_add <= t1_out;
                        end if;

                        nxt_state := S23;

                    when S7 =>
                        state_out <= "00111";
                        
                        c_wen <= '1';
                        z_wen <= '1';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '1';
                        rf_wen <= '0';
                        mem_wen <= '0';


                        if (op_code = "0001" or op_code = "0101" or op_code = "0111" or op_code ="1011" or op_code="1001") then
                            alu_oper <= "00";
                        elsif (op_code = "0010") then
                            alu_oper <= "01";
                        end if;
                        
                        alu_a <= t1_out;
                        alu_b <= t2_out;
                        t3_in <= alu_out;

                        if (op_code = "0001" or op_code ="0010") then
                            
                            nxt_state := S8;
                        elsif (op_code = "0101") then
                            
                            nxt_state := S11;
                        elsif (op_code = "0111") then
                            
                            nxt_state := S10;
                        elsif (op_code = "1011") then
                            
                            nxt_state := S17;
                        elsif (op_code = "1001") then
                            
                            nxt_state := S17;
                        end if;
                        
                    when S8 =>
                        state_out <= "01000";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '1';
                        mem_wen <= '0';


                        rf_a3 <= ir_out( 5 downto 3);
                        rf_d3 <= t3_out;

                        nxt_state := S21;

                    when S9 =>
                        state_out <= "01001";
                        
                        c_wen <= '1';
                        z_wen <= '1';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '1';
                        rf_wen <= '0';
                        mem_wen <= '0';


                        alu_b <= t2_out(14 downto 0) & '0'; --left shift
                        alu_a <= t1_out;
                        alu_oper <= "00"; -- added
                        t3_in <= alu_out;

                        nxt_state := S8;

                    when S10 =>
                        state_out <= "01010";
                        
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '1';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';


                        rf_a1 <= ir_out (11 downto 9);
                        t1_in <= rf_d1;
                        
                        nxt_state := S13;

                    when S11 =>
                        state_out <= "01011";

                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '1';
                        rf_wen <= '0';
                        mem_wen <= '0';
                        

                        mem_add <= t3_out;
                        t3_in <= mem_do; --- mem_do

                        nxt_state := S12;
                    
                    ------------------------ CHECK HERE BEFORE MOVING AHEAD ----------------------
                    when S12 =>
                        state_out <= "01100";

                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '1';
                        mem_wen <= '0';

                        -- t1_wen <= '1';
                        -- t3_wen <= '0';
                        
                        rf_a3 <= ir_out( 11 downto 9);
                        rf_d3 <= t3_out;

                        nxt_state := S21;
                        
                    when S13 =>
                        state_out <= "01100";
                        
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '1';


                        mem_add <= t3_out;
                        mem_din <= t1_out;
                        
                        nxt_state := S21;

                    when S14 =>
                        state_out <= "01110";
                        
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '1';
                        t2_wen <= '1';
                        t3_wen <= '0';
                        rf_wen <= '1';
                        mem_wen <= '0';


                        rf_d3 <= pc_out;
                        rf_a3 <=ir_out( 11 downto 9);
                        rf_a1 <= "111";
                        t1_in <= rf_d1;
                        
                        t2_in (8 downto 0) <= ir_out(8 downto 0);
                            
                        se4: for i in 15 downto 9 loop
                            t2_in(i) <= ir_out(8);
                        end loop se4;

                        nxt_state := S7;

                    when S15 =>
                        state_out <= "01111";

                        c_wen <= '1';
                        z_wen <= '1';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';

                        -- t1_wen <= '0';  
                        -- t2_wen <= '0';

                        alu_a <= t1_out;
                        alu_b <= t2_out;
                        alu_oper <= "10";
                        
                        nxt_state := S16;

                    when S16 =>
                        state_out <= "10000";

                        c_wen <= '1';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '1';
                        rf_wen <= '0';
                        mem_wen <= '0';

                        alu_oper <= "00";
                        alu_a <= pc_out;
                        alu_b (5 downto 0) <= ir_out(5 downto 0);
                            
                        se5: for i in 15 downto 6 loop
                            alu_b (i) <= ir_out(5);
                        end loop se5;

                        t3_in <= alu_out;
                        
                        if (z_out ='1') then
                            nxt_state := S17;
                        else 
                            nxt_state := S21;
                        end if;

                    when S17 =>

                        state_out <= "10001";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '1';
                        mem_wen <= '0';
                        
                        rf_a3 <= "111";
                        rf_d3 <= t3_out;
                        
                        nxt_state := S0;

                    when S18 =>
                        state_out <= "10010";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '1';
                        t2_wen <= '1';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';


                        rf_a1 <= ir_out (11 downto 9);
                        t1_in <= rf_d1;
                        
                        t2_in(8 downto 0) <= ir_out(8 downto 0);
                            
                        se6: for i in 15 downto 9 loop
                            t2_in (i) <= ir_out(8);
                        end loop se6;
                        
                        nxt_state := S7;
                    when S19 =>
                        state_out <= "10011";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        mem_wen <= '0';


                        rf_wen <= '1';
                        rf_d3 <= pc_out;
                        rf_a3 <= ir_out (11 downto 9);
                        rf_a1 <= ir_out ( 8 downto 6);
                        pc_wen <= '1';
                        pc_in <= rf_d1;

                        nxt_state := S21;

                    when S20 =>
                        state_out <= "10100";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        t1_wen <= '1';
                        t2_wen <= '1';
                        t3_wen <= '1';
                        mem_wen <= '0';


                        rf_a1 <= ir_out(11 downto 9);
                        t1_in <= rf_d1;
                        
                        t3_in(8 downto 0) <= ir_out(8 downto 0);
                            
                        se7: for i in 15 downto 9 loop
                            t3_in (i) <= ir_out(8);
                        end loop se7;

                        t2_in(2 downto 0) <= "000";
                        t2_in(15 downto 3) <= ( others => '0' );
                        
                        if op_code = LM then
                            nxt_state := S22;
                        elsif op_code = SM then
                            nxt_state := S6;
                        end if;

                    when S21 =>
                        state_out <= "10101";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '1';
                        mem_wen <= '0';

                        rf_a3 <= "111";
                        rf_d3 <= pc_out;

                        nxt_state := S0;

                    when S22 =>
                        state_out <= "10110";
                        c_wen <= '0';
                        z_wen <= '0';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '1';
                        mem_wen <= '0';
                        

                        if t3_out(7-to_integer(unsigned(t2_out))) ='1' then
                            rf_a3 <= t2_out( 2 downto 0);
                            mem_add <= t1_out;
                            rf_d3 <= mem_do;
                        end if;
                        nxt_state := S23;

                       

                    when S23 =>
                        state_out <= "10111";
                        c_wen <= '1';
                        z_wen <= '1';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '1';
                        t2_wen <= '0';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';

                        alu_a <= t1_out;
                        alu_b <= (0 => '1', others => '0');
                        alu_oper <= "00";
                        t1_in <= alu_out;

                        nxt_state := S24;

                    when S24 =>
                        state_out <= "10111";
                        c_wen <= '1';
                        z_wen <= '1';
                        ir_wen <= '0';
                        pc_wen <= '0';
                        t1_wen <= '0';
                        t2_wen <= '1';
                        t3_wen <= '0';
                        rf_wen <= '0';
                        mem_wen <= '0';

                        alu_a <= t2_out;
                        alu_b <= (0 => '1', others => '0');
                        alu_oper <= "00";
                        t2_in <= alu_out;
                        
                        if alu_out(3 downto 0) = "1000" then
                            nxt_state :=S21;
                        else
                            if op_code = LM then
                                nxt_state := S22;    
                            elsif op_code = SM then
                                nxt_state := S6;
                            end if;
                        end if;

                    when others => null;
                end case;
                    
                if rising_edge(clk) then
                    if (rst ='1') then
                        state <= S0;
                    else
                        state <= nxt_state;
                    end if;
                end if;
                
        end process;
end behave;
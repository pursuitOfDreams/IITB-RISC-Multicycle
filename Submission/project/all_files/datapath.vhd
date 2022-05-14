library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port(
        clk: in std_logic;
        rst: in std_logic;
        memory_write: in std_logic;
        write_address: in std_logic_vector( 15 downto 0);
        instruction: in std_logic_vector( 15 downto 0);
        state_out: out std_logic_vector (4 downto 0)
    );
end datapath;


architecture dp_arc of datapath is

    component register_OneBit
        port(
            output        : out std_logic;
            input       : in  std_logic;
            write_ena : in  std_logic;
            clk         : in  std_logic
        );
    end component;

    component register_SixteenBit
        port(
            output        : out std_logic_vector( 15 downto 0);
            input       : in  std_logic_vector( 15 downto 0);
            write_ena : in  std_logic;
            clk         : in  std_logic
        );
    end component;

    component register_file
        port(
            clk : in std_logic;
            input : in std_logic_vector( 15 downto 0);
            ra1_sel, ra2_sel : in std_logic_vector(2 downto 0);
            write_ena : in std_logic;
            write_at : in std_logic_vector( 2 downto 0);
            out1 ,out2 : out std_logic_vector( 15 downto 0)
        );
    end component;

    component RAM 
			port(
			  address, input: in std_logic_vector(15 downto 0);
			  write_ena : in std_logic;
			  clk : in std_logic;
			  output: out std_logic_vector(15 downto 0)
			);
    end component;

    component control_path
        port(
            clk, rst: in std_logic; -- clock variables
            pc_in, ir_in, mem_din, t1_in, t2_in, t3_in, alu_a, alu_b, mem_add, rf_d3: out std_logic_vector( 15 downto 0);

            pc_out, ir_out, mem_do, t1_out, t2_out, t3_out, rf_d1, rf_d2, alu_out : in std_logic_vector( 15 downto 0);

            ir_wen, pc_wen, t1_wen, t2_wen, t3_wen, rf_wen, mem_wen, c_wen, z_wen : out std_logic; -- update controls
            c_out, z_out, alu_c, alu_z: in std_logic;

            rf_a1, rf_a2, rf_a3 : out std_logic_vector(2 downto 0);
            alu_oper: out std_logic_vector( 1 downto 0);
            state_out : out std_logic_vector( 4 downto 0)
        );
    end component;

    component ALU
        port(
            alu_a, alu_b : in std_logic_vector( 15 downto 0);
            operation : in std_logic_vector( 1 downto 0);
            alu_output: out std_logic_vector( 15 downto 0);
            carry, zero: out std_logic
        );
    end component;
	 
	 component Mux2x1
			port(
				i0: in std_logic;
				i1: in std_logic;
				sel: in std_logic;
				output: out std_logic
			);
	 end component;

    signal rf_a1, rf_a2, rf_a3 : std_logic_vector( 2 downto 0);
    signal rf_d1, rf_d2, rf_d3: std_logic_vector( 15 downto 0);
    signal t1_in, t1_out, t2_in, t2_out, t3_in, t3_out: std_logic_vector( 15 downto 0);
    signal pc_wen, ir_wen, rf_wen, t1_wen, t2_wen, t3_wen, c_wen, z_wen, mem_wen: std_logic;
    signal alu_oper: std_logic_vector( 1 downto 0);
    signal alu_a, alu_b, alu_out: std_logic_vector( 15 downto 0);
    signal memory_address, memory_din: std_logic_vector( 15 downto 0);
    signal mem_add, mem_din, mem_do: std_logic_vector( 15 downto 0);
    signal pc_in, pc_out: std_logic_vector( 15 downto 0);
    signal  ir_in, ir_out: std_logic_vector( 15 downto 0);
    signal c_out, z_out: std_logic;
    signal alu_c, alu_Z: std_logic;
    signal mem_write: std_logic;    

begin

    program_counter: register_SixteenBit port map (pc_out,pc_in,pc_wen,clk);

    -- memory
    memory: RAM port map (memory_address,memory_din,mem_write,clk,mem_do);

    -- registers
    inst_register: register_SixteenBit port map (ir_out,ir_in,ir_wen,clk);
    registerFile: register_file port map (clk, rf_d3, rf_a1, rf_a2,rf_wen,rf_a3,rf_d1,rf_d2);
    temp_register1: register_SixteenBit port map (t1_out, t1_in, t1_wen, clk);
    temp_register2: register_SixteenBit port map (t2_out, t2_in, t2_wen, clk);
    temp_register3: register_SixteenBit port map (t3_out, t3_in, t3_wen, clk);

    -- flags
    carryFlag: register_OneBit port map (c_out, alu_c, c_wen, clk);
    zeroFlag: register_OneBit port map (z_out, alu_z, z_wen, clk);

    a: ALU port map (alu_a, alu_b, alu_oper, alu_out,alu_c,alu_z);

    state_machine: control_path port map (clk,rst,
        pc_in,ir_in,mem_din,t1_in,t2_in,t3_in,alu_a,alu_b,mem_add, rf_d3,
        pc_out,ir_out,mem_do,t1_out, t2_out,t3_out, rf_d1,rf_d2,alu_out,
        ir_wen,pc_wen,t1_wen,t2_wen,t3_wen,rf_wen,mem_wen,c_wen,z_wen,
        c_out,z_out,alu_c,alu_z,
        rf_a1,rf_a2,rf_a3,
        alu_oper,
        state_out);


    mem_write <= mem_wen or memory_write;

    address: for i in 0 to 15 generate
			addnode: Mux2x1 port map (mem_add(i),write_address(i),memory_write,memory_address(i));
--        if (memory_write = '1') then
--            memory_address(i) <= write_address(i);
--        else
--            memory_address(i) <= mem_add(i);
--        end if;
    end generate address;

    datain: for i in 0 to 15 generate
			addnode: Mux2x1 port map (mem_din(i),instruction(i),memory_write,memory_din(i));
--        if (memory_write = '1') then
--            memory_din(i) <= instruction(i);
--        else
--            memory_din(i) <= mem_din(i);
--        end if;
    end generate datain;


end architecture;
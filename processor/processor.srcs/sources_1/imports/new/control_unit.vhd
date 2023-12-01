------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/22/2019 10:06:20 AM
-- Design Name:
-- Module Name: control_unit - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;


entity control_unit is
	port (
		clock : in std_logic;
		reset : in std_logic;
		write : out std_logic;
		IR_Load : out std_logic;
		IR : in std_logic_vector(7 downto 0);
		MAR_Load : out std_logic;
		PC_Load : out std_logic;
		PC_Inc : out std_logic;
		A_Load : out std_logic;
		B_Load : out std_logic;
		ALU_Sel : out std_logic_vector(2 downto 0);
		CCR_Result : in std_logic_vector(3 downto 0);
		CCR_Load : out std_logic;
		Bus1_Sel : out std_logic_vector(1 downto 0);
		Bus2_Sel : out std_logic_vector(1 downto 0)
	);
end entity;

architecture control_unit_arch of control_unit is

	-- Constants for Instruction Pnemonics
	constant LDA_IMM : std_logic_vector(7 downto 0) := x"86";  -- Load Register A with Immediate Addressing
	constant LDA_DIR : std_logic_vector(7 downto 0) := x"87";  -- Load Register A with Direct Addressing
	constant LDB_IMM : std_logic_vector(7 downto 0) := x"88";  -- Load Register B with Immediate Addressing
	constant LDB_DIR : std_logic_vector(7 downto 0) := x"89";  -- Load Register B with Direct Addressing
	constant STA_DIR : std_logic_vector(7 downto 0) := x"96";  -- Store Register A to memory (RAM or IO)
	constant STB_DIR : std_logic_vector(7 downto 0) := x"97";  -- Store Register B to memory (RAM or IO)
	constant ADD_AB : std_logic_vector(7 downto 0) := x"42";  -- A <= A + B
	constant SUB_AB : std_logic_vector(7 downto 0) := x"43";  -- A <= A - B
	constant AND_AB : std_logic_vector(7 downto 0) := x"44";  -- A <= A and B
	constant OR_AB : std_logic_vector(7 downto 0) := x"45";  -- A <= A or B
	constant INCA : std_logic_vector(7 downto 0) := x"46";  -- A <= A + 1
	constant INCB : std_logic_vector(7 downto 0) := x"47";  -- B <= B + 1
	constant DECA : std_logic_vector(7 downto 0) := x"48";  -- A <= A - 1
	constant DECB : std_logic_vector(7 downto 0) := x"49";  -- B <= B - 1
	constant BRA : std_logic_vector(7 downto 0) := x"20";  -- Branch Always
	constant BMI : std_logic_vector(7 downto 0) := x"21";  -- Branch if N=1
	constant BPL : std_logic_vector(7 downto 0) := x"22";  -- Branch if N=0
	constant BEQ : std_logic_vector(7 downto 0) := x"23";  -- Branch if Z=1
	constant BNE : std_logic_vector(7 downto 0) := x"24";  -- Branch if Z=0
	constant BVS : std_logic_vector(7 downto 0) := x"25";  -- Branch if V=1
	constant BVC : std_logic_vector(7 downto 0) := x"26";  -- Branch if V=0
	constant BCS : std_logic_vector(7 downto 0) := x"27";  -- Branch if C=1
	constant BCC : std_logic_vector(7 downto 0) := x"28";  -- Branch if C=0

	type state_type is (S_FETCH_0,  -- Opcode fetch states
		S_FETCH_1,
		S_FETCH_2,

		S_DECODE_3,  -- Opcode decode state

		S_LDA_IMM_4,  -- Load A (Immediate) states
		S_LDA_IMM_5,
		S_LDA_IMM_6,

		S_LDA_DIR_4,  -- Load A (Direct) states
		S_LDA_DIR_5,
		S_LDA_DIR_6,
		S_LDA_DIR_7,
		S_LDA_DIR_8,

		S_STA_DIR_4,  -- Store A (Direct) States
		S_STA_DIR_5,
		S_STA_DIR_6,
		S_STA_DIR_7,

		S_LDB_IMM_4,  -- Load B (Immediate) states
		S_LDB_IMM_5,
		S_LDB_IMM_6,

		S_LDB_DIR_4,  -- Load B (Direct) states
		S_LDB_DIR_5,
		S_LDB_DIR_6,
		S_LDB_DIR_7,
		S_LDB_DIR_8,

		S_STB_DIR_4,  -- Store B (Direct) States
		S_STB_DIR_5,
		S_STB_DIR_6,
		S_STB_DIR_7,

		S_ADD_AB_4,  -- Data Manipulations

		S_BRA_4,  -- Branch States
		S_BRA_5,
		S_BRA_6,

		S_BEQ_4,
		S_BEQ_5,
		S_BEQ_6,
		S_BEQ_7
	);

	signal current_state, next_state : state_type;

begin

	---------------------------------------------------------------------------
	-- STATE MEMORY
	---------------------------------------------------------------------------
	STATE_MEMORY : process (Clock, Reset)
	begin
		if (Reset = '0') then
			current_state <= S_FETCH_0;
		elsif (clock'event and clock = '1') then
			current_state <= next_state;
		end if;
	end process;

	---------------------------------------------------------------------------
	-- NEXT STATE LOGIC
	---------------------------------------------------------------------------
	NEXT_STATE_LOGIC : process (current_state, IR, CCR_Result)
	begin
		if (current_state = S_FETCH_0) then
			next_state <= S_FETCH_1;
		elsif (current_state = S_FETCH_1) then
			next_state <= S_FETCH_2;
		elsif (current_state = S_FETCH_2) then
			next_state <= S_DECODE_3;
		elsif (current_state = S_DECODE_3) then

			-- here is where the different paths in the FSM are decided
			if (IR = LDA_IMM) then
				next_state <= S_LDA_IMM_4;  -- Register A
			elsif (IR = LDA_DIR) then
				next_state <= S_LDA_DIR_4;
			elsif (IR = STA_DIR) then
				next_state <= S_STA_DIR_4;

			elsif (IR = LDB_IMM) then
				next_state <= S_LDB_IMM_4;  --  Register B
			elsif (IR = LDB_DIR) then
				next_state <= S_LDB_DIR_4;
			elsif (IR = STB_DIR) then
				next_state <= S_STB_DIR_4;

			elsif (IR = ADD_AB) then  -- Add
				next_state <= S_ADD_AB_4;

			elsif (IR = BRA) then  -- Branches
				next_state <= S_BRA_4;

			-- CCR_Result(2) = Zero flag
			elsif (IR = BEQ and CCR_Result(2) = '1') then
				next_state <= S_BEQ_4;

			-- CCR_Result(2) = Zero flag
			elsif (IR = BEQ and CCR_Result(2) = '0') then
				next_state <= S_BEQ_7;

			else
				next_state <= S_FETCH_0;
			end if;

		-- Path for LDA_IMM instruction
		elsif (current_state = S_LDA_IMM_4) then
			next_state <= S_LDA_IMM_5;
		elsif (current_state = S_LDA_IMM_5) then
			next_state <= S_LDA_IMM_6;
		elsif (current_state = S_LDA_IMM_6) then
			next_state <= S_FETCH_0;

		-- Path for LDA_DIR instruction
		elsif (current_state = S_LDA_DIR_4) then
			next_state <= S_LDA_DIR_5;
		elsif (current_state = S_LDA_DIR_5) then
			next_state <= S_LDA_DIR_6;
		elsif (current_state = S_LDA_DIR_6) then
			next_state <= S_LDA_DIR_7;
		elsif (current_state = S_LDA_DIR_7) then
			next_state <= S_LDA_DIR_8;
		elsif (current_state = S_LDA_DIR_8) then
			next_state <= S_FETCH_0;

		-- Path for STA_DIR instruction
		elsif (current_state = S_STA_DIR_4) then
			next_state <= S_STA_DIR_5;
		elsif (current_state = S_STA_DIR_5) then
			next_state <= S_STA_DIR_6;
		elsif (current_state = S_STA_DIR_6) then
			next_state <= S_STA_DIR_7;
		elsif (current_state = S_STA_DIR_7) then
			next_state <= S_FETCH_0;

		-- Path for LDB_IMM instruction
		elsif (current_state = S_LDB_IMM_4) then
			next_state <= S_LDB_IMM_5;
		elsif (current_state = S_LDB_IMM_5) then
			next_state <= S_LDB_IMM_6;
		elsif (current_state = S_LDB_IMM_6) then
			next_state <= S_FETCH_0;

		-- Path for LDB_DIR instruction
		elsif (current_state = S_LDB_DIR_4) then
			next_state <= S_LDB_DIR_5;
		elsif (current_state = S_LDB_DIR_5) then
			next_state <= S_LDB_DIR_6;
		elsif (current_state = S_LDB_DIR_6) then
			next_state <= S_LDB_DIR_7;
		elsif (current_state = S_LDB_DIR_7) then
			next_state <= S_LDB_DIR_8;
		elsif (current_state = S_LDB_DIR_8) then
			next_state <= S_FETCH_0;

		-- Path for STB_DIR instruction
		elsif (current_state = S_STB_DIR_4) then
			next_state <= S_STB_DIR_5;
		elsif (current_state = S_STB_DIR_5) then
			next_state <= S_STB_DIR_6;
		elsif (current_state = S_STB_DIR_6) then
			next_state <= S_STB_DIR_7;
		elsif (current_state = S_STB_DIR_7) then
			next_state <= S_FETCH_0;

		-- Path for BRA instruction
		elsif (current_state = S_BRA_4) then
			next_state <= S_BRA_5;
		elsif (current_state = S_BRA_5) then
			next_state <= S_BRA_6;
		elsif (current_state = S_BRA_6) then
			next_state <= S_FETCH_0;

		-- Path for BEQ and Z=1 instruction
		elsif (current_state = S_BEQ_4) then
			next_state <= S_BEQ_5;
		elsif (current_state = S_BEQ_5) then
			next_state <= S_BEQ_6;
		elsif (current_state = S_BEQ_6) then
			next_state <= S_FETCH_0;

		-- Path for BEQ and Z=0 instruction
		elsif (current_state = S_BEQ_7) then
			next_state <= S_FETCH_0;

		-- Path for ADD_AB instruction
		elsif (current_state = S_ADD_AB_4) then
			next_state <= S_FETCH_0;

		else
			next_state <= S_FETCH_0;

		end if;
	end process;

	--------------------------------------------------------------------
	-- OUTPUT LOGIC
	--------------------------------------------------------------------
	OUTPUT_LOGIC : process (current_state)
	begin
		case (current_state) is
			when S_FETCH_0 =>  -- Put PC onto MAR to provide address of Opcode
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_FETCH_1 =>  -- Increment PC, Opcode will be available next state
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_FETCH_2 =>  -- Put Opcode into IR
			IR_Load <= '1';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_DECODE_3 =>  -- No outputs, machine is decoding IR to decide which state to go to next
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			--------------------------------------------------------------------
			-- LDA_IMM
			--------------------------------------------------------------------
			when S_LDA_IMM_4 =>  -- Put PC into MAR to provide address of Operand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDA_IMM_5 =>  -- Increment PC, Operand will be available next state
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDA_IMM_6 =>  -- Operand is available, latch into A
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			--------------------------------------------------------------------
			-- LDA_DIR
			--------------------------------------------------------------------
			when S_LDA_DIR_4 =>  -- Put PC onto MAR to provide address of Operand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDA_DIR_5 =>  -- Prepare to receive Operand from memory, increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDA_DIR_6 =>  -- Put Operand into MAR (Leave Bus2=from_memory)
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDA_DIR_7 =>  -- Wait for memory to respond
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDA_DIR_8 =>  -- Put data arriving on "from_memory" into A
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			--------------------------------------------------------------------
			-- STA_DIR
			--------------------------------------------------------------------
			when S_STA_DIR_4 =>  -- Put PC onto MAR to provide address of Operand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_STA_DIR_5 =>  -- Prepare to receive Operand from memory, increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_STA_DIR_6 =>  -- Put Operand into MAR (Leave Bus2=from_memory)
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_STA_DIR_7 =>  -- Put A onto Bus2, which is connected to "to_memory", assert write
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "01";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '1';

			--------------------------------------------------------------------
			-- LDB_IMM
			--------------------------------------------------------------------
			when S_LDB_IMM_4 =>  -- Put PC into MAR to provide address of Operand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDB_IMM_5 =>  -- Increment PC, Operand will be available next state
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDB_IMM_6 =>  -- Operand is available, latch into B
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			--------------------------------------------------------------------
			-- LDB_DIR
			--------------------------------------------------------------------
			when S_LDB_DIR_4 =>  -- Put PC onto MAR to provide address of Operand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDB_DIR_5 =>  -- Prepare to receive Operand from memory, increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDB_DIR_6 =>  -- Put Operand into MAR (Leave Bus2=from_memory)
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDB_DIR_7 =>  -- Wait for memory to respond
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_LDB_DIR_8 =>  -- Put data arriving on "from_memory" into B
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			--------------------------------------------------------------------
			-- STB_DIR
			--------------------------------------------------------------------
			when S_STB_DIR_4 =>  -- Put PC onto MAR to provide address of Operand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_STB_DIR_5 =>  -- Prepare to receive Operand from memory, increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_STB_DIR_6 =>  -- Put Operand into MAR (Leave Bus2=from_memory)
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_STB_DIR_7 =>  -- Put B onto Bus2, which is connected to "to_memory", assert write
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "10";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '1';

			--------------------------------------------------------------------
			-- ADD_AB
			--------------------------------------------------------------------
			when S_ADD_AB_4 =>  -- Assert control signals to perfom addition
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '1';
			Bus1_Sel <= "01";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			--------------------------------------------------------------------
			-- BRA
			--------------------------------------------------------------------
			when S_BRA_4 =>  -- Put PC onto MAR to provide address of Operand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_BRA_5 =>  -- Prepare to receive Operand from memory
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_BRA_6 =>  -- Put Operand into PC (Leave Bus2=from_memory)
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			--------------------------------------------------------------------
			-- BEQ
			--------------------------------------------------------------------
			when S_BEQ_4 =>  -- Put PC onto MAR to provide address of Operand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_BEQ_5 =>  -- Prepare to receive Operand from memory
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_BEQ_6 =>  -- Put Operand into PC (Leave Bus2=from_memory)
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			when S_BEQ_7 =>  -- Z=0 so just increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

			--------------------------------------------------------------------
			-- OTHERS
			--------------------------------------------------------------------
			when others =>
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00";  -- "00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00";  -- "00"=ALU, "01"=Bus1, "10"=from_memory
			write <= '0';

		end case;
	end process;

end architecture;

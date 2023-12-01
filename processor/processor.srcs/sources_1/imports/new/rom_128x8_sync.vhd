------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/22/2019 10:09:20 AM
-- Design Name:
-- Module Name: rom_128x8_sync - Behavioral
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
use IEEE.numeric_std.all;


entity rom_128x8_sync is
	port (
		clock : in std_logic;
		address : in std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(7 downto 0));
end entity;

architecture rom_128x8_sync_arch of rom_128x8_sync is

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

	type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);

	-- constant ROM : rom_type := (
	-- 	0 => LDB_IMM,
	-- 	1 => x"CC",
	-- 	2 => STB_DIR,
	-- 	3 => x"80",
	-- 	4 => LDA_DIR,
	-- 	5 => x"80",
	-- 	6 => BRA,
	-- 	7 => x"00",
	--
	-- 	others => x"00"
	-- );

	-- constant ROM : rom_type := (
	-- 	0 => LDA_IMM,
	-- 	1 => x"FF",
	-- 	2 => LDB_IMM,
	-- 	3 => x"01",
	-- 	4 => ADD_AB,
	-- 	5 => BRA,
	-- 	6 => x"00",
	--
	-- 	others => x"00"
	-- );

	-- constant ROM : rom_type := (
	-- 	0 => LDA_DIR,
	-- 	1 => x"F0",
	-- 	2 => LDB_DIR,
	-- 	3 => x"F1",
	-- 	4 => ADD_AB, -- Put the result in regA
	-- 	5 => STA_DIR,
	-- 	6 => x"E0",
	-- 	7 => BRA,
	-- 	8 => x"00",
	--
	-- 	others => x"00"
	-- );

	-- constant ROM : rom_type := (
	-- 	-- Reset:
	-- 	0 => LDB_IMM,
	-- 	1 => x"00",  -- Reset toggle to 0
	-- 	2 => STB_DIR,
	-- 	3 => x"80",  -- Store in memory
	-- 	4 => STB_DIR,
	-- 	5 => x"E0",  -- Output to port out 00
	-- 	-- Main:
	-- 	6 => LDB_DIR,
	-- 	7 => x"F0",  -- Load toggle button (port in 00) into B register
	-- 	8 => LDA_IMM,
	-- 	9 => x"00",  -- Load 0 into A register
	-- 	10 => ADD_AB,  -- Add A and B to set status registers
	-- 	11 => BEQ,
	-- 	12 => x"06",  -- Loop back to Main if toggle button is not pressed (Z = 1)
	-- 	-- If Pressed
	-- 	13 => LDB_DIR,
	-- 	14 => x"80",  -- Get toggle setting
	-- 	15 => LDA_IMM,
	-- 	16 => x"00",  -- Load 1 into A register
	-- 	17 => ADD_AB,  -- Add A and B to set statu registers
	-- 	18 => BEQ,
	-- 	19 => x"16",  -- Jump to Set if toggle is not set
	-- 	20 => BRA,
	-- 	21 => x"00",  -- Loop back to Reset
	-- 	-- Set Toggle
	-- 	22 => LDB_IMM,
	-- 	23 => x"01",  -- Load 1 into B register
	-- 	24 => STB_DIR,
	-- 	25 => x"80",  -- Store in memory
	-- 	26 => STB_DIR,
	-- 	27 => x"E0",  -- Output to port out 00
	-- 	28 => BRA,
	-- 	29 => x"06",  -- Loop back to Main

	-- 	-- Fill the rest of memory with 0's
	-- 	others => x"00"
	-- );

	constant ROM : rom_type := (
		-- Reset:
		0 => LDB_IMM,
		1 => x"00",  -- Reset toggle to 0
		2 => STB_DIR,
		3 => x"80",  -- Store in memory
		4 => STB_DIR,
		5 => x"E0",  -- Output to port out 00
		-- Main:
		6 => LDB_DIR,
		7 => x"F0",  -- Load toggle button (port in 00) into B register
		8 => LDA_IMM,
		9 => x"00",  -- Load 0 into A register
		10 => ADD_AB,  -- Add A and B to set status registers
		11 => BEQ,
		12 => x"06",  -- Loop back to Main if toggle button is not pressed (Z = 1)
		-- Store Pressed State
		13 => LDB_IMM,
		14 => x"01", -- Load 1 into B register
		15 => STB_DIR,
		16 => x"81",  -- Store button state
		-- Pressed:
		17 => LDB_DIR,
		18 => x"F0",  -- Load toggle button (port in 00) into B register
		19 => LDA_IMM,
		20 => x"FF",  -- Load -1 into A register
		21 => ADD_AB,  -- Add A and B to set status registers
		22 => BEQ,
		23 => x"11",  -- Loop back to Pressed
		-- Store Released State
		24 => LDB_IMM,
		25 => x"00",  -- Load 0 into B register
		26 => STB_DIR,
		27 => x"81",  -- Store button state
		-- Released:
		28 => LDB_DIR,
		29 => x"80",  -- Get toggle setting
		30 => LDA_IMM,
		31 => x"00",  -- Load 1 into A register
		32 => ADD_AB,  -- Add A and B to set statu registers
		33 => BEQ,
		34 => x"25",  -- Jump to Set if toggle is not set
		35 => BRA,
		36 => x"00",  -- Loop back to Reset
		-- Set Toggle
		37 => LDB_IMM,
		38 => x"01",  -- Load 1 into B register
		39 => STB_DIR,
		40 => x"80",  -- Store in memory
		41 => STB_DIR,
		42 => x"E0",  -- Output to port out 00
		43 => BRA,
		44 => x"06",  -- Loop back to Main

		-- Fill the rest of memory with 0's
		others => x"00"
	);

	signal EN : std_logic;

begin
	-- A circuit to create an enable so that this memory is only active for valid addresses (e.g., 0 to 127)
	enable : process (address)
	begin
		if ((to_integer(unsigned(address)) >= 0) and (to_integer(unsigned(address)) <= 127)) then
			EN <= '1';
		else
			EN <= '0';
		end if;
	end process;

	-- Model of the ROM memory
	memory : process (clock)
	begin
		if (clock'event and clock = '1') then
			if (EN = '1') then
				data_out <= ROM(to_integer(unsigned(address)));
			end if;
		end if;
	end process;

end architecture;

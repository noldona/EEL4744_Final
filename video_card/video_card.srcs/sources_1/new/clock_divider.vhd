----------------------------------------------------------------------------------
-- Engineer: Ronald Jones 
-- 
-- Create Date: 10/14/2023 08:52:34 PM
-- Design Name: VGA Clock Divider
-- Module Name: clock_divider - clock_divider_arch
-- Project Name: EEL 4744 Final Project
-- Target Devices: Basys3 Development Board
-- Description: Will generate a clock pulse from the given parameters 
-- 
-- Dependencies: None
-- 
-- Revision: 0.1.0
-- Revision 0.1.0 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
	generic(
		input_freq: real := real(100e6);
		output_freq: real := real(25175e3);
		accuracy: real := 100.0
	);
	port(
		clk : in std_logic;
		reset_bar : in std_logic;
		clk_div : out std_logic
	);
end clock_divider;

architecture clock_divider_arch of clock_divider is
	constant TOTAL_COUNT: integer := integer(input_freq / accuracy);
	constant N: integer := integer(input_freq / (2.0 * output_freq)) + 1;
	constant P: integer := N - 1;
	constant C: integer := TOTAL_COUNT / P;
	constant B: integer := C - (TOTAL_COUNT mod P);

	signal seq_ctr: integer range 0 to C - 1;  -- Sequence Counter
	signal dual_mod_load: integer range 0 to N - 1;  -- Selected Load Value
	signal dual_mod_ctr: integer range 0 to N - 1;  -- Dual Modulus Counter
	signal mux_select: std_logic; -- Select between N and P
	signal term_count: std_logic;  -- Dual Modulus Terminal Count
	signal divider: std_logic := '0';  -- Output Divider

begin
	-- This is the sequence counter. Count from C-1 downto 0. Enabled only
	-- when term_count is active. If coutn is 0, then reload to C-1
	pSeqCount: process (clk) begin
		if (rising_edge(clk)) then
			if (reset_bar = '0') then
				seq_ctr <= 0;
			else
				if (term_count = '1') then
					if (seq_ctr = 0) then
						seq_ctr <= C - 1;
					else
						seq_ctr <= seq_ctr - 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	-- This is the comparison of the current sequence count to the value B
	mux_select <= '1' when (seq_ctr < B) else '0';
	
	-- This is the dual-modulus counter. Count from dual_mod_load downto 0.
	-- Counter auto reloads when terminal count is reached.
	pDualModCount: process(clk) begin
		if (rising_edge(clk)) then
			if (reset_bar = '0') then
				dual_mod_ctr <= 0;
			else
				if (term_count = '1') then
					dual_mod_ctr <= dual_mod_load;
				else
					dual_mod_ctr <= dual_mod_ctr - 1;
				end if;
			end if;
		end if;
	end process;
	
	-- Detect the terminal count condition
	term_count <= '1' when (dual_mod_ctr = 0) else '0';
	
	-- The output divide-by-two counter
	pDivider: process(clk) begin
		if (rising_edge(clk)) then
			if (reset_bar = '0') then
				divider <= '0';
			elsif (term_count = '1') then
				divider <= not divider;
			end if;
		end if;
	end process;
	
	-- Module Output
	clk_div <= divider;
end clock_divider_arch;

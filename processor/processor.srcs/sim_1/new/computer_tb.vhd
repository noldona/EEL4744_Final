------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 12/01/2023 10:55:33 AM
-- Design Name:
-- Module Name: computer_tb - computer_tb_arch
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
use IEEE.STD_LOGIC_1164.all;


entity computer_tb is
	--  port ();
end computer_tb;

architecture computer_tb_arch of computer_tb is

	component computer
		port (
			clock : in std_logic;
			rst_btn : in std_logic;
			toggle_btn : in std_logic;
			reset_out : out std_logic;
			toggle_out : out std_logic
		);
	end component;

	--Inputs
	signal clock : std_logic := '0';
	signal rst_btn : std_logic := '1';
	signal toggle_btn : std_logic := '0';

	--Outputs
	signal reset_out : std_logic;
	signal toggle_out : std_logic;

	-- Clock period definitions
	constant clock_period : time := 10 ns;

begin
	-- Instantiate the Unit Under Test (UUT)
	UUT : computer port map(
		clock => clock,
		rst_btn => rst_btn,
		toggle_btn => toggle_btn,
		reset_out => reset_out,
		toggle_out => toggle_out
	);

	-- Clock process definitions
	CLOCK_PROCESS : process
	begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
	end process;

	COMPUTER_TEST : process
	begin
		toggle_btn <= '0';
		rst_btn <= '1';
		wait for clock_period * 5;
		rst_btn <= '0';
		wait for clock_period * 100;
		toggle_btn <= '1';
		wait for clock_period * 100;
		toggle_btn <= '0';
		wait for clock_period * 100;
		toggle_btn <= '1';
		wait for clock_period * 100;
		toggle_btn <= '0';
		wait for clock_period * 100;
		wait;
	end process;

end computer_tb_arch;

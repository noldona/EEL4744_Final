-------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/22/2019 09:53:49 AM
-- Design Name:
-- Module Name: computer - Behavioral
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
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;


entity computer is
	port (
		clock : in std_logic;
		rst_btn : in std_logic;
		toggle_btn : in std_logic;
		reset_out : out std_logic;
		toggle_out : out std_logic
	);
end entity;

architecture computer_arch of computer is
	-- Component Declaration
	component cpu
		port (
			clock : in std_logic;
			reset : in std_logic;
			to_memory : out std_logic_vector(7 downto 0);
			from_memory : in std_logic_vector(7 downto 0);
			address : out std_logic_vector(7 downto 0);
			write : out std_logic);
	end component;

	component memory
		port (
			clock : in std_logic;
			reset : in std_logic;
			address : in std_logic_vector(7 downto 0);
			write : in std_logic;
			data_in : in std_logic_vector(7 downto 0);
			data_out : out std_logic_vector(7 downto 0);
			port_in_00 : in std_logic_vector(7 downto 0);
			port_in_01 : in std_logic_vector(7 downto 0);
			port_out_00 : out std_logic_vector(7 downto 0);
			port_out_01 : out std_logic_vector(7 downto 0)
		);
	end component;

	-- Signal Declaration
	signal memory_data_in : std_logic_vector(7 downto 0);
	signal memory_data_out : std_logic_vector(7 downto 0);
	signal memory_address : std_logic_vector(7 downto 0);
	signal memory_write : std_logic;
	signal reset : std_logic;
	
	signal port_in_00 : std_logic_vector(7 downto 0) := x"00";
	signal port_in_01 : std_logic_vector(7 downto 0) := x"00";
	signal port_out_00 : std_logic_vector(7 downto 0);
	signal port_out_01 : std_logic_vector(7 downto 0);

begin
	reset <= not rst_btn;
	reset_out <= reset;
	port_in_00(0) <= toggle_btn;
	toggle_out <= port_out_00(0);

	-- Component Instantiations
	CPU_1 : cpu
	port map (
		clock => clock,
		reset => reset,
		to_memory => memory_data_in,
		from_memory => memory_data_out,
		address => memory_address,
		write => memory_write
	);

	MEMORY_1 : memory
	port map (
		clock => clock,
		reset => reset,
		address => memory_address,  -- this requires an internal signal
		write => memory_write,
		data_in => memory_data_in,  -- this requires an internal signal
		data_out => memory_data_out,  -- this requires an internal signal
		port_in_00 => port_in_00,
		port_in_01 => port_in_01,
		port_out_00 => port_out_00,
		port_out_01 => port_out_01
	);

end architecture;

------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/22/2019 10:01:34 AM
-- Design Name:
-- Module Name: memory - Behavioral
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


entity memory is
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
end entity;

architecture memory_arch of memory is

	-- Define Internal Signals
	signal rom_data_out : std_logic_vector(7 downto 0);
	signal rw_data_out : std_logic_vector(7 downto 0);

	-- Declare ROM
	component rom_128x8_sync
		port (
			clock : in std_logic;
			address : in std_logic_vector(7 downto 0);
			data_out : out std_logic_vector(7 downto 0)
		);
	end component;

	-- Declare RAM
	component rw_96x8_sync
		port (
			clock : in std_logic;
			reset: in std_logic;
			data_in : in std_logic_vector(7 downto 0);
			write : in std_logic;
			address : in std_logic_vector(7 downto 0);
			data_out : out std_logic_vector(7 downto 0));
	end component;

begin

	-- instantiate ROM for "Program Memory"
	U1 : rom_128x8_sync
		port map(
			clock => clock,
			address => address,
			data_out => rom_data_out
		);

	-- instantiate R/W for "Data Memory"
	U2 : rw_96x8_sync
		port map(
			clock => clock,
			reset => reset,
			data_in => data_in,
			write => write,
			address => address,
			data_out => rw_data_out
		);

	----------------------------------------------------------------------
	-- OUTPUT Ports
	----------------------------------------------------------------------
	-- port_out_00 description : ADDRESS x"E0"
	U3 : process (clock, reset)
	begin
		if (reset = '0') then
			port_out_00 <= x"00";
		elsif (clock'event and clock = '1') then
			if (address = x"E0" and write = '1') then
				port_out_00 <= data_in;
			end if;
		end if;
	end process;

	-- port_out_01 description : ADDRESS x"E1"
	U4 : process (clock, reset)
	begin
		if (reset = '0') then
			port_out_01 <= x"00";
		elsif (clock'event and clock = '1') then
			if (address = x"E1" and write = '1') then
				port_out_01 <= data_in;
			end if;
		end if;
	end process;


	----------------------------------------------------------------------
	-- MUX for data out
	----------------------------------------------------------------------

	MUX1 : process (address, rom_data_out, rw_data_out, port_in_00, port_in_01)
	begin
		if ((to_integer(unsigned(address)) >= 0) and (to_integer(unsigned(address)) <= 127)) then
			data_out <= rom_data_out;

		elsif ((to_integer(unsigned(address)) >= 128) and (to_integer(unsigned(address)) <= 223)) then
			data_out <= rw_data_out;

		elsif (address = x"F0") then
			data_out <= port_in_00;
		elsif (address = x"F1") then
			data_out <= port_in_01;
		else
			data_out <= x"00";
		end if;
	end process;

end architecture;

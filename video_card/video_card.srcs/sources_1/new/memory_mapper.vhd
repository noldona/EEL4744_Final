----------------------------------------------------------------------------------
-- Engineer: Ronald Jones 
-- 
-- Create Date: 10/14/2023 04:14:28 PM
-- Design Name: VGA Memory Mapper
-- Module Name: memory_mapper - memory_mapper_arch
-- Project Name: EEL 4744 Final Project
-- Target Devices: Basys3 Development Board
-- Description: This will map the addr_x and addr_y values to appropriate
-- 		memory locations with possible offset 
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

entity memory_mapper is
	generic(
		offset: integer := 0;
		x_max: integer := 16#321#;
		y_max: integer := 16#259#
	);
	port(
		clk: in std_logic;
		addr_x : in std_logic_vector(15 downto 0);
		addr_y : in std_logic_vector(15 downto 0);
		hblank: in std_logic;
		vblank: in std_logic;
		addr : out std_logic_vector(31 downto 0)
	);
end memory_mapper;

architecture memory_mapper_arch of memory_mapper is
begin
	addr <= std_logic_vector((unsigned(addr_y) * x_max) + unsigned(addr_x) + offset);
end memory_mapper_arch;

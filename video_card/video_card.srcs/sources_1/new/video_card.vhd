----------------------------------------------------------------------------------
-- Engineer: Ronald Jones
--
-- Create Date: 10/12/2023 03:35:04 PM
-- Design Name: VGA Video Card
-- Module Name: video_card - video_card_arch
-- Project Name: EEL 4744 Final Project
-- Target Devices: Basys3 Development Board
-- Description: This will generate the required signals for a VGA connection
--		It will supply 4-bits per color at the selected screen resolution
--		Screen resolution options are the following:
--			640 x 350
--				VGA 640x350@70 Hz (pixel clock 25.175 MHz)
--			640 x 400
--				VGA 640x400@70 Hz (pixel clock 25.175 MHz)
--			640 x 480
--				VGA 640x480@60 Hz Industry standard (pixel clock 25.175 MHz)
--			800 x 600
--				SVGA 800x600@60 Hz (pixel clock 40.0 MHz)
--
-- Dependencies:
-- 		VGA Types
-- 		VGA Sync Counter
-- 		VGA Memory Mapper
--
-- Revision: 0.1.0
-- Revision 0.1.0 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use WORK.VGA_TYPES.ALL;
use WORK.CONSOLE_UTILS.ALL;


entity video_card is
	port(
		clk_100MHz: in std_logic;
		rst: in std_logic;
		toggle: in std_logic;
		vgaRed: out std_logic_vector(2 downto 0);
		vgaGreen: out std_logic_vector(2 downto 0);
		vgaBlue: out std_logic_vector(1 downto 0);
		hsync: out std_logic;
		vsync: out std_logic
	);
end video_card;

architecture video_card_arch of video_card is
	-------------------------------
	-- Functions
	-------------------------------
	-- Inline If-Then-Else function
	function ite(b: boolean; x, y: integer) return integer is
		begin
			if (b) then
				return x;
			else
				return y;
			end if;
		end function ite;

	-------------------------------
	-- Types
	-------------------------------

	-------------------------------
	-- Constants
	-------------------------------
	-- Using 640x480 resolution, so we can output 320x240 resolution
	-- This is the biggest resolution that fits within 32k of memory
	-- at a byte per pixel, giving up 256 colors
	-- constant RESOLUTION: t_VGA := VGA_640_480_60;
	constant RESOLUTION: t_VGA := SVGA_800_600_60;
	constant Y_DIV: integer := 4;
	constant X_DIV: integer := 4;

	-------------------------------
	-- Components
	-------------------------------
	component clk_wiz_0
		port (
			-- Clock in ports
			clk_in1: std_logic;
			-- Clock out ports
			clk_40MHz: out std_logic;
			clk_25MHz: out std_logic;
			-- Statu and control signals
			resetn: in std_logic
		);
	end component;

	component sync_counter
		generic (
			RESOLUTION: t_VGA := VGA_640_480_60;
			DIR: std_logic := '0'  -- '0' = Horizontal, '1' = Vertical
		);
		port (
			clk: in std_logic;
			rst: in std_logic;
			sync: out std_logic;
			blank: out std_logic;
			addr: out std_logic_vector(15 downto 0);
			carry: out std_logic
		);
	end component;

	component ram
		generic (
			START_ADDRESS: integer := 16#0000#;
			END_ADDRESS: integer := 16#FFFF#;
			INIT_FILE: string := "";
			READ_ONLY: std_logic := '0'  -- 0: RAM, 1: ROM
		);
		port (
			clk: in std_logic;
			rst: in std_logic;
			state: in t_Bus_States;
			addr: in std_logic_vector(15 downto 0);
			data: inout std_logic_vector(7 downto 0)
		);
	end component;

	-------------------------------
	-- Signals
	-------------------------------
	-- Clock Signal
	signal clk_40MHz: std_logic := '0';  -- 40 MHz clock
	signal clk_25MHz: std_logic := '0';  -- 25.17857 MHz clock
	signal clk: std_logic := '0';

	-- Horizontal Sync Counter Signals
	signal hblank: std_logic := '0';
	signal hcarry: std_logic := '1';

	-- Vertical Sync Counter Signals
	signal vblank: std_logic := '0';
	signal vcarry: std_logic := '1';

	-- Address Signals
	signal addr_x: std_logic_vector(15 downto 0) := x"0000";
	signal addr_y: std_logic_vector(15 downto 0) := x"0000";
--	signal temp: std_logic_vector(31 downto 0);

	-- VRAM Signals
	signal ram_addr: std_logic_vector(15 downto 0) := x"0000";
	signal ram_data: std_logic_vector(7 downto 0) := BUS_HIGH_Z;

begin
	-- Configure which VGA clock we are using based upon the selected
	-- resolution
	with RESOLUTION.pixel_freq select
		clk <= clk_25MHz when 25175e3,
			clk_40MHz when 40e6,
			'0' when others;

	-------------------------------
	-- Component Implementations
	-------------------------------
	CLK_WIZ: clk_wiz_0
	port map (
		-- Clock in ports
		clk_in1 => clk_100MHz,
		-- Clock out ports
		clk_40MHz => clk_40MHz,
		clk_25MHz => clk_25MHz,
		-- Statu and control signals
		resetn => rst
	);

	-- Sync Counter for the Hortizontal
	HSYNC_COUNTER: sync_counter
		generic map (
			RESOLUTION => RESOLUTION,
			DIR => '0'  -- Horizontal
		)
		port map (
			clk => clk,
			rst => rst,
			sync => hsync,
			blank => hblank,
			addr => addr_x,
			carry => hcarry
		);

	-- Sync Counter for the Vertical
	VSYNC_COUNTER: sync_counter
		generic map (
			RESOLUTION => RESOLUTION,
			DIR => '1'  -- Vertical
		)
		port map (
			clk => hcarry,
			rst => rst,
			sync => vsync,
			blank => vblank,
			addr => addr_y,
			carry => vcarry
		);

	VRAM_1: ram
		generic map (
			START_ADDRESS => 16#0000#,
			END_ADDRESS => 16#752F#,
			INIT_FILE => "image_3.mif",
			READ_ONLY => '1'
		)
		port map (
			clk => clk,
			rst => rst,
			state => READ,
			addr => ram_addr,
			data => ram_data
		);

	VRAM_2: ram
		generic map (
			START_ADDRESS => 16#7530#,
			END_ADDRESS => 16#EA5F#,
			INIT_FILE => "image_4.mif",
			READ_ONLY => '1'
		)
		port map (
			clk => clk,
			rst => rst,
			state => READ,
			addr => ram_addr,
			data => ram_data
		);

	-------------------------------
	-- Module Implementation
	-------------------------------
	ADDR_PROC: process(addr_y, addr_x)
		variable temp: unsigned(31 downto 0);
	begin
		temp := ((unsigned(addr_y) / Y_DIV) * (RESOLUTION.hsync.active / Y_DIV)) +
			((unsigned(addr_x)) / X_DIV);
		if (toggle = '1') then
			temp := temp + 16#7530#;
		end if;
		ram_addr <= std_logic_vector(temp(15 downto 0));
	end process;
--	temp <= std_logic_vector(
--		((unsigned(addr_y) / Y_DIV) * RESOLUTION.hsync.active) +
--		((unsigned(addr_x)) / X_DIV) +
--		(to_unsigned(ite((toggle = '1'), 16#8000#, 16#0000#), 16)));
--	ram_addr <= temp(15 downto 0);

	vgaRed <= "000" when (vblank = '1' or hblank = '1') else ram_data(7 downto 5);
	vgaGreen <= "000" when (vblank = '1' or hblank = '1') else ram_data(4 downto 2);
	vgaBlue <= "00" when (vblank = '1' or hblank = '1') else ram_data(1 downto 0);

end video_card_arch;

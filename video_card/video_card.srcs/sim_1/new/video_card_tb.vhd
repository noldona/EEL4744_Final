-------------------------------------------------------------------------------
-- Engineer: Ronald Jones
--
-- Create Date: 10/14/2023 02:13:08 PM
-- Design Name: VGA Video Card Test Bench
-- Module Name: video_card_tb - video_card_tb_arch
-- Project Name: Game Console
-- Target Devices: Digilent Cmod S7 Development Board
-- Description: This is a test bench for the VGA Video Card module
--
-- Dependencies:
-- 		VGA Types
-- 		Game Console Utilities
-- 		Test Utilities
-- 		VGA Video Card
-- 		Sync Counter Test Bench
--
-- Revision: 0.1.0
-- Revision 0.1.0 - File Created
-- Additional Comments:
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use WORK.VGA_TYPES.ALL;
use WORK.CONSOLE_UTILS.ALL;
use WORK.TEST_UTILS.ALL;


entity video_card_tb is
	-- port ();
end video_card_tb;

architecture video_card_tb_arch of video_card_tb is
	-------------------------------
	-- Functions
	-------------------------------

	-------------------------------
	-- Types
	-------------------------------

	-------------------------------
	-- Constants
	-------------------------------
	constant CLK_HZ: integer := 25178570;  -- 25.17857 MHz
	constant CLK_PERIOD: time := 1 sec / clk_hz;
	constant RESOLUTION: t_VGA := VGA_640_480_60;
	constant X_DIV: integer := 2;
	constant Y_DIV: integer := 2;

	-------------------------------
	-- Components
	-------------------------------
	component video_card
		port (
			clk_100MHz: in std_logic;
			rst: in std_logic;
			toggle: in std_logic;
			vgaRed: out std_logic_vector(2 downto 0);
			vgaGreen: out std_logic_vector(2 downto 0);
			vgaBlue: out std_logic_vector(1 downto 0);
			hsync: out std_logic;
			vsync: out std_logic
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
	-- Video Card Signals
	signal clk: std_logic := '0';
	signal rst: std_logic := '0';
	signal toggle: std_logic := '0';
	signal vgaRed: std_logic_vector(2 downto 0);
	signal vgaGreen: std_logic_vector(2 downto 0);
	signal vgaBlue: std_logic_vector(1 downto 0);
	signal hsync: std_logic;
	signal vsync: std_logic;

	-- VRAM signals
	signal ram_clk: std_logic := '0';
	signal ram_rst: std_logic := '1';
	signal ram_addr: std_logic_vector(15 downto 0) := x"0000";
	signal ram_data: std_logic_vector(7 downto 0) := BUS_HIGH_Z;

begin
	-------------------------------
	-- Component Implementations
	-------------------------------
	UUT: video_card
		port map(
			clk_100MHz => clk,
			rst => rst,
			toggle => toggle,
			vgaRed => vgaRed,
			vgaGreen => vgaGreen,
			vgaBlue => vgaBlue,
			hsync => hsync,
			vsync => vsync
		);

	VRAM_1: ram
		generic map (
			START_ADDRESS => 16#0000#,
			END_ADDRESS => 16#7FFF#,
			INIT_FILE => "../../sources_1/new/image_1.mif",
			READ_ONLY => '1'
		)
		port map (
			clk => ram_clk,
			rst => ram_rst,
			state => READ,
			addr => ram_addr,
			data => ram_data
		);

	VRAM_2: ram
		generic map (
			START_ADDRESS => 16#8000#,
			END_ADDRESS => 16#FFFF#,
			INIT_FILE => "../../sources_1/new/image_2.mif",
			READ_ONLY => '1'
		)
		port map (
			clk => ram_clk,
			rst => ram_rst,
			state => READ,
			addr => ram_addr,
			data => ram_data
		);

	-------------------------------
	-- Module Implementation
	-------------------------------
	CLK_PROC: process
	begin
		wait for CLK_PERIOD / 2;
		if (clk = '1') then
			clk <= '0';
		else
			clk <= '1';
		end if;
	end process;
	
	VGA_TEST: process
	begin
		wait for CLK_PERIOD * 5;
		rst <= '1';
		wait;
	end process;

--	VGA_TEST: process
--		variable red: std_logic_vector(2 downto 0);
--		variable green: std_logic_vector(2 downto 0);
--		variable blue: std_logic_vector(1 downto 0);
--		variable blank: std_logic;
--		alias UUT_CLK_25MHZ is <<signal UUT.clk_25MHz: std_logic>>;
--	begin
--		-- Test Reset State
--		report "VGA Module: Reset Test: Begin" severity note;
--			-- Wait 5 clock cycles
--			wait for CLK_PERIOD * 5;
--			assert_equals(vgaRed, "000", "VGA Module", "Reset Test", "vgaRed");
--			assert_equals(vgaGreen, "000", "VGA Module", "Reset Test", "vgaGreen");
--			assert_equals(vgaBlue, "00", "VGA Module", "Reset Test", "vgaBlue");
--			assert_equals(hsync, '1', "VGA Module", "Reset Test", "hsync");
--			assert_equals(vsync, '1', "VGA Module", "Reset Test", "vsync");
--			rst <= '1';  -- Take out of reset mode
--			wait until falling_edge(UUT_CLK_25MHZ);  -- Wait 1 clock cycle before changing data
--		report "VGA Module: Reset Test: End" severity note;

--		-- Test Image 2 Display
--		report "VGA Module: Image 2 Test: Begin" severity note;
--			rst <= '0';  -- Reset counters back to 0
--			wait for CLK_PERIOD;  -- Wait 1 clock cycle
--			rst <= '1';  -- Take out of reset mode
--			toggle <= '1';
--			for y in 0 to RESOLUTION.vsync.total loop
--				for x in 0 to RESOLUTION.hsync.total loop
--					-- Set RAM address to current pixel
--					blank := '1' when (x > RESOLUTION.hsync.active or y > RESOLUTION.vsync.active) else '0';
--					ram_addr <= std_logic_vector(to_unsigned((((y / Y_DIV) * RESOLUTION.hsync.active) +
--						(x / X_DIV)  + 16#8000#), 16));
--					ram_clk <= '1';  -- Toggle the RAM clock on to load the value
--					wait until rising_edge(UUT_CLK_25MHZ);
--					-- Get color for the pixel
--					red := "000" when (blank = '1') else ram_data(7 downto 5);
--					green := "000" when (blank = '1') else ram_data(4 downto 2);
--					blue := "00" when (blank = '1') else ram_data(1 downto 0);
--					ram_clk <= '0';  -- Toggle the RAM clock off for next cycle
--					wait until falling_edge(UUT_CLK_25MHZ);  -- Wait 1 clock cycle
--					assert_equals(vgaRed, red, "VGA Module", "Image 2 Test", "vgaRed");
--					assert_equals(vgaGreen, green, "VGA Module", "Image 2 Test", "vgaGreen");
--					assert_equals(vgaBlue, blue, "VGA Module", "Image 2 Test", "vgaBlue");
--				end loop;
--			end loop;
--		report "VGA Module: Image 2 Test: End" severity note;

--		-- Test Image 2 Display
--		report "VGA Module: Image 1 Test: Begin" severity note;
--			rst <= '0';  -- Reset counters back to 0
--			wait for CLK_PERIOD;  -- Wait 1 clock cycle
--			rst <= '1';  -- Take out of reset mode
--			toggle <= '0';
--			for y in 0 to RESOLUTION.vsync.total loop
--				for x in 0 to RESOLUTION.hsync.total loop
--					-- Set RAM address to current pixel
--					blank := '1' when (x > RESOLUTION.hsync.active or y > RESOLUTION.vsync.active) else '0';
--					ram_addr <= std_logic_vector(to_unsigned(((y / Y_DIV) * RESOLUTION.hsync.active) +
--						(x / X_DIV), 16));
--					ram_clk <= '1';  -- Toggle the RAM clock on to load the value
--					wait until rising_edge(UUT_CLK_25MHZ);
--					-- Get color for the pixel
--					red := "000" when (blank = '1') else ram_data(7 downto 5);
--					green := "000" when (blank = '1') else ram_data(4 downto 2);
--					blue := "00" when (blank = '1') else ram_data(1 downto 0);
--					ram_clk <= '0';  -- Toggle the RAM clock off for next cycle
--					wait until falling_edge(UUT_CLK_25MHZ);  -- Wait 1 clock cycle
--					assert_equals(vgaRed, red, "VGA Module", "Image 1 Test", "vgaRed");
--					assert_equals(vgaGreen, green, "VGA Module", "Image 1 Test", "vgaGreen");
--					assert_equals(vgaBlue, blue, "VGA Module", "Image 1 Test", "vgaBlue");
--				end loop;
--			end loop;
--		report "VGA Module: Image 1 Test: End" severity note;

--		wait;
--	end process;

end video_card_tb_arch;

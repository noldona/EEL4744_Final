------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/22/2019 10:04:52 AM
-- Design Name:
-- Module Name: alu - Behavioral
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


entity alu is
	port (
		A : in std_logic_vector(7 downto 0);
		B : in std_logic_vector(7 downto 0);
		ALU_Sel : in std_logic_vector(2 downto 0);
		Result : out std_logic_vector(7 downto 0);
		NZVC : out std_logic_vector(3 downto 0)
	);
end entity;

architecture alu_arch of alu is
begin
	ALU_PROCESS : process (A, B, ALU_Sel)
		variable Sum_uns : unsigned(8 downto 0);
	begin
		if (ALU_Sel = "000") then -- ADDITION
			--  producing the sum
			Sum_uns := unsigned('0' & A) + unsigned('0' & B);
			Result <= std_logic_vector(Sum_uns(7 downto 0));

			-- producing the status flags
			-- Negative flag
			NZVC(3) <= Sum_uns(7);

			-- Zero flag
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			-- Two's complement flag
			if ((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or
					(A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;

			-- Carry flag
			NZVC(0) <= Sum_uns(8);
		else
			Result <= "ZZZZZZZZ";
			NZVC <= "ZZZZ";
		end if;
	end process;

end architecture;

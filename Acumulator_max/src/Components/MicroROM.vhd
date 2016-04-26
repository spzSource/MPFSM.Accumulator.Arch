library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MicroROM is
	port(
		read_enable : in  std_logic;
		address     : in  std_logic_vector(5 downto 0);
		data_output : out std_logic_vector(9 downto 0)
	);
end MicroROM;

architecture MicroROM_Behaviour of MicroROM is
	--
	-- type and sub-types declarations
	--
	subtype instruction_subType is std_logic_vector(9 downto 0);
	type ROM_type is array (0 to 63) of instruction_subType;

	--
	-- Represents the set of instructions as read only (constant) memory.
	--
	constant ROM : ROM_type := (
	"0111" & "000001", -- 000000 | 00 	|LOADI a[a[0]]
	"1000" & "000110", -- 				|STOREI a[a[6]] = accumulator	
	"0100" & "000000", -- 010110 | 22 	|HALT
	
	others => "0100" & "000000"
	);

	signal data : instruction_subType;
begin
	--
	-- Move instruction to the output by specified address
	-- 
	data <= ROM(CONV_INTEGER(address));

	TRISTATE_BUFFERS : process(read_enable, data)
	begin
		if (read_enable = '1') then
			data_output <= data;
		else
			data_output <= (others => 'Z');
		end if;
	end process;

end MicroROM_Behaviour;

		
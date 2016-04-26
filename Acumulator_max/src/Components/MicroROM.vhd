library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use commands.all;

entity MicroROM is
	port(
		read_enable : in  std_logic;
		address     : in  std_logic_vector(5 downto 0);
		data_output : out std_logic_vector(9 downto 0)
	);
end MicroROM;

architecture MicroROM_Behaviour of MicroROM is
	
	subtype ram_address is std_logic_vector(5 downto 0);
	
	--
	-- predefined addresses
	--
	constant OUTER_MAX_ADDR   : ram_address := "000101";
	constant INNER_MAX_ADDR   : ram_address := "000110";
	constant OUTER_INDEX_ADDR : ram_address := "000111";
	constant INNER_INDEX_ADDR : ram_address := "001000";
	
	constant ONE_ADDR         : ram_address := "001001";
	constant ZERO_ADDR        : ram_address := "001010";
	
	constant TEMP_1			  : ram_address := "001011";
	constant TEMP_2			  : ram_address := "001100";

	--
	-- type and sub-types declarations
	--
	subtype instruction_subType is std_logic_vector(9 downto 0);
	type ROM_type is array (0 to 63) of instruction_subType;

	--
	-- Represents the set of instructions as read only (constant) memory.
	--
	constant ROM : ROM_type := (
		-- index initialization						   | ROM_ADDR |
		LOAD_OP  & ZERO_ADDR,						-- |  000000  |    
		STORE_OP & OUTER_INDEX_ADDR,				-- |  000001  |
		STORE_OP & INNER_INDEX_ADDR,				-- |  000010  |
		
		-- check exit condition for outer loop
		LOAD_OP  & OUTER_MAX_ADDR,					-- |  000011  |
		SUB_OP   & OUTER_INDEX_ADDR,				-- |  000100  |
		JZ_OP    & "000000", -- { end outer loop }	-- |  000101  |
		
		-- check exit condition for inner loop
		LOAD_OP  & OUTER_INDEX_ADDR,				-- |  000110  |
		ADD_OP   & ONE_ADDR,						-- |  000111  |
		STORE_OP & INNER_INDEX_ADDR,				-- |  000111  |
		LOAD_OP  & INNER_MAX_ADDR,					-- |  001000  |
		SUB_OP   & INNER_INDEX_ADDR,				-- |  001001  |
		JZ_OP    & "000000", -- {end inner loop}	-- |  001010  |
		
		-- compare two values, retrieved by current indexes
		LOADI_OP & INNER_INDEX_ADDR,
		STORE_OP & TEMP_1,
		LOADI_OP & OUTER_INDEX_ADDR,
		STORE_OP & TEMP_2,
		SUB_OP   & TEMP_1,
		JNSB_OP  & "000000", -- {skip swap}		
		
		-- swap two items
		
		others => (instruction_subType'range => '0')
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

		
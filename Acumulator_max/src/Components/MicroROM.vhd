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
		LOAD_OP   & ZERO_ADDR,						-- |  000000  |   0
		STORE_OP  & OUTER_INDEX_ADDR,				-- |  000001  |	  1
		STORE_OP  & INNER_INDEX_ADDR,				-- |  000010  |	  2
		
		-- check exit condition for outer loop
		LOAD_OP   & OUTER_MAX_ADDR,					-- |  000011  |	  3
		SUB_OP    & OUTER_INDEX_ADDR,				-- |  000100  |	  4
		JZ_OP     & "100100", -- { end outer loop }	-- |  000101  |	  5
		
		-- check exit condition for inner loop
		LOAD_OP   & OUTER_INDEX_ADDR,				-- |  000110  |	  6
		ADD_OP    & ONE_ADDR,						-- |  000111  |	  7
		STORE_OP  & INNER_INDEX_ADDR,				-- |  001000  |	  8
		LOAD_OP   & INNER_MAX_ADDR,					-- |  001001  |	  9
		SUB_OP    & INNER_INDEX_ADDR,				-- |  001010  |	  10
		JZ_OP     & "011111", -- {end inner loop}	-- |  001011  |	  11
		
		-- compare two values, retrieved by current indexes
		LOADI_OP  & OUTER_INDEX_ADDR,				-- |  001100  |	  12
		STORE_OP  & TEMP_1,							-- |  001101  |	  13
		LOADI_OP  & INNER_INDEX_ADDR,				-- |  001110  |	  14
		STORE_OP  & TEMP_2, -- {j}					-- |  001111  |	  15
		SUB_OP    & TEMP_1, -- {i}					-- |  010000  |	  16
		JNSB_OP   & "010110", -- {skip swap}		-- |  010001  |	  17	
		
		-- swap two items
		LOAD_OP   & TEMP_1, 						-- |  010010  |	  18
		STORE_OP  & TEMP_2,				   			-- |  010011  |	  19
		LOADI_OP  & INNER_INDEX_ADDR,	 			-- |  010100  |	  20
		STORE_OP  & TEMP_1,							-- |  010101  |	  21
		
		LOAD_OP   & TEMP_1,							-- |  010110  |	  22
		STOREI_OP & OUTER_INDEX_ADDR,				-- |  010111  |	  23
		LOAD_OP   & TEMP_2,							-- |  011000  |	  24
		STOREI_OP & INNER_INDEX_ADDR, 				-- |  011001  |	  25
		
		LOAD_OP   & INNER_INDEX_ADDR,				-- |  011010  |	  26
		ADD_OP    & ONE_ADDR,						-- |  011011  |	  27
		STORE_OP  & INNER_INDEX_ADDR,				-- |  011100  |	  28
		LOAD_OP   & ZERO_ADDR,						-- |  011101  |	  29
		JZ_OP     & "001001",						-- |  011110  |	  30
		
		LOAD_OP   & OUTER_INDEX_ADDR,				-- |  011111  |	  31
		ADD_OP    & ONE_ADDR,						-- |  100000  |	  32
		STORE_OP  & OUTER_INDEX_ADDR,				-- |  100001  |	  33
		LOAD_OP   & ZERO_ADDR,						-- |  100010  |	  34
		JZ_OP     & "000011",						-- |  100011  |	  35
		
		others => HALT_OP & "000000"
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

		
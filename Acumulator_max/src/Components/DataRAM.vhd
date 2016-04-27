library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--
-- Represents random access memory
-- 
-- read_write: 1 - read, 0 - write
--
entity DataRAM is
	port(
		read_write  : in  std_logic;
		address     : in  std_logic_vector(5 downto 0);
		data_input  : in  std_logic_vector(7 downto 0);
		data_output : out std_logic_vector(7 downto 0)
	);
end entity DataRAM;

architecture DataRAM_Bevioural of DataRAM is
	subtype byte is std_logic_vector(7 downto 0);
	type RAM_t is array (0 to 64) of byte;

	--
	-- Initial state for memory
	--
	signal RAM : RAM_t := (
		"00000101",                     -- 5	a[0]  
		"00000011",                     -- 3	a[1]
		"00000001",                     -- 1	a[2]
		"00000110",                     -- 6	a[3]

		"00000000",                     -- 0	a[4]  [-]
		"00000011",                     -- 3    a[5]  outer loop: max index value
		"00000100",                     -- 4	a[6]  inner loop: max index value

		"00000000",                     -- 0	a[7]  outer loop: current index
		"00000000",                     -- 0	a[8]  inner loop: current index    

		"00000001",                     -- 1	a[9]  constant one = 1	  
		"00000000",                     -- 0    a[10] constant zero = 0

		"00000000",                     -- 0    a[11] reserved cell (temp 1)
		"00000000",                     -- 0   	a[12] reserved cell (temp 2) 

		others => "00000000"
	);

	signal data_in  : byte;
	signal data_out : byte;
begin
	--
	-- describes write-behaviour for RAM
	--
	data_in <= data_input;
	WRITE : process(read_write, address, data_in)
	begin
		if (read_write = '0') then
			RAM(CONV_INTEGER(address)) <= data_in;
		end if;
	end process;

	--
	-- read the data by specific address
	--
	data_out <= RAM(CONV_INTEGER(address));

	--
	-- describes read-behaviour for RAM
	--
	TRISTATE_BUFFERS : process(read_write, data_out)
	begin
		if (read_write = '1') then
			data_output <= data_out;
		else
			data_output <= (others => 'Z');
		end if;
	end process;

end architecture DataRAM_Bevioural;


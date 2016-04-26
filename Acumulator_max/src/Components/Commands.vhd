library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package commands is
	subtype op_code is std_logic_vector(3 downto 0);

	constant LOAD_OP   : op_code := "0000";
	constant STORE_OP  : op_code := "0001";
	constant ADD_OP    : op_code := "0010";
	constant SUB_OP    : op_code := "0011";
	constant HALT_OP   : op_code := "0100";
	constant JZ_OP     : op_code := "0101";
	constant JNSB_OP   : op_code := "0110";
	constant LOADI_OP  : op_code := "0111";
	constant STOREI_OP : op_code := "1000";
end commands;
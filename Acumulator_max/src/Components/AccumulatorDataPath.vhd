library ieee;

use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity AccumulatorDataPath is
	port(
		enabled              : in  std_logic;
		operation_code       : in  std_logic_vector(3 downto 0);
		operand              : in  std_logic_vector(7 downto 0);
		result               : out std_logic_vector(7 downto 0);
		zero_flag            : out std_logic;
		significant_bit_flag : out std_logic
	);
end entity AccumulatorDataPath;

architecture AccumulatorDataPath_Behavioural of AccumulatorDataPath is
	signal accumulator                      : std_logic_vector(7 downto 0);
	signal add_result                       : std_logic_vector(7 downto 0);
	signal sub_result                       : std_logic_vector(7 downto 0);
	signal accumulator_zero_flag            : std_logic;
	signal accumulator_significant_bit_flag : std_logic;

	--
	-- operation codes
	--
	constant LOAD  : std_logic_vector(3 downto 0) := "0000"; 
	constant LOADI : std_logic_vector(3 downto 0) := "0111";
	constant ADD   : std_logic_vector(3 downto 0) := "0010";
	constant MUL   : std_logic_vector(3 downto 0) := "0011";

begin
	--
	-- represents 8-bit adder
	--
	add_result <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(accumulator) + CONV_INTEGER(operand), 8);

	--
	-- represents 8-bit subtraction
	--
	sub_result <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(accumulator) - CONV_INTEGER(operand), 8);

	--
	-- synchronous register-accumulator
	--
	REGISTER_ACCUMULATOR : process(enabled, operation_code, operand, add_result, sub_result)
	begin
		if (rising_edge(enabled)) then
			case operation_code is	
				when LOADI  => accumulator <= operand;
				when LOAD   => accumulator <= operand;
				when ADD    => accumulator <= add_result;
				when MUL    => accumulator <= sub_result;
				when others => null;
			end case;
		end if;
	end process;

	FLAGS_PROCESS : process(accumulator)
	begin
		if accumulator = (accumulator'range => '0') then
			accumulator_zero_flag <= '1';
		else
			accumulator_zero_flag <= '0';
		end if;

		if accumulator(7) = '1' then
			accumulator_significant_bit_flag <= '1';
		else
			accumulator_significant_bit_flag <= '0';
		end if;
	end process;

	result               <= accumulator;
	zero_flag            <= accumulator_zero_flag;
	significant_bit_flag <= accumulator_significant_bit_flag;

end architecture AccumulatorDataPath_Behavioural;


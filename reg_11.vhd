library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_11 is
	port ( Clk : in std_logic;
		reset: in std_logic;
		Shift_In : in std_logic;
		Shift_En : in std_logic;
		Shift_Out : out std_logic;
		Data_Out : out std_logic_vector(10 downto 0));
end reg_11;

architecture Behavioral of reg_11 is
	signal reg_value: std_logic_vector (10 downto 0);
begin
operate_reg : process (Clk, Reset,  Shift_En, Shift_In)
	begin
		if (Reset = '1') then
			reg_value(0) <= '0'; -- set register to 0
			reg_value(1) <= '0';
			reg_value(2) <= '0';
			reg_value(3) <= '0';
			reg_value(4) <= '0';
			reg_value(5) <= '0';
			reg_value(6) <= '0';
			reg_value(7) <= '0';
			reg_value(8) <= '0';
			reg_value(9) <= '0';
			reg_value(10) <= '0';
		elsif (rising_edge(Clk)) then
			if (Shift_En = '1') then
				reg_value <= Shift_In & reg_value(10 downto 1);
			else
				reg_value <= reg_value;
			end if;
		end if;
	end process;
	Data_Out <= reg_value;
	Shift_Out <= reg_value(0);
end behavioral;
		
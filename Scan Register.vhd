entity  Scan_Register is
	port (  PS2_Data : in std_logic;
			Clk : in std_logic;
			Shift_En : in std_logic;
			Reg_A : out std_logic(7 downto 0);
			Reg_B : out std_logic(7 downto 0));
end Scan_Register;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mapper is
	port (  clk: in std_logic;
			Reg_Ain : in std_logic_vector(10 downto 0);
			Reg_Bin : in std_logic_vector(10 downto 0);
			U : out std_logic;
			D : out std_logic;
			L : out std_logic;
			R : out std_logic;
			M: out std_logic;
			At : out std_logic;
			Bl : out std_logic;
			linkDir: out std_logic_vector(1 downto 0));
end mapper;
architecture Behavioral of mapper is
signal A ,B: std_logic_vector(7 downto 0);
signal dir: std_logic_vector(1 downto 0);
begin
	A <= Reg_Ain(8 downto 1);
	B <= Reg_Bin(8 downto 1);

	
	process(clk)
		variable dir2: std_logic_vector(1 downto 0);
	begin
		dir2:=dir;
		linkDir <= dir2;
		if(rising_edge(clk))then
			if (B = "11110000") then
				U <= '0';
				D <= '0';
				L <= '0';
				R <= '0';
				M <= '0';
				At <= '0';
				dir <= dir2;
			else
				case A is
					when "00011101"=> -- W
						U <= '1';
						D <= '0';
						L <= '0';
						R <= '0';
						M <= '1';
						At <= '0';
						dir <= "00";

				
					when "00011100"=> -- A
						U <= '0';
						D <= '0';
						L <= '1';
						R <= '0';
						M <= '1';
						At <= '0';
						dir <= "10";

					when "00100011"=> -- D
						U <= '0';
						D <= '0';
						L <= '0';
						R <= '1';
						M <= '1';
						At <= '0';
						dir <= "11";
					when "00011011"=> -- S
						U <= '0';
						D <= '1';
						L <= '0';
						R <= '0';
						M <= '1';
						At <= '0';
						dir <= "01";

						--------------------------
					when "00010100"=>	
						U <= '0';
						D <= '0';
						L <= '0';
						R <= '0';
						M <= '0';
						At <= '1';
						dir <= dir2;
						--------------------------
					when others=>
						U <= '0';
						D <= '0';
						L <= '0';
						R <= '0';
						M <= '0';
						At <= '0';
						dir <= dir2;
				end case;

			end if;	
		end if;	
			
			
			
--		elsif(A = "00010100")then
--			U <= '0';
--			D <= '0';
--			L <= '0';
--			R <= '0';
--			M <= '0';
--			At <= '1';
--			Bl <= '0';
--		elsif(A = "00010010")then
--			U <= '0';
--			D <= '0';
--			L <= '0';
--			R <= '0';
--			M <= '0';
--			At <= '1';
--			Bl <= '1';
--		else 
--			U <= '0';
--			D <= '0';
--			L <= '0';
--			R <= '0';
--			M <= '0';
--			At <= '0';
--		end if;
		
--		if(A = "00010100")then
--			At <= '1';
--			Bl <= '0';
--		elsif(A = "00010010")then
--			At <= '0';
--			Bl <= '1';
--		else
--			At <= '0';
--			Bl <= '0';
--		end if;
	
	end process; 
	Bl <= '0';	
		
end Behavioral;
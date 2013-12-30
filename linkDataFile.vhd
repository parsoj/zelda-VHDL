library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.math_real.ALL;

entity linkDataFile is
	Port(	clk: in std_logic;
			reset: in std_logic;
			keysU,keysD,keysL,keysR: in std_logic;
			M: in std_logic;
			Attack: in std_logic;
			lnkDir: in std_logic_vector(1 downto 0);
			Health: in std_logic_vector(1 downto 0);
			Blck: in std_logic;
			linkInfo: out std_logic_vector(6 downto 0));
end linkDataFile;

architecture Behavioral of linkDataFile is 
--	signal dirCollector: std_logic_vector(3 downto 0);
--	signal linkDir: std_logic_vector(1 downto 0);
--
--	signal clkdiv: std_logic;
--set_input_delay 1.2 -clock clk -min [get_ports keys*];
begin
--	dirCollector <= U & D & L & R;
--	
--
--	findDir: process(clk)
--	begin
--		if(rising_edge(clk))then
--			case dirCollector is
--				
--				when "1000"=>
--					linkDir <= "00";
--				when "0100"=>
--					linkDir <= "01";
--				when "0010"=>
--					linkDir <= "10";
--				when "0001"=>
--					linkDir <= "11";
--				when others=>
--					linkDir <= linkDir;
--					
--				end case;
--
--				
--		end if;
--	end process;

	
	
	linkInfo(1 downto 0) <= lnkDir;
	linkInfo(3) <= M;
	linkInfo(2) <= Attack;
	linkInfo(5 downto 4) <= Health;
	linkInfo(6) <=Blck;	
end Behavioral;
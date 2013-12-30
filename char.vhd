library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
entity Game is
   Port ( Reset : in std_logic;
        frame_clk : in std_logic;
        Link_dir: in std_logic_vector(1 downto 0);
        U : in std_logic;
        D : in std_logic;
        L : in std_logic;
        R : in std_logic;
        atk : in std_logic;
        Link : out std_logic_vector(25 downto 0);
        En1 : out std_logic_vector(24 downto 0);
        En2 : out std_logic_vector(24 downto 0);
        En3 : out std_logic_vector(25 downto 0);
        maps : out std_logic_vector(1 downto 0)
        
        
   --     testOut: out std_logic_vector(15 downto 0)
        
        );
end Game;

--Link 
--dir(2), xpos(10), ypos(10),atk(1), health(3)
--Enemy 1
--xpos(10), ypos(10), type(3), health(2)
architecture Behavioral of Game is

type cntrl_state is (A,B,C,E);
signal state, next_state:cntrl_state;

signal Link_atk : std_logic;
signal Link_X_pos, Link_X_motion, Link_Y_pos, Link_Y_motion : std_logic_vector(9 downto 0);

signal Map1En1_X_pos, Map1En1_X_motion, Map1En1_Y_pos, Map1En1_Y_motion : std_logic_vector(9 downto 0);
signal Map1En2_X_pos, Map1En2_X_motion, Map1En2_Y_pos, Map1En2_Y_motion : std_logic_vector(9 downto 0);
signal Map1En3_X_pos, Map1En3_X_motion, Map1En3_Y_pos, Map1En3_Y_motion : std_logic_vector(9 downto 0);

signal Map2En1_X_pos, Map2En1_X_motion, Map2En1_Y_pos, Map2En1_Y_motion : std_logic_vector(9 downto 0);
signal Map2En2_X_pos, Map2En2_X_motion, Map2En2_Y_pos, Map2En2_Y_motion : std_logic_vector(9 downto 0);
signal Map2En3_X_pos, Map2En3_X_motion, Map2En3_Y_pos, Map2En3_Y_motion : std_logic_vector(9 downto 0);

signal Map3En1_X_pos, Map3En1_X_motion, Map3En1_Y_pos, Map3En1_Y_motion : std_logic_vector(9 downto 0);
signal Map3En2_X_pos, Map3En2_X_motion, Map3En2_Y_pos, Map3En2_Y_motion : std_logic_vector(9 downto 0);
signal Map3En3_X_pos, Map3En3_X_motion, Map3En3_Y_pos, Map3En3_Y_motion : std_logic_vector(9 downto 0);

signal Map4En1_X_pos, Map4En1_X_motion, Map4En1_Y_pos, Map4En1_Y_motion : std_logic_vector(9 downto 0);
signal Map4En2_X_pos, Map4En2_X_motion, Map4En2_Y_pos, Map4En2_Y_motion : std_logic_vector(9 downto 0);
signal Map4En3_X_pos, Map4En3_X_motion, Map4En3_Y_pos, Map4En3_Y_motion : std_logic_vector(9 downto 0);

signal Link_Health: std_logic_vector(2 downto 0);

signal Map1En1_Health, Map1En2_Health, Map1En3_Health : std_logic_vector(1 downto 0);
signal Map2En1_Health, Map2En2_Health, Map2En3_Health : std_logic_vector(1 downto 0);
signal Map3En1_Health, Map3En2_Health, Map3En3_Health : std_logic_vector(1 downto 0);
signal Map4En1_Health, Map4En2_Health, Map4En3_Health : std_logic_vector(1 downto 0);

signal Link_Size, damage : std_logic_vector(9 downto 0);

--signal frame_clk_div : std_logic_vector(5 downto 0);


constant Link_X_Center : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(320, 10);  --Center position on the X axis
constant Link_Y_Center : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(240, 10);  --Center position on the Y axis

constant Link_X_Min    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);  --Leftmost point on the X axis
constant Link_X_Max    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(639, 10);  --Rightmost point on the X axis
constant Link_Y_Min    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);   --Topmost point on the Y axis
constant Link_Y_Max    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(479, 10);  --Bottommost point on the Y axis                              
constant Link_X_Step   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(1, 10);  --Step size on the X axis
constant Link_Y_Step   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(1, 10);  --Step size on the Y axis

--constant Map1En1_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map1En1_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map1En2_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map1En2_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map1En3_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map1En3_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--
--constant Map2En1_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map2En1_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map2En2_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map2En2_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map2En3_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map2En3_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--
--constant Map3En1_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map3En1_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map3En2_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map3En2_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map3En3_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map3En3_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--
--constant Map4En1_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map4En1_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map4En2_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map4En2_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map4En3_X     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
--constant Map4En3_Y     : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);
begin
  Link_Size <= CONV_STD_LOGIC_VECTOR(32, 10); -- assigns the value 4 as a 10-digit binary number, ie "0000000100"
--  damage <= CONV_STD_LOGIC_VECTOR(27, 10);
-------------------------------------------------








--  process(frame_clk, reset)
--  begin
--    if (reset = '1') then
--      frame_clk_div <= "000000";
--    elsif (rising_edge(frame_clk)) then
--      frame_clk_div <= frame_clk_div + '1';
--    end if;
--  end process;
--	control_reg: process(Reset, frame_clk)
--	begin
--		if(Reset = '1') then
--            state <= A;
--            
--            
--		elsif (rising_edge(frame_clk)) then
--			state <= next_state;
--		end if;
--	end process;
--



	get_next_state : process (frame_clk, Reset, U,D,L,R,Link_Size)
	begin
		
		
	
			--		case state is
	--			when A => 
	--			
				
				
					if(Reset = '1') then
			
						Link_Y_Motion <= "0000000000";
						Link_X_Motion <= "0000000000";
						Link_Y_Pos <= Link_Y_Center;
						Link_X_pos <= Link_X_Center;
--						Link_Health <= "111";
--						Map1En1_X_Pos <= Map1En1_X;
--						Map1En1_Y_Pos <= Map1En1_Y;
--						Map1En1_Health<= "11";
--						Map1En2_X_Pos <= Map1En2_X;
--						Map1En2_Y_Pos <= Map1En2_Y;
--						Map1En2_Health<= "11";
--						Map1En3_X_Pos <= Map1En3_X;
--						Map1En3_Y_Pos <= Map1En3_Y;
--						Map1En3_Health<= "11";
--						
--						Map2En1_X_Pos <= Map3En1_X;
--						Map2En1_Y_Pos <= Map3En1_Y;
--						Map2En1_Health<= "11";
--						Map2En2_X_Pos <= Map3En2_X;
--						Map2En2_Y_Pos <= Map3En2_Y;
--						Map2En2_Health<= "11";
--						Map2En3_X_Pos <= Map3En3_X;
--						Map2En3_Y_Pos <= Map3En3_Y;
--						Map2En3_Health<= "11";
--						
--						Map3En1_X_Pos <= Map3En1_X;
--						Map3En1_Y_Pos <= Map3En1_Y;
--						Map3En1_Health<= "11";
--						Map3En2_X_Pos <= Map3En2_X;
--						Map3En2_Y_Pos <= Map3En2_Y;
--						Map3En2_Health<= "11";
--						Map3En3_X_Pos <= Map3En3_X;
--						Map3En3_Y_Pos <= Map3En3_Y;
--						Map3En3_Health<= "11";
--						
--						Map4En1_X_Pos <= Map4En1_X;
--						Map4En1_Y_Pos <= Map4En1_Y;
--						Map4En1_Health<= "11";
--						Map4En2_X_Pos <= Map4En2_X;
--						Map4En2_Y_Pos <= Map4En2_Y;
--						Map4En2_Health<= "11";
--						Map4En3_X_Pos <= Map4En3_X;
--						Map4En3_Y_Pos <= Map4En3_Y;
--						Map4En3_Health<= "11";
--						testout <= "0000000000000000";
				elsif(rising_edge(frame_clk))then
					
					if(Link_Y_Pos + Link_Size >= Link_Y_Max) then 
						Link_Y_Motion <= not(Link_Y_Step) + '1';
						Link_X_Motion <= "0000000000"; 
--						Link_Y_Pos <= Link_Y_Min;
--						next_state <= C;
--						testout <= "0000000000000001";
						
					elsif(Link_Y_Pos - Link_Size <= Link_Y_Min) then  
						Link_Y_Motion <= Link_Y_Step; 
						Link_X_Motion <= "0000000000"; 
						
					elsif (Link_X_Pos + Link_Size >= Link_X_Max) then 
						Link_Y_Motion <= not(Link_X_Step) + '1'; 
						Link_X_Motion <= "0000000000"; 
--						next_state <= B;
--						Link_X_Pos <= Link_X_Min;
--						testout <= "0000000000000010";
						
					elsif(Link_X_Pos - Link_Size <= Link_X_Min) then 
						Link_Y_Motion <= Link_X_Step; 
						Link_X_Motion <= "0000000000"; 
--						testout <= "0000000000000011";
						
					elsif(U = '1') then
						Link_Y_Motion <= not(Link_Y_Step)+ '1';
						Link_X_Motion <= "0000000000";
--						if(( Link_Y_pos - Map1En1_Y_pos <= Link_Size AND Link_Y_pos - Map1En1_Y_pos > 0 AND ((Link_X_pos - Map1En1_X_pos <= Link_Size 
--						   AND Link_X_pos - Map1En1_X_pos > 0) OR (Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0) )) OR 
--						   ( Link_Y_pos - Map1En2_Y_pos <= Link_Size AND Link_Y_pos - Map1En2_Y_pos > 0 AND ((Link_X_pos - Map1En2_X_pos <= Link_Size
--							AND Link_X_pos - Map1En2_X_pos > 0) OR (Map1En2_X_pos-Link_X_pos <= Link_Size AND Map1En2_X_pos-Link_X_pos > 0) )) OR 
--						   ( Link_Y_pos - Map1En3_Y_pos <= Link_Size AND Link_Y_pos - Map1En3_Y_pos > 0 AND ((Link_X_pos - Map1En3_X_pos <= Link_Size
--							AND Link_X_pos - Map1En3_X_pos > 0) OR (Map1En3_X_pos-Link_X_pos <= Link_Size AND Map1En3_X_pos-Link_X_pos > 0) )) ) then
--							Link_Y_Motion <= Link_Y_Step+ "0000000100";
--							Link_Health <= Link_Health - '1';
--						end if;
					
			--			testout <= "0000000000000100";
					elsif(D = '1') then
						Link_Y_Motion <= Link_Y_Step;
						Link_X_Motion <= "0000000000";  
--						if(( Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map1En1_X_pos <= Link_Size 
--						   AND Link_X_pos - Map1En1_X_pos > 0) OR (Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0) )) OR 
--						   ( Map1En2_Y_pos-Link_Y_pos <= Link_Size AND Map1En2_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map1En2_X_pos <= Link_Size
--							AND Link_X_pos - Map1En2_X_pos > 0) OR (Map1En2_X_pos-Link_X_pos <= Link_Size AND Map1En2_X_pos-Link_X_pos > 0) )) OR 
--						   (Map1En3_Y_pos-Link_Y_pos <= Link_Size AND Map1En3_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map1En3_X_pos <= Link_Size
--							AND Link_X_pos - Map1En3_X_pos > 0) OR (Map1En3_X_pos-Link_X_pos <= Link_Size AND Map1En3_X_pos-Link_X_pos > 0) )) ) then
--							Link_Y_Motion <= not(Link_Y_Step+ "0000000100")+ '1';
--							Link_Health <= Link_Health - '1';						
--						end if;
					
						
--						testout <= "0000000000000101";
					elsif(R = '1') then
						Link_X_Motion <= Link_X_Step;
						Link_Y_Motion <= "0000000000";
--						if(( Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map1En1_Y_pos <= Link_Size 
--						   AND Link_Y_pos - Map1En1_Y_pos > 0) OR (Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0) )) OR 
--						   ( Map1En2_X_pos-Link_X_pos <= Link_Size AND Map1En2_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map1En2_Y_pos <= Link_Size
--							AND Link_Y_pos - Map1En2_Y_pos > 0) OR (Map1En2_Y_pos-Link_Y_pos <= Link_Size AND Map1En2_Y_pos-Link_Y_pos > 0) )) OR 
--						   (Map1En3_X_pos-Link_X_pos <= Link_Size AND Map1En3_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map1En3_Y_pos <= Link_Size
--							AND Link_Y_pos - Map1En3_Y_pos > 0) OR (Map1En3_Y_pos-Link_Y_pos <= Link_Size AND Map1En3_Y_pos-Link_Y_pos > 0) )) ) then
--						   Link_X_Motion <= not(Link_X_Step+ "0000000100") + '1';
--							Link_Health <= Link_Health - '1';					   
--						end if;
--					
						
					elsif(L = '1') then
						Link_X_Motion <= not(Link_X_Step) + '1';
						Link_Y_Motion <= "0000000000";
--						if(( Link_X_pos - Map1En1_X_pos <= Link_Size AND Link_X_pos - Map1En1_X_pos > 0 AND ((Link_Y_pos - Map1En1_Y_pos <= Link_Size 
--						   AND Link_Y_pos - Map1En1_Y_pos > 0) OR (Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0) )) OR 
--						   ( Link_X_pos - Map1En2_X_pos <= Link_Size AND Link_X_pos - Map1En2_X_pos > 0 AND ((Link_Y_pos - Map1En2_Y_pos <= Link_Size
--							AND Link_Y_pos - Map1En2_Y_pos > 0) OR (Map1En2_Y_pos-Link_Y_pos <= Link_Size AND Map1En2_Y_pos-Link_Y_pos > 0) )) OR 
--						   ( Link_X_pos - Map1En3_X_pos <= Link_Size AND Link_X_pos - Map1En3_X_pos > 0 AND ((Link_Y_pos - Map1En3_Y_pos <= Link_Size
--							AND Link_Y_pos - Map1En3_Y_pos > 0) OR (Map1En3_Y_pos-Link_Y_pos <= Link_Size AND Map1En3_Y_pos-Link_Y_pos > 0) )) ) then
--						   Link_X_Motion <= Link_X_Step+ "0000000100";
--							Link_Health <= Link_Health - '1';					   
--						end if;
--						
						
--						testout <= "0000000000000110";
					else 
						Link_Y_Motion <= "0000000000"; -- Ball is somewhere in the middle, don't bounce, just keep moving
						Link_X_Motion <= "0000000000"; -- Ball is somewhere in the middle, don't bounce, just keep moving
	--					testout <= "0000000000000111";
						
					end if;
					
					
					
					
					
	--			    if(atk = '1') then
	--			    	if(Link_dir = "00") then
	--			    		if(Link_Y_pos - Map1En1_Y_pos <= damage AND Link_Y_pos - Map1En1_Y_pos > 0 AND ((Link_X_pos - Map1En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map1En1_X_pos > 0) OR (Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0) ) AND
	--			    		   Map1En1_Health > 0) then
	--			    			Map1En1_Health <= Map1En1_Health - '1';
	--			    		elsif(Link_Y_pos - Map1En2_Y_pos <= damage AND Link_Y_pos - Map1En2_Y_pos > 0 AND ((Link_X_pos - Map1En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map1En1_X_pos > 0) OR (Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map1En2_Health > 0) then
	-- 			    			Map1En2_Health <= Map1En2_Health - '1';
	--			    		elsif(Link_Y_pos - Map1En3_Y_pos <= damage AND Link_Y_pos - Map1En3_Y_pos > 0 AND ((Link_X_pos - Map1En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map1En1_X_pos > 0) OR (Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map1En3_Health > 0) then
	--			    			Map1En3_Health <= Map1En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "01") then
	--			    		if(Map1En1_Y_pos - Link_Y_pos <= damage AND Map1En1_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map1En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map1En1_X_pos > 0) OR (Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map1En1_Health > 0) then
	--			    			Map1En1_Health <= Map1En1_Health - '1';
	--			    		elsif(Map1En2_Y_pos - Link_Y_pos <= damage AND Map1En2_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map1En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map1En1_X_pos > 0) OR (Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0)) AND 
	--				    		Map1En2_Health > 0) then
	-- 			    			Map1En2_Health <= Map1En2_Health - '1';
	--			    		elsif(Map1En3_Y_pos - Link_Y_pos <= damage AND Map1En3_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map1En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map1En1_X_pos > 0) OR (Map1En1_X_pos-Link_X_pos <= Link_Size AND Map1En1_X_pos-Link_X_pos > 0)) AND
	--			    			Map1En3_Health > 0) then
	--			    			Map1En3_Health <= Map1En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "11") then
	--			    		if(Map1En1_X_pos - Link_X_pos <= damage AND Map1En1_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map1En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map1En1_Y_pos > 0) OR (Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0) )  AND
	--				    		Map1En1_Health > 0) then
	--			    			Map1En1_Health <= Map1En1_Health - '1';
	--			    		elsif(Map1En2_X_pos - Link_X_pos <= damage AND Map1En2_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map1En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map1En1_Y_pos > 0) OR (Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0) ) AND
	--				    		Map1En2_Health > 0) then
	-- 			    			Map1En2_Health <= Map1En2_Health - '1';
	--			    		elsif(Map1En3_X_pos - Link_X_pos <= damage AND Map1En3_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map1En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map1En1_Y_pos > 0) OR (Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0) ) AND
	--			    			Map1En3_Health > 0) then
	--			    			Map1En3_Health <= Map1En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "10") then
	--			    		if(Map1En1_X_pos - Link_X_pos <= damage AND Map1En1_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map1En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map1En1_Y_pos > 0) OR (Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0) ) AND
	--				    		Map1En1_Health > 0) then
	--			    			Map1En1_Health <= Map1En1_Health - '1';
	--			    		elsif(Map1En2_X_pos - Link_X_pos <= damage AND Map1En2_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map1En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map1En1_Y_pos > 0) OR (Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0) ) AND 
	--				    		Map1En2_Health > 0) then
	-- 			    			Map1En2_Health <= Map1En2_Health - '1';
	--			    		elsif(Map1En3_X_pos - Link_X_pos <= damage AND Map1En3_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map1En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map1En1_Y_pos > 0) OR (Map1En1_Y_pos-Link_Y_pos <= Link_Size AND Map1En1_Y_pos-Link_Y_pos > 0) ) AND
	--			    			Map1En3_Health > 0) then
	--			    			Map1En3_Health <= Map1En3_Health - '1';
	--			    		end if;
	--			    	end if;
	--			    	Link_atk <= '1';
	--			    end if;
	--			    Link_X_pos<= Link_X_Motion + Link_X_pos;
	--				Link_Y_pos<= Link_Y_Motion + Link_Y_pos;
	--			when B =>
	--				if   (Link_Y_Pos + Link_Size >= Link_Y_Max) then 
	--      		  		Link_Y_Motion <= "0000000000";
	--			        Link_X_Motion <= "0000000000"; 
	--			        next_state <= E;
	--			        Link_Y_Pos <= Link_Y_Min;
	--		        elsif(Link_Y_Pos - Link_Size <= Link_Y_Min) then  
	--					Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000"; 
	--			    elsif (Link_X_Pos + Link_Size >= Link_X_Max) then 
	--			        Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000"; 
	--		        elsif(Link_X_Pos - Link_Size <= Link_X_Min) then 
	--			        Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000";
	--			        next_state <= A;
	--			        Link_X_Pos <= Link_X_Max;
	--				elsif(U = '1') then
	--					Link_Y_Motion <= not(Link_Y_Step)+ '1';
	--					Link_X_Motion <= "0000000000";
	--					if(( Link_Y_pos - Map2En1_Y_pos <= Link_Size AND Link_Y_pos - Map2En1_Y_pos > 0 AND ((Link_X_pos - Map2En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map2En1_X_pos > 0) OR (Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Link_Y_pos - Map2En2_Y_pos <= Link_Size AND Link_Y_pos - Map2En2_Y_pos > 0 AND ((Link_X_pos - Map2En2_X_pos <= Link_Size
	--						AND Link_X_pos - Map2En2_X_pos > 0) OR (Map2En2_X_pos-Link_X_pos <= Link_Size AND Map2En2_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Link_Y_pos - Map2En3_Y_pos <= Link_Size AND Link_Y_pos - Map2En3_Y_pos > 0 AND ((Link_X_pos - Map2En3_X_pos <= Link_Size
	--						AND Link_X_pos - Map2En3_X_pos > 0) OR (Map2En3_X_pos-Link_X_pos <= Link_Size AND Map2En3_X_pos-Link_X_pos > 0) )) ) then
	--						Link_Y_Motion <= Link_Y_Step+ "0000000100";
	--						Link_Health <= Link_Health - '1';
	--					end if;
	--					
	--				elsif(D = '1') then
	--					Link_Y_Motion <= Link_Y_Step;
	--					Link_X_Motion <= "0000000000";  
	--					if(( Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map2En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map2En1_X_pos > 0) OR (Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Map2En2_Y_pos-Link_Y_pos <= Link_Size AND Map2En2_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map2En2_X_pos <= Link_Size
	--						AND Link_X_pos - Map2En2_X_pos > 0) OR (Map2En2_X_pos-Link_X_pos <= Link_Size AND Map2En2_X_pos-Link_X_pos > 0) )) OR 
	--					   (Map2En3_Y_pos-Link_Y_pos <= Link_Size AND Map2En3_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map2En3_X_pos <= Link_Size
	--						AND Link_X_pos - Map2En3_X_pos > 0) OR (Map2En3_X_pos-Link_X_pos <= Link_Size AND Map2En3_X_pos-Link_X_pos > 0) )) ) then
	--						Link_Y_Motion <= not(Link_Y_Step+ "0000000100")+ '1';
	--						Link_Health <= Link_Health - '1';						
	--					end if;
	--					
	--					Link_atk <= '0';
	--				elsif(R = '1') then
	--					Link_X_Motion <= Link_X_Step;
	--					Link_Y_Motion <= "0000000000";
	--					if(( Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map2En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map2En1_Y_pos > 0) OR (Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Map2En2_X_pos-Link_X_pos <= Link_Size AND Map2En2_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map2En2_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map2En2_Y_pos > 0) OR (Map2En2_Y_pos-Link_Y_pos <= Link_Size AND Map2En2_Y_pos-Link_Y_pos > 0) )) OR 
	--					   (Map2En3_X_pos-Link_X_pos <= Link_Size AND Map2En3_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map2En3_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map2En3_Y_pos > 0) OR (Map2En3_Y_pos-Link_Y_pos <= Link_Size AND Map2En3_Y_pos-Link_Y_pos > 0) )) ) then
	--					   Link_X_Motion <= not(Link_X_Step+ "0000000100") + '1';
	--						Link_Health <= Link_Health - '1';					   
	--					end if;
	--					
	--					Link_atk <= '0';
	--				elsif(L = '1') then
	--					Link_X_Motion <= not(Link_X_Step) + '1';
	--					Link_Y_Motion <= "0000000000";
	--					if(( Link_X_pos - Map2En1_X_pos <= Link_Size AND Link_X_pos - Map2En1_X_pos > 0 AND ((Link_Y_pos - Map2En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map2En1_Y_pos > 0) OR (Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Link_X_pos - Map2En2_X_pos <= Link_Size AND Link_X_pos - Map2En2_X_pos > 0 AND ((Link_Y_pos - Map2En2_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map2En2_Y_pos > 0) OR (Map2En2_Y_pos-Link_Y_pos <= Link_Size AND Map2En2_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Link_X_pos - Map2En3_X_pos <= Link_Size AND Link_X_pos - Map2En3_X_pos > 0 AND ((Link_Y_pos - Map2En3_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map2En3_Y_pos > 0) OR (Map2En3_Y_pos-Link_Y_pos <= Link_Size AND Map2En3_Y_pos-Link_Y_pos > 0) )) ) then
	--						Link_Y_Motion <= Link_Y_Step+ "0000000100";
	--					   Link_X_Motion <= Link_X_Step+ "0000000100";
	--						Link_Health <= Link_Health - '1';					   
	--					end if;
	--					
	--					Link_atk <= '0';
	--				else 
	--					Link_Y_Motion <= "0000000000"; -- Ball is somewhere in the middle, don't bounce, just keep moving
	--			        Link_X_Motion <= "0000000000"; -- Ball is somewhere in the middle, don't bounce, just keep moving
	--			    end if;
	--			    
	--			    
	--			    
	--			    
	--			    if(atk = '1') then
	--			    	if(Link_dir = "00") then
	--			    		if(Link_Y_pos - Map2En1_Y_pos <= damage AND Link_Y_pos - Map2En1_Y_pos > 0 AND ((Link_X_pos - Map2En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map2En1_X_pos > 0) OR (Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0) ) AND
	--			    		   Map2En1_Health > 0) then
	--			    			Map2En1_Health <= Map2En1_Health - '1';
	--			    		elsif(Link_Y_pos - Map2En2_Y_pos <= damage AND Link_Y_pos - Map2En2_Y_pos > 0 AND ((Link_X_pos - Map2En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map2En1_X_pos > 0) OR (Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map2En2_Health > 0) then
	-- 			    			Map2En2_Health <= Map2En2_Health - '1';
	--			    		elsif(Link_Y_pos - Map2En3_Y_pos <= damage AND Link_Y_pos - Map2En3_Y_pos > 0 AND ((Link_X_pos - Map2En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map2En1_X_pos > 0) OR (Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map2En3_Health > 0) then
	--			    			Map2En3_Health <= Map2En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "01") then
	--			    		if(Map2En1_Y_pos - Link_Y_pos <= damage AND Map2En1_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map2En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map2En1_X_pos > 0) OR (Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map2En1_Health > 0) then
	--			    			Map2En1_Health <= Map2En1_Health - '1';
	--			    		elsif(Map2En2_Y_pos - Link_Y_pos <= damage AND Map2En2_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map2En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map2En1_X_pos > 0) OR (Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0)) AND 
	--				    		Map2En2_Health > 0) then
	-- 			    			Map2En2_Health <= Map2En2_Health - '1';
	--			    		elsif(Map2En3_Y_pos - Link_Y_pos <= damage AND Map2En3_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map2En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map2En1_X_pos > 0) OR (Map2En1_X_pos-Link_X_pos <= Link_Size AND Map2En1_X_pos-Link_X_pos > 0)) AND
	--			    			Map2En3_Health > 0) then
	--			    			Map2En3_Health <= Map2En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "11") then
	--			    		if(Map2En1_X_pos - Link_X_pos <= damage AND Map2En1_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map2En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map2En1_Y_pos > 0) OR (Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0) )  AND
	--				    		Map2En1_Health > 0) then
	--			    			Map2En1_Health <= Map2En1_Health - '1';
	--			    		elsif(Map2En2_X_pos - Link_X_pos <= damage AND Map2En2_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map2En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map2En1_Y_pos > 0) OR (Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0) ) AND
	--				    		Map2En2_Health > 0) then
	-- 			    			Map2En2_Health <= Map2En2_Health - '1';
	--			    		elsif(Map2En3_X_pos - Link_X_pos <= damage AND Map2En3_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map2En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map2En1_Y_pos > 0) OR (Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0) ) AND
	--			    			Map2En3_Health > 0) then
	--			    			Map2En3_Health <= Map2En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "10") then
	--			    		if(Map2En1_X_pos - Link_X_pos <= damage AND Map2En1_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map2En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map2En1_Y_pos > 0) OR (Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0) ) AND
	--				    		Map2En1_Health > 0) then
	--			    			Map2En1_Health <= Map2En1_Health - '1';
	--			    		elsif(Map2En2_X_pos - Link_X_pos <= damage AND Map2En2_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map2En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map2En1_Y_pos > 0) OR (Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0) ) AND 
	--				    		Map2En2_Health > 0) then
	-- 			    			Map2En2_Health <= Map2En2_Health - '1';
	--			    		elsif(Map2En3_X_pos - Link_X_pos <= damage AND Map2En3_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map2En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map2En1_Y_pos > 0) OR (Map2En1_Y_pos-Link_Y_pos <= Link_Size AND Map2En1_Y_pos-Link_Y_pos > 0) ) AND
	--			    			Map2En3_Health > 0) then
	--			    			Map2En3_Health <= Map2En3_Health - '1';
	--			    		end if;
	--			    	end if;
	--			    	Link_atk <= '1';
	--			    end if;
				    
					Link_Y_pos<= Link_Y_pos + Link_Y_Motion;
					Link_X_pos<=  Link_X_pos + Link_X_Motion;
				end if;	
	--				
	--				
	--			when C =>
	--				if   (Link_Y_Pos + Link_Size >= Link_Y_Max) then 
	--      		  		Link_Y_Motion <= "0000000000";
	--			        Link_X_Motion <= "0000000000"; 
	--		        elsif(Link_Y_Pos - Link_Size <= Link_Y_Min) then  
	--					Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000"; 
	--			        next_state <= A;
	--			        Link_Y_Pos <= Link_Y_Max;
	--			    elsif (Link_X_Pos + Link_Size >= Link_X_Max) then 
	--			        Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000";
	--			        next_state <= E;
	--			        Link_X_Pos <= Link_X_Min; 
	--		        elsif(Link_X_Pos - Link_Size <= Link_X_Min) then 
	--			        Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000"; 
	--				elsif(U = '1') then
	--					Link_Y_Motion <= not(Link_Y_Step)+ '1';
	--					Link_X_Motion <= "0000000000";
	--					if(( Link_Y_pos - Map3En1_Y_pos <= Link_Size AND Link_Y_pos - Map3En1_Y_pos > 0 AND ((Link_X_pos - Map3En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map3En1_X_pos > 0) OR (Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Link_Y_pos - Map3En2_Y_pos <= Link_Size AND Link_Y_pos - Map3En2_Y_pos > 0 AND ((Link_X_pos - Map3En2_X_pos <= Link_Size
	--						AND Link_X_pos - Map3En2_X_pos > 0) OR (Map3En2_X_pos-Link_X_pos <= Link_Size AND Map3En2_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Link_Y_pos - Map3En3_Y_pos <= Link_Size AND Link_Y_pos - Map3En3_Y_pos > 0 AND ((Link_X_pos - Map3En3_X_pos <= Link_Size
	--						AND Link_X_pos - Map3En3_X_pos > 0) OR (Map3En3_X_pos-Link_X_pos <= Link_Size AND Map3En3_X_pos-Link_X_pos > 0) )) ) then
	--						Link_Y_Motion <= Link_Y_Step+ "0000000100";
	--						Link_Health <= Link_Health - '1';
	--					end if;
	--					Link_dir <= "00";
	--				elsif(D = '1') then
	--					Link_Y_Motion <= Link_Y_Step;
	--					Link_X_Motion <= "0000000000";  
	--					if(( Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map3En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map3En1_X_pos > 0) OR (Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Map3En2_Y_pos-Link_Y_pos <= Link_Size AND Map3En2_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map3En2_X_pos <= Link_Size
	--						AND Link_X_pos - Map3En2_X_pos > 0) OR (Map3En2_X_pos-Link_X_pos <= Link_Size AND Map3En2_X_pos-Link_X_pos > 0) )) OR 
	--					   (Map3En3_Y_pos-Link_Y_pos <= Link_Size AND Map3En3_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map3En3_X_pos <= Link_Size
	--						AND Link_X_pos - Map3En3_X_pos > 0) OR (Map3En3_X_pos-Link_X_pos <= Link_Size AND Map3En3_X_pos-Link_X_pos > 0) )) ) then
	--						Link_Y_Motion <= not(Link_Y_Step+ "0000000100")+ '1';
	--						Link_Health <= Link_Health - '1';						
	--					end if;
	--					Link_dir <= "01";
	--					Link_atk <= '0';
	--				elsif(R = '1') then
	--					Link_X_Motion <= Link_X_Step;
	--					Link_Y_Motion <= "0000000000";
	--					if(( Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map3En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map3En1_Y_pos > 0) OR (Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Map3En2_X_pos-Link_X_pos <= Link_Size AND Map3En2_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map3En2_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map3En2_Y_pos > 0) OR (Map3En2_Y_pos-Link_Y_pos <= Link_Size AND Map3En2_Y_pos-Link_Y_pos > 0) )) OR 
	--					   (Map3En3_X_pos-Link_X_pos <= Link_Size AND Map3En3_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map3En3_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map3En3_Y_pos > 0) OR (Map3En3_Y_pos-Link_Y_pos <= Link_Size AND Map3En3_Y_pos-Link_Y_pos > 0) )) ) then
	--					   Link_X_Motion <= not(Link_X_Step+ "0000000100") + '1';
	--						Link_Health <= Link_Health - '1';					   
	--					end if;
	--					Link_dir <= "11";
	--					Link_atk <= '0';
	--				elsif(L = '1') then
	--					Link_X_Motion <= not(Link_X_Step) + '1';
	--					Link_Y_Motion <= "0000000000";
	--					if(( Link_X_pos - Map3En1_X_pos <= Link_Size AND Link_X_pos - Map3En1_X_pos > 0 AND ((Link_Y_pos - Map3En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map3En1_Y_pos > 0) OR (Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Link_X_pos - Map3En2_X_pos <= Link_Size AND Link_X_pos - Map3En2_X_pos > 0 AND ((Link_Y_pos - Map3En2_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map3En2_Y_pos > 0) OR (Map3En2_Y_pos-Link_Y_pos <= Link_Size AND Map3En2_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Link_X_pos - Map3En3_X_pos <= Link_Size AND Link_X_pos - Map3En3_X_pos > 0 AND ((Link_Y_pos - Map3En3_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map3En3_Y_pos > 0) OR (Map3En3_Y_pos-Link_Y_pos <= Link_Size AND Map3En3_Y_pos-Link_Y_pos > 0) )) ) then
	--						Link_Y_Motion <= Link_Y_Step+ "0000000100";
	--					   Link_X_Motion <= Link_X_Step+ "0000000100";
	--						Link_Health <= Link_Health - '1';					   
	--					end if;
	--					Link_dir <= "10";
	--					Link_atk <= '0';
	--				else 
	--					Link_Y_Motion <= "0000000000"; -- Ball is somewhere in the middle, don't bounce, just keep moving
	--			        Link_X_Motion <= "0000000000"; -- Ball is somewhere in the middle, don't bounce, just keep moving
	--			    end if;
	--			    if(atk = '1') then
	--			    	if(Link_dir = "00") then
	--			    		if(Link_Y_pos - Map3En1_Y_pos <= damage AND Link_Y_pos - Map3En1_Y_pos > 0 AND ((Link_X_pos - Map3En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map3En1_X_pos > 0) OR (Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0) ) AND
	--			    		   Map3En1_Health > 0) then
	--			    			Map3En1_Health <= Map3En1_Health - '1';
	--			    		elsif(Link_Y_pos - Map3En2_Y_pos <= damage AND Link_Y_pos - Map3En2_Y_pos > 0 AND ((Link_X_pos - Map3En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map3En1_X_pos > 0) OR (Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map3En2_Health > 0) then
	-- 			    			Map3En2_Health <= Map3En2_Health - '1';
	--			    		elsif(Link_Y_pos - Map3En3_Y_pos <= damage AND Link_Y_pos - Map3En3_Y_pos > 0 AND ((Link_X_pos - Map3En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map3En1_X_pos > 0) OR (Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map3En3_Health > 0) then
	--			    			Map3En3_Health <= Map3En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "01") then
	--			    		if(Map3En1_Y_pos - Link_Y_pos <= damage AND Map3En1_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map3En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map3En1_X_pos > 0) OR (Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map3En1_Health > 0) then
	--			    			Map3En1_Health <= Map3En1_Health - '1';
	--			    		elsif(Map3En2_Y_pos - Link_Y_pos <= damage AND Map3En2_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map3En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map3En1_X_pos > 0) OR (Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0)) AND 
	--				    		Map3En2_Health > 0) then
	-- 			    			Map3En2_Health <= Map3En2_Health - '1';
	--			    		elsif(Map3En3_Y_pos - Link_Y_pos <= damage AND Map3En3_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map3En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map3En1_X_pos > 0) OR (Map3En1_X_pos-Link_X_pos <= Link_Size AND Map3En1_X_pos-Link_X_pos > 0)) AND
	--			    			Map3En3_Health > 0) then
	--			    			Map3En3_Health <= Map3En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "11") then
	--			    		if(Map3En1_X_pos - Link_X_pos <= damage AND Map3En1_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map3En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map3En1_Y_pos > 0) OR (Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0) )  AND
	--				    		Map3En1_Health > 0) then
	--			    			Map3En1_Health <= Map3En1_Health - '1';
	--			    		elsif(Map3En2_X_pos - Link_X_pos <= damage AND Map3En2_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map3En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map3En1_Y_pos > 0) OR (Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0) ) AND
	--				    		Map3En2_Health > 0) then
	-- 			    			Map3En2_Health <= Map3En2_Health - '1';
	--			    		elsif(Map3En3_X_pos - Link_X_pos <= damage AND Map3En3_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map3En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map3En1_Y_pos > 0) OR (Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0) ) AND
	--			    			Map3En3_Health > 0) then
	--			    			Map3En3_Health <= Map3En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "10") then
	--			    		if(Map3En1_X_pos - Link_X_pos <= damage AND Map3En1_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map3En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map3En1_Y_pos > 0) OR (Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0) ) AND
	--				    		Map3En1_Health > 0) then
	--			    			Map3En1_Health <= Map3En1_Health - '1';
	--			    		elsif(Map3En2_X_pos - Link_X_pos <= damage AND Map3En2_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map3En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map3En1_Y_pos > 0) OR (Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0) ) AND 
	--				    		Map3En2_Health > 0) then
	-- 			    			Map3En2_Health <= Map3En2_Health - '1';
	--			    		elsif(Map3En3_X_pos - Link_X_pos <= damage AND Map3En3_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map3En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map3En1_Y_pos > 0) OR (Map3En1_Y_pos-Link_Y_pos <= Link_Size AND Map3En1_Y_pos-Link_Y_pos > 0) ) AND
	--			    			Map3En3_Health > 0) then
	--			    			Map3En3_Health <= Map3En3_Health - '1';
	--			    		end if;
	--			    	end if;
	--			    	Link_atk <= '1';
	--			    end if;
	--			    Link_X_pos<= Link_X_Motion + Link_X_pos;
	--				Link_Y_pos<= Link_Y_Motion + Link_Y_pos;
	--			when E =>
	--				if   (Link_Y_Pos + Link_Size >= Link_Y_Max) then 
	--      		  		Link_Y_Motion <= "0000000000";
	--			        Link_X_Motion <= "0000000000"; 
	--		        elsif(Link_Y_Pos - Link_Size <= Link_Y_Min) then  
	--					Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000"; 
	--			        next_state <= B;
	--			        Link_Y_Pos <= Link_Y_Max;
	--			    elsif (Link_X_Pos + Link_Size >= Link_X_Max) then 
	--			        Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000"; 
	--		        elsif(Link_X_Pos - Link_Size <= Link_X_Min) then 
	--			        Link_Y_Motion <= "0000000000"; 
	--			        Link_X_Motion <= "0000000000";
	--			        next_state <= C;
	--			        Link_X_Pos <= Link_X_Max; 
	--				elsif(U = '1') then
	--					Link_Y_Motion <= not(Link_Y_Step)+ '1';
	--					Link_X_Motion <= "0000000000";
	--					if(( Link_Y_pos - Map4En1_Y_pos <= Link_Size AND Link_Y_pos - Map4En1_Y_pos > 0 AND ((Link_X_pos - Map4En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map4En1_X_pos > 0) OR (Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Link_Y_pos - Map4En2_Y_pos <= Link_Size AND Link_Y_pos - Map4En2_Y_pos > 0 AND ((Link_X_pos - Map4En2_X_pos <= Link_Size
	--						AND Link_X_pos - Map4En2_X_pos > 0) OR (Map4En2_X_pos-Link_X_pos <= Link_Size AND Map4En2_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Link_Y_pos - Map4En3_Y_pos <= Link_Size AND Link_Y_pos - Map4En3_Y_pos > 0 AND ((Link_X_pos - Map4En3_X_pos <= Link_Size
	--						AND Link_X_pos - Map4En3_X_pos > 0) OR (Map4En3_X_pos-Link_X_pos <= Link_Size AND Map4En3_X_pos-Link_X_pos > 0) )) ) then
	--						Link_Y_Motion <= Link_Y_Step+ "0000000100";
	--						Link_Health <= Link_Health - '1';
	--					end if;
	--					Link_dir <= "00";
	--				elsif(D = '1') then
	--					Link_Y_Motion <= Link_Y_Step;
	--					Link_X_Motion <= "0000000000";  
	--					if(( Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map4En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map4En1_X_pos > 0) OR (Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0) )) OR 
	--					   ( Map4En2_Y_pos-Link_Y_pos <= Link_Size AND Map4En2_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map4En2_X_pos <= Link_Size
	--						AND Link_X_pos - Map4En2_X_pos > 0) OR (Map4En2_X_pos-Link_X_pos <= Link_Size AND Map4En2_X_pos-Link_X_pos > 0) )) OR 
	--					   (Map4En3_Y_pos-Link_Y_pos <= Link_Size AND Map4En3_Y_pos-Link_Y_pos > 0 AND ((Link_X_pos - Map4En3_X_pos <= Link_Size
	--						AND Link_X_pos - Map4En3_X_pos > 0) OR (Map4En3_X_pos-Link_X_pos <= Link_Size AND Map4En3_X_pos-Link_X_pos > 0) )) ) then
	--						Link_Y_Motion <= not(Link_Y_Step+ "0000000100")+ '1';
	--						Link_Health <= Link_Health - '1';						
	--					end if;
	--					Link_dir <= "01";
	--					Link_atk <= '0';
	--				elsif(R = '1') then
	--					Link_X_Motion <= Link_X_Step;
	--					Link_Y_Motion <= "0000000000";
	--					if(( Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map4En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map4En1_Y_pos > 0) OR (Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Map4En2_X_pos-Link_X_pos <= Link_Size AND Map4En2_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map4En2_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map4En2_Y_pos > 0) OR (Map4En2_Y_pos-Link_Y_pos <= Link_Size AND Map4En2_Y_pos-Link_Y_pos > 0) )) OR 
	--					   (Map4En3_X_pos-Link_X_pos <= Link_Size AND Map4En3_X_pos-Link_X_pos > 0 AND ((Link_Y_pos - Map4En3_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map4En3_Y_pos > 0) OR (Map4En3_Y_pos-Link_Y_pos <= Link_Size AND Map4En3_Y_pos-Link_Y_pos > 0) )) ) then
	--					   Link_X_Motion <= not(Link_X_Step+ "0000000100") + '1';
	--						Link_Health <= Link_Health - '1';					   
	--					end if;
	--					Link_dir <= "11";
	--					Link_atk <= '0';
	--				elsif(L = '1') then
	--					Link_X_Motion <= not(Link_X_Step) + '1';
	--					Link_Y_Motion <= "0000000000";
	--					if(( Link_X_pos - Map4En1_X_pos <= Link_Size AND Link_X_pos - Map4En1_X_pos > 0 AND ((Link_Y_pos - Map4En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map4En1_Y_pos > 0) OR (Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Link_X_pos - Map4En2_X_pos <= Link_Size AND Link_X_pos - Map4En2_X_pos > 0 AND ((Link_Y_pos - Map4En2_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map4En2_Y_pos > 0) OR (Map4En2_Y_pos-Link_Y_pos <= Link_Size AND Map4En2_Y_pos-Link_Y_pos > 0) )) OR 
	--					   ( Link_X_pos - Map4En3_X_pos <= Link_Size AND Link_X_pos - Map4En3_X_pos > 0 AND ((Link_Y_pos - Map4En3_Y_pos <= Link_Size
	--						AND Link_Y_pos - Map4En3_Y_pos > 0) OR (Map4En3_Y_pos-Link_Y_pos <= Link_Size AND Map4En3_Y_pos-Link_Y_pos > 0) )) ) then
	--						Link_Y_Motion <= Link_Y_Step+ "0000000100";
	--					   Link_X_Motion <= Link_X_Step+ "0000000100";
	--						Link_Health <= Link_Health - '1';					   
	--					end if;
	--					Link_dir <= "10";
	--					Link_atk <= '0';
	--				else 
	--					Link_Y_Motion <= "0000000000"; -- Ball is somewhere in the middle, don't bounce, just keep moving
	--			        Link_X_Motion <= "0000000000"; -- Ball is somewhere in the middle, don't bounce, just keep moving
	--			    end if;
	--			    if(atk = '1') then
	--			    	if(Link_dir = "00") then
	--			    		if(Link_Y_pos - Map4En1_Y_pos <= damage AND Link_Y_pos - Map4En1_Y_pos > 0 AND ((Link_X_pos - Map4En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map4En1_X_pos > 0) OR (Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0) ) AND
	--			    		   Map4En1_Health > 0) then
	--			    			Map4En1_Health <= Map4En1_Health - '1';
	--			    		elsif(Link_Y_pos - Map4En2_Y_pos <= damage AND Link_Y_pos - Map4En2_Y_pos > 0 AND ((Link_X_pos - Map4En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map4En1_X_pos > 0) OR (Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map4En2_Health > 0) then
	-- 			    			Map4En2_Health <= Map4En2_Health - '1';
	--			    		elsif(Link_Y_pos - Map4En3_Y_pos <= damage AND Link_Y_pos - Map4En3_Y_pos > 0 AND ((Link_X_pos - Map4En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map4En1_X_pos > 0) OR (Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map4En3_Health > 0) then
	--			    			Map4En3_Health <= Map4En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "01") then
	--			    		if(Map4En1_Y_pos - Link_Y_pos <= damage AND Map4En1_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map4En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map4En1_X_pos > 0) OR (Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0) ) AND
	--				    		Map4En1_Health > 0) then
	--			    			Map4En1_Health <= Map4En1_Health - '1';
	--			    		elsif(Map4En2_Y_pos - Link_Y_pos <= damage AND Map4En2_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map4En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map4En1_X_pos > 0) OR (Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0)) AND 
	--				    		Map4En2_Health > 0) then
	-- 			    			Map4En2_Health <= Map4En2_Health - '1';
	--			    		elsif(Map4En3_Y_pos - Link_Y_pos <= damage AND Map4En3_Y_pos - Link_Y_pos > 0 AND ((Link_X_pos - Map4En1_X_pos <= Link_Size 
	--					   AND Link_X_pos - Map4En1_X_pos > 0) OR (Map4En1_X_pos-Link_X_pos <= Link_Size AND Map4En1_X_pos-Link_X_pos > 0)) AND
	--			    			Map4En3_Health > 0) then
	--			    			Map4En3_Health <= Map4En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "11") then
	--			    		if(Map4En1_X_pos - Link_X_pos <= damage AND Map4En1_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map4En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map4En1_Y_pos > 0) OR (Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0) )  AND
	--				    		Map4En1_Health > 0) then
	--			    			Map4En1_Health <= Map4En1_Health - '1';
	--			    		elsif(Map4En2_X_pos - Link_X_pos <= damage AND Map4En2_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map4En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map4En1_Y_pos > 0) OR (Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0) ) AND
	--				    		Map4En2_Health > 0) then
	-- 			    			Map4En2_Health <= Map4En2_Health - '1';
	--			    		elsif(Map4En3_X_pos - Link_X_pos <= damage AND Map4En3_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map4En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map4En1_Y_pos > 0) OR (Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0) ) AND
	--			    			Map4En3_Health > 0) then
	--			    			Map4En3_Health <= Map4En3_Health - '1';
	--			    		end if;
	--			    	elsif(Link_dir = "10") then
	--			    		if(Map4En1_X_pos - Link_X_pos <= damage AND Map4En1_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map4En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map4En1_Y_pos > 0) OR (Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0) ) AND
	--				    		Map4En1_Health > 0) then
	--			    			Map4En1_Health <= Map4En1_Health - '1';
	--			    		elsif(Map4En2_X_pos - Link_X_pos <= damage AND Map4En2_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map4En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map4En1_Y_pos > 0) OR (Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0) ) AND 
	--				    		Map4En2_Health > 0) then
	-- 			    			Map4En2_Health <= Map4En2_Health - '1';
	--			    		elsif(Map4En3_X_pos - Link_X_pos <= damage AND Map4En3_X_pos - Link_X_pos > 0 AND ((Link_Y_pos - Map4En1_Y_pos <= Link_Size 
	--					   AND Link_Y_pos - Map4En1_Y_pos > 0) OR (Map4En1_Y_pos-Link_Y_pos <= Link_Size AND Map4En1_Y_pos-Link_Y_pos > 0) ) AND
	--			    			Map4En3_Health > 0) then
	--			    			Map4En3_Health <= Map4En3_Health - '1';
	--			    		end if;
	--			    	end if;
	--			    	Link_atk <= '1';
	--			    end if;
	--			    Link_X_pos<= Link_X_Motion + Link_X_pos;
	--				Link_Y_pos<= Link_Y_Motion + Link_Y_pos;
	--		end case;
	
	end process;
	------------------------------------
	Link(25 downto 24) <= "00";
	Link(23 downto 14) <= Link_X_pos;
	Link(13 downto 4) <= Link_Y_pos;
	Link(3 downto 0) <= "0000";
	
	------------------------------------
	
	
	
--	get_cntrl_out : process (state)
--	begin
--		case state is
--			when A=>
--					
--					Link(25 downto 24) <= Link_dir;
--					Link(23 downto 14) <= Link_X_pos;
--					Link(13 downto 4) <= Link_Y_pos;
--					Link(3) <= atk;
--					Link(2 downto 0) <= Link_Health;
--					En1(24 downto 15) <= Map1En1_X_pos;
--					En1(14 downto 5) <= Map1En1_X_pos;
--					En1(4 downto 2) <= "000";
--					En1(1 downto 0) <= Map1En1_Health;
--					En2(24 downto 15) <= Map1En1_X_pos;
--					En2(14 downto 5) <= Map1En1_X_pos;
--					En2(4 downto 2) <= "000";
--					En2(1 downto 0) <= Map1En1_Health;
--					En3(24 downto 15) <= Map1En1_X_pos;
--					En3(14 downto 5) <= Map1En1_X_pos;
--					En3(4 downto 2) <= "000";
--					En3(1 downto 0) <= Map1En1_Health;
--					maps <= "00";
-- 			when B=>
--					Link(25 downto 24) <= Link_dir;
--					Link(23 downto 14) <= Link_X_pos;
--					Link(13 downto 4) <= Link_Y_pos;
--					Link(3) <= atk;
--					Link(2 downto 0) <= Link_Health;
--					En1(24 downto 15) <= Map2En1_X_pos;
--					En1(14 downto 5) <= Map2En1_X_pos;
--					En1(4 downto 2) <= "000";
--					En1(1 downto 0) <= Map2En1_Health;
--					En2(24 downto 15) <= Map2En1_X_pos;
--					En2(14 downto 5) <= Map2En1_X_pos;
--					En2(4 downto 2) <= "000";
--					En2(1 downto 0) <= Map2En1_Health;
--					En3(24 downto 15) <= Map2En1_X_pos;
--					En3(14 downto 5) <= Map2En1_X_pos;
--					En3(4 downto 2) <= "000";
--					En3(1 downto 0) <= Map2En1_Health;
--					maps <= "01";
--			when C=>			
--					Link(25 downto 24) <= Link_dir;
--					Link(23 downto 14) <= Link_X_pos;
--					Link(13 downto 4) <= Link_Y_pos;
--					Link(3) <= atk;
--					Link(2 downto 0) <= Link_Health;
--					En1(24 downto 15) <= Map3En1_X_pos;
--					En1(14 downto 5) <= Map3En1_X_pos;
--					En1(4 downto 2) <= "000";
--					En1(1 downto 0) <= Map3En1_Health;
--					En2(24 downto 15) <= Map3En1_X_pos;
--					En2(14 downto 5) <= Map3En1_X_pos;
--					En2(4 downto 2) <= "000";
--					En2(1 downto 0) <= Map3En1_Health;
--					En3(24 downto 15) <= Map3En1_X_pos;
--					En3(14 downto 5) <= Map3En1_X_pos;
--					En3(4 downto 2) <= "000";
--					En3(1 downto 0) <= Map3En1_Health;
--					maps <= "10";					
--			when E=>			
--					Link(25 downto 24) <= Link_dir;
--					Link(23 downto 14) <= Link_X_pos;
--					Link(13 downto 4) <= Link_Y_pos;
--					Link(3) <= atk;
--					Link(2 downto 0) <= Link_Health;
--					En1(24 downto 15) <= Map4En1_X_pos;
--					En1(14 downto 5) <= Map4En1_X_pos;
--					En1(4 downto 2) <= "000";
--					En1(1 downto 0) <= Map4En1_Health;
--					En2(24 downto 15) <= Map4En1_X_pos;
--					En2(14 downto 5) <= Map4En1_X_pos;
--					En2(4 downto 2) <= "000";
--					En2(1 downto 0) <= Map4En1_Health;
--					En3(24 downto 15) <= Map4En1_X_pos;
--					En3(14 downto 5) <= Map4En1_X_pos;
--					En3(4 downto 2) <= "000";
--					En3(1 downto 0) <= Map4En1_Health;		
--					maps <= "11";					
--			end case;
--	end process;
end Behavioral;      

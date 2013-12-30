---------------------------------------------------------------------------
--    Color_Mapper.vhd                                                   --
--    Stephen Kempf                                                      --
--    3-1-06                                                             --
--												 --
--    Modified by David Kesler - 7-16-08						 --
--                                                                       --
--    Fall 2007 Distribution                                             --
--                                                                       --
--    For use with ECE 385 Lab 9                                         --
--    University of Illinois ECE Department                              --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--use ieee.numeric_std.all;

entity Color_Mapper is
   Port ( En1   : in std_logic_vector(25 downto 0);
          En2   : in std_logic_vector(25 downto 0);
          En3   : in std_logic_vector(25 downto 0);
          BallX : in std_logic_vector(9 downto 0);
          BallY : in std_logic_vector(9 downto 0);
          DrawX : in std_logic_vector(9 downto 0);
          DrawY : in std_logic_vector(9 downto 0);
          
          Ball_size : in std_logic_vector(9 downto 0);
          mapname : in std_logic_vector(1 downto 0);
          --inputs for animations
          linkInfo: in std_logic_vector(6 downto 0);
          aniClk: in std_logic;
          
          
          RAM_Data: in std_logic_vector(15 downto 0);
           
          RAM_Addr: out std_logic_vector(17 downto 0);
         
          
          Red   : out std_logic_vector(9 downto 0);
          Green : out std_logic_vector(9 downto 0);
          Blue  : out std_logic_vector(9 downto 0));
end Color_Mapper;

architecture Behavioral of Color_Mapper is

	signal Ball_on : std_logic;

	--these signals are used for accessing SRAM
	signal RG: std_logic_vector(15 downto 0);
	signal temp_Addr: std_logic_vector(19 downto 0);

	--state machine stuff for loading pixels from memory
	type cntrl_state is (A, B, C,F);
	signal state, next_state: cntrl_state;
	signal newPixReset, dataReady: std_logic;
	signal drToggle, nprToggle: std_logic;
	signal loadedTog: std_logic;
	
	--signals for use in selecting which picture will be read from memory
	
	constant picSize: std_logic_vector(13 downto 0):= "00010000000000";
	constant attackOffset: std_logic_vector(13 downto 0):= CONV_STD_LOGIC_VECTOR(8*1024, 14);
	constant mapOffset: std_logic_vector(15 downto 0):= CONV_STD_LOGIC_VECTOR(16*1024, 16);
	constant enemyOffset : std_logic_vector(15 downto 0):= CONV_STD_LOGIC_VECTOR(22*1024, 16);
	signal linksCurrDir: std_logic_vector(1 downto 0);
	signal linkMoving, linkAttacking: std_logic;
	

	signal stuff: std_logic_vector(3 downto 0);
	
	--MapPlanner
	type int_array is array (integer range <>) of integer;
	signal map0 :int_array(0 to 299):=(
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
	signal map1 :int_array(0 to 299):=(
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 3, 3, 4, 0, 4, 3, 3, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 3, 3, 4, 0, 4, 3, 3, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 3, 3, 4, 0, 4, 3, 3, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 3, 3, 4, 0, 4, 3, 3, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0);
	signal map2 :int_array(0 to 299):=(
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 2, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 2, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 2, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 2, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	signal map3 :int_array(0 to 299):=(
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 0,
	1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
begin
	
	linksCurrDir <= linkInfo(1 downto 0);
	linkMoving <= linkInfo(3);
	linkAttacking <= linkInfo(2);
	
	--Ball-on_proc is the central process in Color_mapper. It is responsible for ultimatly deciding the color of each pixel that is written to the screen.
	-- It does this by setting a signal temp_Addr, with the address of the correct pixel, leadingto the following person to lead out. to be even more specific, most of the peices of code in 
	--Ball__on_proc set yes another variable called BaseOne, which is THEN used to set temp_Addr.  
	Ball_on_proc : process (BallX, BallY, DrawX, DrawY, Ball_size, linksCurrDir, linkMoving, aniClk,linkAttacking, En1, En2, En3)
		variable baseOne:std_logic_vector(16 downto 0);
		variable tempX, tempY: std_logic_vector(9 downto 0);
		variable frameNo, EnframeNo:std_logic;
		variable xcoord, ycoord, values:integer;
		variable blocktype: std_logic_vector(3 downto 0);
		variable temp :  std_logic_vector(1 downto 0);
  ----------------------
		variable swordX1, swordX2: std_logic_vector(9 downto 0);

	 variable swordY1, swordY2: std_logic_vector(9 downto 0);

	 ----------
		variable AttAnimSetter: std_logic; 
	 begin

	

	
	--here a pixel is tested to see it if it is a peice of link's sword. link's sword is currently a single grey box a pixes that appears whenever l. 
	--Unlike the following if statements in this process, this paritcular conditionas is not specifically responsible fore setting temp address, 
	--but it modifies helper vaalues swordX, swordX1, swordy, swordy1, which are used in drawing link/s words below the values for these helper variables 
		  (DrawX <= BallX) AND
		  (DrawY >= BallY ) AND
		  (DrawY < (BallY + Ball_Size))) then
			 swordX1 := BallX-Ball_Size;
			 swordX2 := BallX;
			 swordY1 := BallY+15;-----
			 swordY2 := BallY +23;-----
		 elsif((linksCurrDir = "00") AND(DrawX >= (BallX-Ball_Size) ) AND --top
		  (DrawX <= (BallX + Ball_Size)) AND
		  (DrawY >= (BallY -Ball_Size) ) AND
		  (DrawY < BallY)) then
			 swordX1 := BallX + 8;
			 swordX2 := BallX + 16;
			 swordY1 := BallY - Ball_Size;
			 swordY2 := BallY;
		 elsif ((linksCurrDir = "11") AND(DrawX >= (BallX + Ball_Size) ) AND --right
		  (DrawX <= (BallX + Ball_Size + Ball_size)) AND
		  (DrawY >= BallY ) AND
		  (DrawY < (BallY + Ball_Size))) then
			 swordX1 := BallX+Ball_Size;
			 swordX2 := BallX + Ball_Size + Ball_Size;
			 swordY1 := BallY + 15;
			 swordY2 := BallY + 23;
		 elsif ((linksCurrDir = "01") AND(DrawX >= BallX ) AND --down
		  (DrawX <= (BallX + Ball_Size)) AND
		  (DrawY >= (BallY + Ball_Size) ) AND
		  (DrawY < (BallY + Ball_Size + Ball_size))) then
			 swordX1 := BallX + 12;
			 swordX2 := BallX + 20;
			 swordY1 := BallY+Ball_Size;
			 swordY2 := BallY+Ball_Size+Ball_Size;
		 	 
		 else 
			swordX1 := "0000000000";
			swordX2 := "0000000000";
			swordY1 := "0000000000";
			swordY2 := "0000000000";
			
			end if;
	end if; 
	
	
	--here a pixel is ultimately testesd to see if it is aa pixel of an attacking link's sword (using the helper values that were just set above)
		 if ((linkAttacking = '1') AND (DrawX >= swordX1) AND --down
		  (DrawX <= swordX2) AND
		  (DrawY >= swordY1 ) AND
		  (DrawY < swordY2)) then
			 temp_Addr <= "00000111000000011100";
	
  ----if it is determined that that pixel is not a peice of link's sword, this id statement is sort of testing if the current pixel being drawn is a peice of one of links sprites. 
  --this involves a few key peices of information such as link's location ( as stored in BallX and BallY, links current direction that he is facing, whether link is attacking right that moment and a number frameNo, which regularly is just which 
  --current frame of the animation we are shoing right then
		elsif ((DrawX >= BallX ) AND
		  (DrawX <= BallX + Ball_size) AND
		  (DrawY >= BallY ) AND
		  (DrawY < BallY + Ball_size)) then
			
			if(linkMoving = '1')then
				frameNo := aniClk;
			elsif(linkAttacking = '1')then
				frameNo := '1';
			end if;
			
			
			if(linkAttacking = '1')then
				baseOne := unsigned(PicSize)*unsigned(linksCurrDir & frameNo) + unsigned(attackOffset);
				baseOne := std_logic_vector(baseOne);
--				baseOne := CONV_STD_LOGIC_VECTOR(( 5*1024 + 8*1024), 17);
			else
				baseOne := unsigned(PicSize)*unsigned(linksCurrDir & frameNo);
				baseOne := std_logic_vector(baseOne);
			end if;
			

			temp_Addr <= baseOne+(Ball_size*(DrawY-BallY)+ (DrawX-BallX))+'1';
	
	
			Ball_on <= '1';
			
			
			
		--the next three elseif statements all deal with enemies, and whether the current pixel being drawn needs to display part of an enemy. each of these statements closely mimics 
		--link's conditional statement to check if the current pixel lies within a box of set dimensions from the pre-determined coordingates of the enemies in our game. using our vectors En1, E2, and En3,
		-- we extract data regarding the location of one of three enemies on the current screen, and compares the X ad Y values of the current pixel to the location of the enemies. 
		--In order to allow monster/enemies to have completely separate animations for enemies than for link, a different frameNo value-EnframeNo is used
		elsif ((DrawX >= En1(25 downto 16) ) AND
		  (DrawX <= En1(25 downto 16) + Ball_size) AND
		  (DrawY >= En1(15 downto 6) ) AND
		  (DrawY < En1(15 downto 6) + Ball_size)AND (En1(5 downto 4) >= "00")) then --this eice checks if the pixel falls within a certain box relative to the current pixel 
			case En1(3 downto 0) is
				when "0111" => --if it is determined that the current pixel should be displaying a peice of an enem'es frame, the En vector is immediately referenced to 
				--determined what type of enemy we are looking at. this information is combined with a standard offset "enemyOffset" which will determine the location in memory corresponding to that 
				--current pixel being written 
					EnframeNo := aniClk;
					temp := "00";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when "1000" =>
					EnframeNo := aniClk;
					temp := "01";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when "1001" =>
					EnframeNo := aniClk;
					temp := "10";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when others =>
			end case;
			temp_Addr <= baseOne+(Ball_size*(DrawY-En1(15 downto 6))+ (DrawX-En1(25 downto 16)))+'1';
		
		--the code below is a repeat of the code immediately above this statement, and as such doesn't need aditional commenting
		elsif ((DrawX >= En2(25 downto 16) ) AND
		  (DrawX <= En2(25 downto 16) + Ball_size) AND
		  (DrawY >= En2(15 downto 6) ) AND
		  (DrawY < En2(15 downto 6) + Ball_size) AND (En2(5 downto 4) >= "00")) then
			case En2(3 downto 0) is
				when "0111" =>
					EnframeNo := aniClk;
					temp := "00";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when "1000" =>
					EnframeNo := aniClk;
					temp := "01";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when "1001" =>
					EnframeNo := aniClk;
					temp := "10";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when others =>
			end case;
			temp_Addr <= baseOne+(Ball_size*(DrawY-En2(15 downto 6))+ (DrawX-En2(25 downto 16)))+'1';
		elsif ((DrawX >= En3(25 downto 16) ) AND
		  (DrawX <= En3(25 downto 16) + Ball_size) AND
		  (DrawY >= En3(15 downto 6) ) AND
		  (DrawY < En3(15 downto 6) + Ball_size)AND (En3(5 downto 4) >= "00")) then
			case En3(3 downto 0) is
				when "0111" =>
					EnframeNo := aniClk;
					temp := "00";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when "1000" =>
					EnframeNo := aniClk;
					temp := "01";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when "1001" =>
					EnframeNo := aniClk;
					temp := "10";
					baseOne := unsigned(PicSize)*unsigned(temp & EnframeNo) + unsigned(enemyOffset);
					baseOne := std_logic_vector(baseOne);
				when others =>
			end case;
			temp_Addr <= baseOne+(Ball_size*(DrawY-En3(15 downto 6))+ (DrawX-En3(25 downto 16)))+'1';
			
			
		else
		
			
			--lastly, if a pixel has been determined to not belong to link, his sword, or any monsters, then that pixel corresponds to a peice of background. 
			--These peices of background are accessed using th integer array maps present in the beginning of this file. 
			Ball_on <= '0';
			tempX := DrawX(9 downto 5) & "00000";
			xcoord := conv_integer(unsigned(tempX))/32;
			tempY := DrawY(9 downto 5) & "00000";
			ycoord := conv_integer(unsigned(tempY))/32;
			values := ycoord*20+xcoord;
			if(xcoord < 20 AND ycoord < 15) then
				case mapname is
					when "00" =>
						blocktype := CONV_STD_LOGIC_VECTOR(map0(values), 4);
					when "01" =>
						blocktype := CONV_STD_LOGIC_VECTOR(map1(values), 4);
					when "10" =>
						blocktype := CONV_STD_LOGIC_VECTOR(map2(values), 4);
					when "11" =>
						blocktype := CONV_STD_LOGIC_VECTOR(map3(values), 4);
				end case;
			end if;
			
			case blocktype is
				when "0000" =>
					baseOne := unsigned(PicSize)*unsigned(blocktype(2 downto 0)) + unsigned(mapOffset);
					baseOne := std_logic_vector(baseOne);
				when "0001" =>
					baseOne := unsigned(PicSize)*unsigned(blocktype(2 downto 0)) + unsigned(mapOffset);
					baseOne := std_logic_vector(baseOne);
				when "0010" =>
					baseOne := unsigned(PicSize)*unsigned(blocktype(2 downto 0)) + unsigned(mapOffset);
					baseOne := std_logic_vector(baseOne);
				when "0011" =>
					baseOne := unsigned(PicSize)*unsigned(blocktype(2 downto 0)) + unsigned(mapOffset);
					baseOne := std_logic_vector(baseOne);
				when "0100" =>
					baseOne := unsigned(PicSize)*unsigned(blocktype(2 downto 0)) + unsigned(mapOffset);
					baseOne := std_logic_vector(baseOne);
				when "0101" =>
					baseOne := unsigned(PicSize)*unsigned(blocktype(2 downto 0)) + unsigned(mapOffset);
					baseOne := std_logic_vector(baseOne);
				when "0110" =>
					baseOne := unsigned(PicSize)*unsigned(blocktype(2 downto 0)) + unsigned(mapOffset);
					baseOne := std_logic_vector(baseOne);
				when "0111" =>
					baseOne := unsigned(PicSize)*unsigned(blocktype(2 downto 0)) + unsigned(mapOffset);
					baseOne := std_logic_vector(baseOne);
				when others =>
			end case;
			
			temp_Addr <= baseOne+(Ball_size*(DrawY-tempY)+ (DrawX-tempX))+'1';
		end if;
	end process Ball_on_proc;


	stMchOut:process(state)
	begin
		case state is 
			when A=>
							
				drToggle <= NOT drToggle;
				--toggle for newPixReset
				nprToggle <= NOT nprToggle; --worried that timing might cause glitch here
				
			when B=>
				RAM_Addr <= temp_Addr(17 downto 0);
				
				
			when C=>
				
				RG<= RAM_DATA;
				--toggle for dataReady
				next_state <= F;
			when others=>
			
			
		end case;
	end process stMchOut;
  
  --this process is responsible for detecting any small changes made in temp_Addr, such these changes will drigger the state machine to immediately
  --drop what it is doing and attempt to service the next request. this ensures that the state machine will be less likely to fall hehind, as the process will never was time trying to
  -- service the request of an old pixel when a next one is available. 
	stMchReset:process(temp_Addr, nprToggle)
	begin
		--must be universal reset triggered by temp_addr
		if(state = A) then
			newPixReset <= '0';
		else
			newPixReset <='1';
		end if;
	end process stMchReset;
 
 
 
 --this process in the state machine determines if any new data has arrived on the Data_output line of the SRAM
	newData: process( RAM_DATA, drToggle)
	begin
		if(state = B) then
			dataReady <='1';
		else
			dataReady <='0';
		end if;
		
	end process newData;

	-- this is the control process for the state machine. it is responsible for switching the states of the st machine. 
	stMchCntl: process(dataReady, newPixReset, next_state)
	begin
		if(newPixReset = '1')then
			state <= A;
		else
			case state is
				when A=>
					--check that newPixReset is 0 again before switching states
					if(newPixReset = '0')then
						state <= B;
					end if;
				when B=>
					if(dataReady = '1')then
						state <= C;
					end if;
				when C=>
					state<=next_state;
				when others=>
				
					
				
			end case;	
		end if;		
	end process stMchCntl;



--the last process of colormapper simply looks for RG to change (an action that the above state machine is responsible for) and then immediately writes RG to the screen. 
--In addition, to avoid the "white boxes" of background around link and each enemy we check the color of each pixel before it it loaded to the screen, and if it is white, 
--then is writes a more cream colored pixel to the screen, in fitting with the background of the game. 
  RGB_Display : process (RG)
	variable GGB: std_logic_vector(15 downto 0);
  begin
--    if ((Ball_on = '1') AND 
	if(RG /= "1111111111111110") then -- blue ball
      Red <=  RG(15 downto 11) & "00000";--RG(15) & "0" & RG(14) & "0" & RG(13) & "0" & RG(12) & "0" & RG(11) & "0";--RG(15 downto 8) & "00";
      Green <= RG(10 downto 6) & "00000";--RG(10) & "0" & RG(9) & "0" & RG(8) & "0" & RG(7) & "0" & RG(6) & "0";
      Blue <= RG(5 downto 1) &"00000";--RG(5) & "0" & RG(4) & "0" & RG(3) & "0" & RG(2) & "0" & RG(1) & "0";
      GGB := RG;
    else          -- 
      Red   <= "11111" & "00000";
      Green <= "11011" & "00000";
      Blue  <= "10101" &"00000";
      
    end if;
  end process RGB_Display;

end Behavioral;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
--    Ball.vhd                                                           --
--    Viral Mehta                                                        --
--    Spring 2005                                                        --
--                                                                       --
--    Modified by Stephen Kempf 03-01-2006                               --
--                              03-12-2007                               --
--    Fall 2012 Distribution                                             --
--                                                                       --
--    For use with ECE 385 Lab 9                                         --
--    UIUC ECE Department                                                --
---------------------------------------------------------------------------
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ball is
   Port ( Reset : in std_logic;
        frame_clk : in std_logic;
        U : in std_logic;
        D : in std_logic;
        L : in std_logic;
        R : in std_logic;
    atk : in std_logic;
        Ball_X_posi, Ball_Y_posi: in std_logic_vector(9 downto 0);      
        BallX : out std_logic_vector(9 downto 0);
        BallY : out std_logic_vector(9 downto 0);
        BallS : out std_logic_vector(9 downto 0);
        BallMaps: out std_logic_vector(1 downto 0);
    Enemy1 : out std_logic_vector(25 downto 0);
    Enemy2 : out std_logic_vector(25 downto 0);
    Enemy3 : out std_logic_vector(25 downto 0));
end ball;
--Enemy  XPosition(10 bits) YPosition(10 bits) Health(2 bits) Enemy Type(4 bits) 
--Enemy type is just the block type for blocks 7,8,9 

architecture Behavioral of ball is

--Define initial status for Enemies
signal Map1En1_X, Map1En1_Y : std_logic_vector(9 downto 0);
signal Map1En1_Health  : std_logic_vector(1 downto 0) := "01";
signal Map1En1_Type  : std_logic_vector(3 downto 0);

signal Map1En2_X, Map1En2_Y : std_logic_vector(9 downto 0);
signal Map1En2_Health  : std_logic_vector(1 downto 0) := "10";
signal Map1En2_Type  : std_logic_vector(3 downto 0) := "1000";

signal Map1En3_X, Map1En3_Y : std_logic_vector(9 downto 0);
signal Map1En3_Health  : std_logic_vector(1 downto 0) := "01";
signal Map1En3_Type  : std_logic_vector(3 downto 0) := "1001";

signal Map2En1_X, Map2En1_Y : std_logic_vector(9 downto 0);
signal Map2En1_Health  : std_logic_vector(1 downto 0) := "01";
signal Map2En1_Type  : std_logic_vector(3 downto 0) := "0111";

signal Map2En2_X, Map2En2_Y : std_logic_vector(9 downto 0);
signal Map2En2_Health  : std_logic_vector(1 downto 0) := "01";
signal Map2En2_Type  : std_logic_vector(3 downto 0) := "1000";

signal Map2En3_X, Map2En3_Y : std_logic_vector(9 downto 0);
signal Map2En3_Health  : std_logic_vector(1 downto 0) := "01";
signal Map2En3_Type  : std_logic_vector(3 downto 0) := "1001";

signal Map3En1_X, Map3En1_Y : std_logic_vector(9 downto 0);
signal Map3En1_Health  : std_logic_vector(1 downto 0) := "01";
signal Map3En1_Type  : std_logic_vector(3 downto 0) := "0111";

signal Map3En2_X, Map3En2_Y : std_logic_vector(9 downto 0);
signal Map3En2_Health  : std_logic_vector(1 downto 0) := "01";
signal Map3En2_Type  : std_logic_vector(3 downto 0) := "1000";

signal Map3En3_X, Map3En3_Y : std_logic_vector(9 downto 0);
signal Map3En3_Health  : std_logic_vector(1 downto 0) := "01";
signal Map3En3_Type  : std_logic_vector(3 downto 0) := "1001";

signal Map4En1_X, Map4En1_Y : std_logic_vector(9 downto 0);
signal Map4En1_Health  : std_logic_vector(1 downto 0) := "01";
signal Map4En1_Type  : std_logic_vector(3 downto 0) := "0111";

signal Map4En2_X, Map4En2_Y : std_logic_vector(9 downto 0);
signal Map4En2_Health  : std_logic_vector(1 downto 0) := "01";
signal Map4En2_Type  : std_logic_vector(3 downto 0) := "1000";

signal Map4En3_X, Map4En3_Y : std_logic_vector(9 downto 0);
signal Map4En3_Health  : std_logic_vector(1 downto 0) := "01";
signal Map4En3_Type  : std_logic_vector(3 downto 0) := "1001";


signal Ball_X_pos, Ball_X_motion, Ball_Y_pos, Ball_Y_motion : std_logic_vector(9 downto 0);
signal sleft, sright, sup, sdown : std_logic;
signal maps : std_logic_vector(1 downto 0);

signal Ball_Size : std_logic_vector(9 downto 0);

type int_array is array (integer range <>) of integer;
--Map Arrays that hold what type of block goes into each section. 
--Size of 32 by 32
--This translates out to 640 by 480
  signal map0 :int_array(0 to 299):=(
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 8, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
  signal map1 :int_array(0 to 299):=(
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 8, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 3, 3, 4, 4, 3, 3, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 9, 1, 1, 1, 1, 1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0);
  signal map2 :int_array(0 to 299):=(
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 2, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 2, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 2, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 2, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  signal map3 :int_array(0 to 299):=(
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 9, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 8, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  

signal Ball_X_Max2,Ball_Y_Max2,Ball_X_Min2,Ball_Y_Min2 : std_logic_vector(9 downto 0); 


--signal frame_clk_div : std_logic_vector(5 downto 0);
--Enemy 1 must be of block type 7
--Enemy 2 must be of block type 8
--Enemy 3 must be of block type 9

--The Enemy's Starting coordinates are the same as the coordinates as where they are drawn on the 15x20 map
--So for Map 1, Enemy 1's X and Y must be the same coordinates as Block type 7 on map 1
constant M1E1_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(9*32, 10);
constant M1E1_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(2*32, 10);

constant M1E2_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(16*32, 10);
constant M1E2_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(8*32, 10);

constant M1E3_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(11*32, 10);
constant M1E3_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(13*32, 10);

constant M2E1_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(3*32, 10);
constant M2E1_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(2*32, 10);

constant M2E2_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(17*32, 10);
constant M2E2_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(2*32, 10);

constant M2E3_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(2*32, 10);
constant M2E3_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(12*32, 10);

constant M3E1_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(17*32, 10);
constant M3E1_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(11*32, 10);

constant M3E2_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(3*32, 10);
constant M3E2_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(11*32, 10);

constant M3E3_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(18*32, 10);
constant M3E3_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(1*32, 10);

constant M4E1_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(17*32, 10);
constant M4E1_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(1*32, 10);

constant M4E2_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(5*32, 10);
constant M4E2_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(10*32, 10);

constant M4E3_X        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(3*32, 10);
constant M4E3_Y        : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(4*32, 10);

constant Ball_X_Center : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(320, 10);  --Center position on the X axis
constant Ball_Y_Center : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(240, 10);  --Center position on the Y axis

constant Ball_X_Min    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);  --Leftmost point on the X axis
constant Ball_X_Max    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(639, 10);  --Rightmost point on the X axis
constant Ball_Y_Min    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(0, 10);   --Topmost point on the Y axis
constant Ball_Y_Max    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(479, 10);  --Bottommost point on the Y axis
                              
constant Ball_X_Step   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(2, 10);  --Step size on the X axis
constant Ball_Y_Step   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(2, 10);  --Step size on the Y axis

begin
  Ball_Size <= CONV_STD_LOGIC_VECTOR(32, 10); -- assigns the value 4 as a 10-digit binary number, ie "0000000100"




 Move_Ball: process(Reset, frame_clk, Ball_Size, U ,D, L, R)
--Temporary variables used to keep track of some calculated position
variable tempX, tempY: std_logic_vector(9 downto 0);
variable xcoord, ycoord, values, value2, value3:integer;
variable blocktype1, blocktype2, blocktype3: std_logic_vector(3 downto 0);
variable stop : std_logic := '0';
--Direction is determined by what the last key input was. IE if the user press 'W' last, the last direction was up.
--dir   key    translated
--UP     'W'       00
--DOWN     'S'       01
--LEFT     'A'       10
--RIGHT     'D'       11
variable dir : std_logic_vector(1 downto 0);
  begin
	  blocktype1 := "0001";
	  blocktype2 := "0001"; 
  
    if(Reset = '1') then   --Asynchronous Reset
	--Reset positions and status of all ememies and characters.
      Ball_Y_Motion <= "0000000000";
      Ball_X_Motion <= "0000000000";
      Ball_Y_Pos <= Ball_Y_Center;
      Ball_X_pos <= Ball_X_Center;
      sleft <= '0';
      sright <= '0';
      sup <= '0';
      sdown <= '0';
      maps <= "00";
      Map1En1_X <= M1E1_X;
      Map1En1_Y <= M1E1_Y;
      Map1En2_X <= M1E2_X;
      Map1En2_Y <= M1E2_Y;
      Map1En3_X <= M1E3_X;
      Map1En3_Y <= M1E3_Y;
      
      Map2En1_X <= M2E1_X;
      Map2En1_Y <= M2E1_Y;
      Map2En2_X <= M2E2_X;
      Map2En2_Y <= M2E2_Y;
      Map2En3_X <= M2E3_X;
      Map2En3_Y <= M2E3_Y;
      
      Map3En1_X <= M3E1_X;
      Map3En1_Y <= M3E1_Y;
      Map3En2_X <= M3E2_X;
      Map3En2_Y <= M3E2_Y;
      Map3En3_X <= M3E3_X;
      Map3En3_Y <= M3E3_Y;
      
      
      Map1En1_Health <= "01";
      Map1En2_Health <= "01";
      Map1En3_Health <= "01";
      
      Map2En1_Health <= "01";
      Map2En2_Health <= "01";
      Map2En3_Health <= "01";
      
      Map3En1_Health <= "01";
      Map3En2_Health <= "01";
      Map3En3_Health <= "01";

		
	 


     --Define how the ball moves with certain inputs
    elsif(rising_edge(frame_clk)) then
    case maps is 
--		when "00" =>
--			Ball_X_Max2 <= Ball_X_Max;
--			Ball_Y_Max2 <= Ball_Y_Max;
--			Ball_X_Min2 <= Ball_X_Min + "0000100000";
--			Ball_Y_Min2 <= Ball_Y_Min + "0000100000";
--		when "01" =>
--			Ball_X_Max2 <= Ball_X_Max - "0000100000";
--			Ball_Y_Max2 <= Ball_Y_Max;
--			Ball_X_Min2 <= Ball_X_Min;
--			Ball_Y_Min2 <= Ball_Y_Min + "0000100000";
--		when "10" =>
--			Ball_X_Max2 <= Ball_X_Max;
--			Ball_Y_Max2 <= Ball_Y_Max - "0000100000";
--			Ball_X_Min2 <= Ball_X_Min;
--			Ball_Y_Min2 <= Ball_Y_Min + "0000100000";
--		when "11" =>
--			Ball_X_Max2 <= Ball_X_Max - "0000100000";
--			Ball_Y_Max2 <= Ball_Y_Max - "0000100000";
--			Ball_X_Min2 <= Ball_X_Min;
--			Ball_Y_Min2 <= Ball_Y_Min;
    when others =>
      Ball_X_Max2 <= Ball_X_Max;
      Ball_Y_Max2 <= Ball_Y_Max;
      Ball_X_Min2 <= Ball_X_Min;
      Ball_Y_Min2 <= Ball_Y_Min;
    end case;
      if(Ball_Y_Pos + Ball_Size >= Ball_Y_Max2) then -- Ball is at the bottom edge, BOUNCE!
        Ball_Y_Motion <= not(Ball_Y_Step) +'1'; --2's complement.
        Ball_X_Motion <= "0000000000";
	  if(maps = "00" OR maps = "01") then -- If you are at top left map or top right map and you hit the bottom of the map, shift down to the next map
        sdown <='1';
      end if;
      elsif(Ball_Y_Pos - '1' = Ball_Y_Min2) then  -- Ball is at the top edge, BOUNCE!
        Ball_Y_Motion <= Ball_Y_Step;
        Ball_X_Motion <= "0000000000"; 
      if(maps = "10" OR maps = "11") then  -- If you are at bottom left map or bottom right map and you hit the topof the map, shift up to the next map
        sup <= '1';
      end if;
    elsif (Ball_X_Pos + Ball_Size >= Ball_X_Max2) then -- Ball is at the right edge, BOUNCE!
        --Ball_X_Motion <= not(Ball_X_Step) + '1'; --2's complement.
        Ball_Y_Motion <= "0000000000";
    if(maps = "00" OR maps = "10") then  -- If you are at top left map or bottom left map and you hit the bottom of the map, shift right to the next map
      sright <= '1';
    end if;
      elsif(Ball_X_Pos - '1' = Ball_X_Min2) then  -- Ball is at the left edge, BOUNCE!
        Ball_X_Motion <= Ball_X_Step;
        Ball_Y_Motion <= "0000000000";
    if(maps = "01" OR maps = "11") then  -- If you are at top right map or bottom right map and you hit the bottom of the map, shift leftto the next map
      sleft <= '1';
    end if; 

    elsif(U = '1') then --If key press is '1', move up 1 pixel
    Ball_Y_Motion <= not(Ball_Y_Step)+ '1';
    Ball_X_Motion <= "0000000000";
    dir := "00"; --set looking direction to up
    elsif(D = '1') then  --If key press is '1', move down 1 pixel
    Ball_Y_Motion <= Ball_Y_Step;
    Ball_X_Motion <= "0000000000"; 
        dir := "01";    --set looking direction to down
      elsif(R = '1') then  --If key press is '1', move right 1 pixel
    Ball_X_Motion <= Ball_X_Step;
    Ball_Y_Motion <= "0000000000";
    dir := "10";  --set looking direction to right
    elsif(L = '1') then  --If key press is '1', move left 1 pixel
    Ball_X_Motion <= not(Ball_X_Step) + 1;
    Ball_Y_Motion <= "0000000000";
    dir := "11"; --set looking direction to left
      else
        Ball_Y_Motion <= "0000000000"; -- Ball is somewhere, no movement
        Ball_X_Motion <= "0000000000"; -- Ball is somewhere, no movement
      end if;
    
   --   Ball_X_Motion <= Ball_X_Motion; -- You need to remove this and make both X and Y respond to keyboard input

      
      
       --This Large if statement is used to determine if the next block up is a block that you can walk through depending on user inputed direction
      if(U = '1') then   
      tempX := Ball_X_pos(9 downto 5) & "00100"; --Takes in the X position of the User
    xcoord := conv_integer(unsigned(tempX))/32;  --And converts it into a integer value to enter into the map array
    tempY := Ball_Y_pos(9 downto 5) & "00100";   --Takes in the y position of the User
    ycoord := conv_integer(unsigned(tempY))/32;  --And converts it into an integer value to enter into the map array
    values := ycoord*20+xcoord;
    tempX := Ball_X_pos(9 downto 5) & "00100" + "100000"; --Takes in the opposite corner of the User position
							  --This is done to prevent the block to go through another block because the origin is on the top left instead of the middle
    xcoord := conv_integer(unsigned(tempX))/32;
    value2 := ycoord*20+xcoord;
    if(xcoord < 20 AND ycoord < 15) then
	--Finds the Block type at that X,Y coordinate 
        case maps is
          when "00" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map0(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map0(value2), 4);
          when "01" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map1(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map1(value2), 4);
          when "10" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map2(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map2(value2), 4);
          when "11" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map3(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map3(value2), 4);
          when others=>
			blocktype1 := "0001";
			blocktype2 := "0001";
        end case;
    end if;
    --if the block type is passable, do nothing
    case blocktype1 is
      when "0001" =>
      when "0100" =>
      when others =>
        stop := '1';  --if not stop movement. 
    end case;
    case blocktype2 is
      when "0001" =>
      when "0100" =>
      when others =>
        stop := '1'; -- This case prevents block glitches due to position of origin
    end case;
    elsif(D = '1') then --Same as before
      tempX := Ball_X_pos(9 downto 5) & "00100";
    xcoord := conv_integer(unsigned(tempX))/32;
    tempY := Ball_Y_pos(9 downto 5) & "00100" + "100000";
    ycoord := conv_integer(unsigned(tempY))/32;
    values := ycoord*20+xcoord;
    tempX := Ball_X_pos(9 downto 5) & "00100" + "100000";
    xcoord := conv_integer(unsigned(tempX))/32;
    value2 := ycoord*20+xcoord;
    if(xcoord < 20 AND ycoord < 15) then
        case maps is
          when "00" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map0(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map0(value2), 4);
          when "01" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map1(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map1(value2), 4);
          when "10" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map2(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map2(value2), 4);
          when "11" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map3(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map3(value2), 4);
          when others=>
			blocktype1 := "0001";
			blocktype2 := "0001"; 
        end case;
    end if;
    case blocktype1 is
      when "0001" =>
      when "0100" =>
      when others =>
        stop := '1';
    end case;
    case blocktype2 is
      when "0001" =>
      when "0100" =>
      when others =>
        stop := '1';
    end case;
    elsif(R = '1') then--Same as before
      tempX := Ball_X_pos(9 downto 5) & "00100" + "100000";
    xcoord := conv_integer(unsigned(tempX))/32;
    tempY := Ball_Y_pos(9 downto 5) & "00100";
    ycoord := conv_integer(unsigned(tempY))/32;
    values := ycoord*20+xcoord;
    tempY := Ball_Y_pos(9 downto 5) & "00100" + "100000";
    ycoord := conv_integer(unsigned(tempY))/32;
    value2 := ycoord*20+xcoord;
    if(xcoord < 20 AND ycoord < 15) then
        case maps is
          when "00" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map0(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map0(value2), 4);
          when "01" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map1(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map1(value2), 4);
          when "10" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map2(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map2(value2), 4);
          when "11" =>
            blocktype1 := CONV_STD_LOGIC_VECTOR(map3(values), 4);
            blocktype2 := CONV_STD_LOGIC_VECTOR(map3(value2), 4);
          when others=>
			blocktype1 := "0001";
			blocktype2 := "0001"; 
        end case;
    end if;
    case blocktype1 is
      when "0001" =>
      when "0100" =>
      when others =>
        stop := '1';
    end case;
    case blocktype2 is
      when "0001" =>
      when "0100" =>
      when others =>
        stop := '1';
    end case;
    elsif(L = '1') then--Same as before
		tempX := Ball_X_pos(9 downto 5) & "00100";
		xcoord := conv_integer(unsigned(tempX))/32;
		tempY := Ball_Y_pos(9 downto 5) & "00100";
		ycoord := conv_integer(unsigned(tempY))/32;
		values := ycoord*20+xcoord;
		tempY := Ball_Y_pos(9 downto 5) & "00100" + "100000";
		ycoord := conv_integer(unsigned(tempY))/32;
		value2 := ycoord*20+xcoord;
		if(xcoord < 20 AND ycoord < 15) then
				case maps is
					when "00" =>
						blocktype1 := CONV_STD_LOGIC_VECTOR(map0(values), 4);
						blocktype2 := CONV_STD_LOGIC_VECTOR(map0(value2), 4);
					when "01" =>
						blocktype1 := CONV_STD_LOGIC_VECTOR(map1(values), 4);
						blocktype2 := CONV_STD_LOGIC_VECTOR(map1(value2), 4);
					when "10" =>
						blocktype1 := CONV_STD_LOGIC_VECTOR(map2(values), 4);
						blocktype2 := CONV_STD_LOGIC_VECTOR(map2(value2), 4);
					when "11" =>
						blocktype1 := CONV_STD_LOGIC_VECTOR(map3(values), 4);
						blocktype2 := CONV_STD_LOGIC_VECTOR(map3(value2), 4);
					when others=>
						blocktype1 := "0001";
						blocktype2 := "0001"; 	
				end case;
		end if;
		case blocktype1 is
			when "0001" =>
			when "0100" =>
			when others =>
				stop := '1';
		end case;
		case blocktype2 is
			when "0001" =>
			when "0100" =>
			when others =>
				stop := '1';
		end case;
	  end if;
	  if(stop = '1') then
		stop := '0';
		Ball_X_Motion <= "0000000000";
		Ball_Y_Motion <= "0000000000";
	  end if;
	  
	  if(atk = '1') then --Checks if user is attacking
		--Checks for different directions of attack	
		case dir is
			when "00" => --UP
				--checks the block straight ahead of the block the user is currently at. 
				tempX := Ball_X_pos(9 downto 5) & "00100" + "100000";
				xcoord := conv_integer(unsigned(tempX))/32;
				tempY := Ball_Y_pos(9 downto 5) & "10000";
				ycoord := conv_integer(unsigned(tempY))/32;
				values := ycoord*20+xcoord;
				if(xcoord < 20 AND ycoord < 15) then
					case maps is
						when "00" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map0(values), 4);
						when "01" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map1(values), 4);
						when "10" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map2(values), 4);
						when "11" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map3(values), 4);
						when others=>
						
							blocktype1 := "0001";
							blocktype2 := "0001"; 
					end case;
				end if;
				case blocktype1 is
					--If the user hits a block that is a enemy( block 7,8,9) then the enemy will take a point of damage depending on which map the enemy is on.
					when "0111" =>
							case maps is
								when "00" =>
									Map1En1_Health <= Map1En1_Health - '1';
								when "01" =>
									Map2En1_Health <= Map2En1_Health - '1';
								when "10" =>
									Map3En1_Health <= Map3En1_Health - '1';
								when "11" =>
									Map4En1_Health <= Map3En1_Health - '1';
							end case;
					when "1000" =>
							case maps is
								when "00" =>
									Map1En2_Health <= Map1En2_Health - '1';
								when "01" =>
									Map2En2_Health <= Map2En2_Health - '1';
								when "10" =>
									Map3En2_Health <= Map3En2_Health - '1';
								when "11" =>
									Map4En2_Health <= Map3En2_Health - '1';
							end case;
					
					when "1001" =>
							case maps is
								when "00" =>
									Map1En3_Health <= Map1En3_Health - '1';
								when "01" =>
									Map2En3_Health <= Map2En3_Health - '1';
								when "10" =>
									Map3En3_Health <= Map3En3_Health - '1';
								when "11" =>
									Map4En3_Health <= Map3En3_Health - '1';
							end case;
					when others =>
				end case;
			when "01" => -- DOWN
				tempX := Ball_X_pos(9 downto 5) & "10000" ;
				xcoord := conv_integer(unsigned(tempX))/32;
				tempY := Ball_Y_pos(9 downto 5) & "00100" + "100000";
				ycoord := conv_integer(unsigned(tempY))/32;
				values := ycoord*20+xcoord;
				if(xcoord < 20 AND ycoord < 15) then
					case maps is
						when "00" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map0(values), 4);
						when "01" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map1(values), 4);
						when "10" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map2(values), 4);
						when "11" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map3(values), 4);
						when others=>
						
							blocktype1 := "0001";
							blocktype2 := "0001"; 	
					end case;
				end if;
				case blocktype1 is
					when "0111" =>
							case maps is
								when "00" =>
									Map1En1_Health <= Map1En1_Health - '1';
								when "01" =>
									Map2En1_Health <= Map2En1_Health - '1';
								when "10" =>
									Map3En1_Health <= Map3En1_Health - '1';
								when "11" =>
									Map4En1_Health <= Map3En1_Health - '1';
							end case;
					when "1000" =>
							case maps is
								when "00" =>
									Map1En2_Health <= Map1En2_Health - '1';
								when "01" =>
									Map2En2_Health <= Map2En2_Health - '1';
								when "10" =>
									Map3En2_Health <= Map3En2_Health - '1';
								when "11" =>
									Map4En2_Health <= Map3En2_Health - '1';
							end case;
					
					when "1001" =>
							case maps is
								when "00" =>
									Map1En3_Health <= Map1En3_Health - '1';
								when "01" =>
									Map2En3_Health <= Map2En3_Health - '1';
								when "10" =>
									Map3En3_Health <= Map3En3_Health - '1';
								when "11" =>
									Map4En3_Health <= Map3En3_Health - '1';
							end case;
					when others =>
				end case;
			when "10" => --LEFT
				tempX := Ball_X_pos(9 downto 5) & "00100" ;
				xcoord := conv_integer(unsigned(tempX))/32;
				tempY := Ball_Y_pos(9 downto 5) & "00100" + "100000";
				ycoord := conv_integer(unsigned(tempY))/32;
				values := ycoord*20+xcoord;
				if(xcoord < 20 AND ycoord < 15) then
					case maps is
						when "00" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map0(values), 4);
						when "01" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map1(values), 4);
						when "10" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map2(values), 4);
						when "11" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map3(values), 4);
						 when others=>
							blocktype1 := "0001";
							blocktype2 := "0001"; 	
					end case;
				end if;
				case blocktype1 is
					when "0111" =>
							case maps is
								when "00" =>
									Map1En1_Health <= Map1En1_Health - '1';
								when "01" =>
									Map2En1_Health <= Map2En1_Health - '1';
								when "10" =>
									Map3En1_Health <= Map3En1_Health - '1';
								when "11" =>
									Map4En1_Health <= Map3En1_Health - '1';
							end case;
					when "1000" =>
							case maps is
								when "00" =>
									Map1En2_Health <= Map1En2_Health - '1';
								when "01" =>
									Map2En2_Health <= Map2En2_Health - '1';
								when "10" =>
									Map3En2_Health <= Map3En2_Health - '1';
								when "11" =>
									Map4En2_Health <= Map3En2_Health - '1';
							end case;
					
					when "1001" =>
							case maps is
								when "00" =>
									Map1En3_Health <= Map1En3_Health - '1';
								when "01" =>
									Map2En3_Health <= Map2En3_Health - '1';
								when "10" =>
									Map3En3_Health <= Map3En3_Health - '1';
								when "11" =>
									Map4En3_Health <= Map3En3_Health - '1';
							end case;
					when others =>
				end case;
			when "11" =>  --RIGHT
				tempX := Ball_X_pos(9 downto 5) & "00100" + "10000";
				xcoord := conv_integer(unsigned(tempX))/32;
				tempY := Ball_Y_pos(9 downto 5) & "00100";
				ycoord := conv_integer(unsigned(tempY))/32;
				values := ycoord*20+xcoord;
				if(xcoord < 20 AND ycoord < 15) then
					case maps is
						when "00" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map0(values), 4);
						when "01" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map1(values), 4);
						when "10" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map2(values), 4);
						when "11" =>
							blocktype1 := CONV_STD_LOGIC_VECTOR(map3(values), 4);
						when others=>
							blocktype1 := "0001";
							blocktype2 := "0001"; 	
					end case;
				end if;
				case blocktype1 is
					when "0111" =>
							case maps is
								when "00" =>
									Map1En1_Health <= Map1En1_Health - '1';
								when "01" =>
									Map2En1_Health <= Map2En1_Health - '1';
								when "10" =>
									Map3En1_Health <= Map3En1_Health - '1';
								when "11" =>
									Map4En1_Health <= Map3En1_Health - '1';
							end case;
					when "1000" =>
							case maps is
								when "00" =>
									Map1En2_Health <= Map1En2_Health - '1';
								when "01" =>
									Map2En2_Health <= Map2En2_Health - '1';
								when "10" =>
									Map3En2_Health <= Map3En2_Health - '1';
								when "11" =>
									Map4En2_Health <= Map3En2_Health - '1';
							end case;
					
					when "1001" =>
							case maps is
								when "00" =>
									Map1En3_Health <= Map1En3_Health - '1';
								when "01" =>
									Map2En3_Health <= Map2En3_Health - '1';
								when "10" =>
									Map3En3_Health <= Map3En3_Health - '1';
								when "11" =>
									Map4En3_Health <= Map3En3_Health - '1';
							end case;
					when others =>
				end case;
		end case;
	  end if;
	  
	  Ball_Y_pos <= Ball_Y_pos + Ball_Y_Motion; -- Update ball position 
          Ball_X_pos <= Ball_X_pos + Ball_X_Motion;
	  
	  --If the user was at a border of the map and the border was passable into another map, logic to deal with that done here
	  if(sdown = '1') then 
		if(maps = "00") then  
			maps <= "10";  --From map 1 to map3
		else
			maps <= "11";  --From map 2 to map4
		end if;
		Ball_Y_pos <= "0000100100"; --Set the User's Y position such that when the user crosses, he will end up being drawn at the top of the map instead of the bottom
					 	--which makes sense since he went from top to bottom
		sdown <= '0';			-- turn of map shifting
	  elsif(sup = '1') then --same as before
		if(maps = "10") then
			maps <= "00";
		else 
			maps <= "01";
		end if;
		Ball_Y_pos <= (Ball_Y_Max2 - "0000000010") - Ball_Size; -- Sets position from top of map to bottom
		sup <= '0';
	  elsif(sright = '1') then--same as before
		if(maps = "00") then
			maps <= "01";
		else 
			maps <= "11";
		end if;
		Ball_X_pos <= "0000100100";   --set from right side of map to the left
		sright <= '0';
	  elsif(sleft = '1') then--same as before
	    if(maps = "01") then
			maps <= "00";
		else 
			maps <= "10";
		end if;
		Ball_X_pos <= (Ball_X_Max2 - "0000000010") - Ball_Size;   --set from left side of map to the right
		sleft <= '0';
	  end if;
	--******************************************
	  --ATTENTION! Please answer the following quesiton in your lab report!
        -- Note that Ball_Y_Motion in the above statement may have been changed at the same clock edge
        --  that is causing the assignment of Ball_Y_pos.  Will the new value of Ball_Y_Motion be used,
        --  or the old?  How will this impact behavior of the ball during a bounce, and how might that 
        --  interact with a response to a keypress?  Can you fix it?  Give an answer in your postlab.
      --******************************************
	case maps is
		-- Output correct enemy depending on what the which map you are at
		when "00" =>
			Enemy1(25 downto 16) <= Map1En1_X;
			Enemy1(15 downto 6) <= Map1En1_Y;
			Enemy1(5 downto 4) <= Map1En1_Health;
			Enemy1(3 downto 0) <= Map1En1_Type;
			Enemy2(25 downto 16) <= Map1En2_X;
			Enemy2(15 downto 6) <= Map1En2_Y;
			Enemy2(5 downto 4) <= Map1En2_Health;
			Enemy2(3 downto 0) <= Map1En2_Type;
			Enemy3(25 downto 16) <= Map1En3_X;
			Enemy3(15 downto 6) <= Map1En3_Y;
			Enemy3(5 downto 4) <= Map1En3_Health;
			Enemy3(3 downto 0) <= Map1En3_Type;
		when "01" =>
			Enemy1(25 downto 16) <= Map2En1_X;
			Enemy1(15 downto 6) <= Map2En1_Y;
			Enemy1(5 downto 4) <= Map2En1_Health;
			Enemy1(3 downto 0) <= Map2En1_Type;
			Enemy2(25 downto 16) <= Map2En2_X;
			Enemy2(15 downto 6) <= Map2En2_Y;
			Enemy2(5 downto 4) <= Map2En2_Health;
			Enemy2(3 downto 0) <= Map2En2_Type;
			Enemy3(25 downto 16) <= Map2En3_X;
			Enemy3(15 downto 6) <= Map2En3_Y;
			Enemy3(5 downto 4) <= Map2En3_Health;
			Enemy3(3 downto 0) <= Map2En3_Type;
		when "10" =>
			Enemy1(25 downto 16) <= Map3En1_X;
			Enemy1(15 downto 6) <= Map3En1_Y;
			Enemy1(5 downto 4) <= Map3En1_Health;
			Enemy1(3 downto 0) <= Map3En1_Type;
			Enemy2(25 downto 16) <= Map3En2_X;
			Enemy2(15 downto 6) <= Map3En2_Y;
			Enemy2(5 downto 4) <= Map3En2_Health;
			Enemy2(3 downto 0) <= Map3En2_Type;
			Enemy3(25 downto 16) <= Map3En3_X;
			Enemy3(15 downto 6) <= Map3En3_Y;
			Enemy3(5 downto 4) <= Map3En3_Health;
			Enemy3(3 downto 0) <= Map3En3_Type;
		when "11" =>
			Enemy1(25 downto 16) <= Map4En1_X;
			Enemy1(15 downto 6) <= Map4En1_Y;
			Enemy1(5 downto 4) <= Map4En1_Health;
			Enemy1(3 downto 0) <= Map4En1_Type;
			Enemy2(25 downto 16) <= Map4En2_X;
			Enemy2(15 downto 6) <= Map4En2_Y;
			Enemy2(5 downto 4) <= Map4En2_Health;
			Enemy2(3 downto 0) <= Map4En2_Type;
			Enemy3(25 downto 16) <= Map4En3_X;
			Enemy3(15 downto 6) <= Map4En3_Y;
			Enemy3(5 downto 4) <= Map4En3_Health;
			Enemy3(3 downto 0) <= Map4En3_Type;
    end case;
  end if;
  
  end process Move_Ball;
  --Set outputs for the user
  BallMaps <= maps;
  BallX <= Ball_X_Pos;
  BallY <= Ball_Y_Pos;
  BallS <= Ball_Size;
 
end Behavioral;      
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity G25_LAB1 is
	Port ( clk : in std_logic;
	countbytwo : in std_logic;
	rst : in std_logic;
	enable : in std_logic;
	max_count : in std_logic_vector(15 downto 0);
	output : out std_logic_vector(15 downto 0));
end G25_LAB1;

architecture Behavioral of G25_LAB1 is

signal   count         : INTEGER RANGE 0 TO 65535;

begin

	process (clk, rst,countbytwo, max_count, enable)
		
		variable     max_count_int : INTEGER RANGE 0 TO 65535;
	begin
		max_count_int := to_integer(unsigned(max_count));
		if (CLK'Event and CLK = '1') then
			-- check if enabled
			if enable = '1' then
				-- check if counting 1 or 2
				if countbytwo = '1' then
					count <= count +2;
					-- use modulation to loop curent counter back
					count <= count mod max_count_int;
				else
					count<= count +1;
					-- use modulation to loop curent counter back
					count <= count mod max_count_int;
				end if;
				
			elsif (rst = '1') then
				count <=0;
				

			end if;
			
         
		end if;
		
		
	
		
		output <=  std_logic_vector(to_unsigned(count, output'length));
	end process;
    
   


end Behavioral;
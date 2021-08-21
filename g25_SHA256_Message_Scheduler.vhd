LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity g25_SHA256_Message_Scheduler is
 port (
	clk : in std_logic;
	M_i : in std_logic_vector(31 downto 0);
	ld_i:	in std_logic;
	Wt_o:	out std_logic_vector(31 downto 0)
 );
end g25_SHA256_Message_Scheduler;

architecture implementation of g25_SHA256_Message_Scheduler is

signal reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15: std_logic_vector(31 downto 0);
signal W_out: std_logic_vector(31 downto 0);
signal sig_0, sig_1: std_logic_vector(31 downto 0);
signal inter: std_logic_vector(31 downto 0);

begin
	
	sig_0 <= (std_logic_vector(rotate_right(unsigned(reg_14),7)) 
			xor std_logic_vector(rotate_right(unsigned(reg_14), 18))) 
			xor std_logic_vector(shift_right(unsigned(reg_14), 3));
	
	sig_1 <= (std_logic_vector(rotate_right(unsigned(reg_1),17)) 
			xor std_logic_vector(rotate_right(unsigned(reg_1), 19))) 
			xor std_logic_vector(shift_right(unsigned(reg_1), 10));
	W_out <= sig_1 AND reg_6 AND sig_0 AND reg_15;
	
	Wt_o <= M_i when (ld_i = '1') else W_out;
	inter <= M_i when (ld_i = '1') else W_out;
	process(clk) 
	begin
		if(rising_edge(clk)) then	
		reg_15 <= reg_14;
		reg_14 <= reg_13;
		reg_13 <= reg_12;
		reg_12 <= reg_11;
		reg_11 <= reg_10;
		reg_10 <= reg_9;
		reg_9 <= reg_8;
		reg_8 <= reg_7;
		reg_7 <= reg_6;
		reg_6 <= reg_5;
		reg_5 <= reg_4;
		reg_4 <= reg_3;
		reg_3 <= reg_2;
		reg_2 <= reg_1;
		reg_1 <= reg_0;
		reg_0 <= inter;
		end if;
	end process;
		
end implementation;
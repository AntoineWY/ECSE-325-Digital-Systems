-- entity name: g25_lab2
-- Version 1.0
-- Authors: YUJIE QIN, YICHENG SONG, Antonie Wang
-- Due Date: March 19, 2021

library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g25_SIG_CH_MAJ is
 port (A_o, B_o, C_o, E_o, F_o, G_o : in std_logic_vector(31 downto 0);
	SIG0, SIG1, CH, MAJ	    : out std_logic_vector(31 downto 0)
);
end g25_SIG_CH_MAJ;

architecture behaviour of g25_SIG_CH_MAJ is
begin
	SIG_0_process: process(A_o)
	begin
		SIG0 <= (std_logic_vector(rotate_right(unsigned(A_o),2)) 
			xor std_logic_vector(rotate_right(unsigned(A_o), 13))) 
			xor std_logic_vector(rotate_right(unsigned(A_o), 22));
	end process;
	
	SIG_1_process: process(E_o)
	begin
		SIG1 <= (std_logic_vector(rotate_right(unsigned(E_o), 6)) 
			xor std_logic_vector(rotate_right(unsigned(E_o), 11))) 
			xor std_logic_vector(rotate_right(unsigned(E_o), 25));
	end process;

 CH_process: process(E_o, F_o, G_o)
	begin
   CH <= (F_o and E_o) xor (not E_o and G_o);
	end process;

 MAJ_process: process(A_o, B_o, C_o)
	begin
   MAJ <= ((A_o and B_o) xor (B_o and C_o)) xor (C_o and A_o);
	end process;

end behaviour;	
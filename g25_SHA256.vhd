--
-- entity name: g25_SHA256
--
-- Version 1.0
-- YICHENG SONG, YINUO WANG, YUJIE QIN
-- Date: March 22, 2021

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g25_SHA256 is
 PORT (	clock, resetn: 				IN STD_LOGIC;
			read, write, chipselect: 	IN STD_LOGIC;
			address: 						IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			in_data: 						IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			out_data: 						OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
end g25_SHA256;


architecture lab3 of g25_SHA256 is

type message_array is array(0 to 15) of std_logic_vector(31 downto 0);
signal M : message_array;

type constant_array is array(0 to 63) of std_logic_vector(31 downto 0);
constant Kt : constant_array := ( x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5",
x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5", x"d807aa98", x"12835b01",
x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa",
x"5cb0a9dc", x"76f988da", x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7",
x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967", x"27b70a85", x"2e1b2138",
x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624",
x"f40e3585", x"106aa070", x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5",
x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3", x"748f82ee", x"78a5636f",
x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
);

signal Kt_sig : std_logic_vector(31 downto 0);
signal Wt : std_logic_vector(31 downto 0);

signal h0 : std_logic_vector(31 downto 0) := x"6a09e667"; -- initial hash values
signal h1 : std_logic_vector(31 downto 0) := x"bb67ae85";
signal h2 : std_logic_vector(31 downto 0) := x"3c6ef372";
signal h3 : std_logic_vector(31 downto 0) := x"a54ff53a";
signal h4 : std_logic_vector(31 downto 0) := x"510e527f";
signal h5 : std_logic_vector(31 downto 0) := x"9b05688c";
signal h6 : std_logic_vector(31 downto 0) := x"1f83d9ab";
signal h7 : std_logic_vector(31 downto 0) := x"5be0cd19";

type SHA_256_STATE is ( INIT, READ_M, RUN, UPDATE, OUTPUT);
signal state : SHA_256_STATE;

signal M_inter: std_logic_vector(31 downto 0);
signal A_o, B_o, C_o, D_o, E_o, F_o, G_o, H_o : std_logic_vector(31 downto 0);
signal LD : std_logic;
signal round_count : integer range 0 to 63;
signal read_count : integer range 0 to 15;
signal out_count : integer range 0 to 7;
signal ld_i : std_logic;


COMPONENT g25_Hash_Core
PORT (
	A_o, B_o, C_o, D_o, E_o, F_o, G_o, H_o : inout std_logic_vector(31 downto 0);
	A_i, B_i, C_i, D_i, E_i, F_i, G_i, H_i : in std_logic_vector(31 downto 0);
	Kt_i, Wt_i : in std_logic_vector(31 downto 0);
	LD, CLK : in std_logic
); 
END COMPONENT;

COMPONENT g25_SHA256_Message_Scheduler
PORT(
	clk : in std_logic;
	M_i : in std_logic_vector(31 downto 0);
	ld_i:	in std_logic;
	Wt_o:	out std_logic_vector(31 downto 0)
);
END COMPONENT;

begin

	ld_i <= '1' when (round_count < 16) else '0';

	i0 : g25_SHA256_Message_Scheduler
	PORT MAP(
	clk => clock, M_i => M_inter, ld_i => ld_i, Wt_o => Wt
	);
	
	
	i1 : g25_Hash_Core
	PORT MAP (A_o => A_o,B_o => B_o,C_o => C_o,D_o => D_o,E_o => E_o,
		F_o => F_o,G_o => G_o, H_o => H_o, A_i => h0,B_i => h1,C_i => h2,D_i => h3,
		E_i => h4,F_i => h5,G_i => h6,H_i => h7,Kt_i => Kt_sig,Wt_i => Wt,
		LD => LD, CLK => clock );
-- concatenate to form the 256 bit hash output
process(resetn, clock)
	begin
		
		if resetn = '1' then
			state <= INIT;		
	
		elsif rising_edge(clock) then
			case state is 
			when INIT =>
				read_count <= 0;
				round_count <= 0;
				out_count <= 0;
				LD <= '1';
				if read = '1' then
					state <= READ_M;
				end if;
			when READ_M =>
				M(read_count) <= in_data;				
				if read_count = 15 then
					state <= RUN;
				else 
					read_count <= read_count + 1;
				end if;
			when RUN =>
				LD <= '0';
				if round_count < 16 then
					M_inter <= M(round_count);
				end if;
				Kt_sig <= Kt(round_count);

				if round_count = 63 then
					LD <= '1';
					state <= UPDATE;
				else
					round_count <= round_count + 1;
				end if;
			when UPDATE =>
				h0 <= std_logic_vector(unsigned(h0) + unsigned(A_o));
				h1 <= std_logic_vector(unsigned(h1) + unsigned(B_o));
				h2 <= std_logic_vector(unsigned(h2) + unsigned(C_o));
				h3 <= std_logic_vector(unsigned(h3) + unsigned(D_o));
				h4 <= std_logic_vector(unsigned(h4) + unsigned(E_o));
				h5 <= std_logic_vector(unsigned(h5) + unsigned(F_o));
				h6 <= std_logic_vector(unsigned(h6) + unsigned(G_o));
				h7 <= std_logic_vector(unsigned(h7) + unsigned(H_o));
				state <= OUTPUT;				
			when OUTPUT =>
				if read = '1' then
					if out_count = 0 then
						out_data <= h0;
					elsif out_count = 1 then
						out_data <= h1;
					elsif out_count = 2 then
						out_data <= h2;
					elsif out_count = 3 then
						out_data <= h3;
					elsif out_count = 4 then
						out_data <= h4;
					elsif out_count = 5 then
						out_data <= h5;
					elsif out_count = 6 then
						out_data <= h6;
					else
						out_data <= h7;
					end if;
				end if;
				if out_count = 7 then
					state <= INIT;
				else
					out_count <= out_count + 1;
				end if;
			end case;
		end if;
end process;
end lab3;
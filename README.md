# ECSE-325-Digital-Systems
## Introduction

Completed as the course project of McGill ECSE 325 (Digital System), we
implement the SHA256 hashing function used in Bitcoin mining. This function
takes in a long message and compresses (hashes) it to a 256-bit message digest.
The hashing function is such that the original message is not easy (i.e. practically
impossible) to derive from the message digest. Several main goals includes:

1. Design of the message schedule circuit and the Avalon Slave interface
2. Run timing analysis to verify the circuit (Quartus platform)
3. Use Qsys to create the complete system, and
connect to the HPS Arm CPU
4. Simulation of hashing a single message block

Please check later "**system structure**" section for more details. More details about SHA-256 algorithm please refer [here](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf). [This page](https://medium.com/biffures/part-5-hashing-with-sha-256-4c2afc191c40) provides a nice inspiration about the SHA-256 hash core in another language (javascript).


## System Structure

### Hash Core
One of the main building blocks of the SHA256 system is the Hash Core Logic. This is the section where messages undergoes a series of rotations and concatenation operations, so a digest that is almost irreversible is generated. The diagram below shows the hash core signals and operations.


![Hashcore](https://github.com/AntoineWY/ECSE-325-Digital-Systems/blob/main/diagrams/hashcore%20-%20main.PNG)

The code section below describes the signal inputs and output of main hash core.

```vhdl
entity g25_Hash_Core is
 port (A_o, B_o, C_o, D_o, E_o, F_o, G_o, H_o : inout std_logic_vector (31 downto 0); 
			A_i, B_i, C_i, D_i, E_i, F_i, G_i, H_i: in std_logic_vector (31 downto 0);
				Kt_i, Wt_i : in std_logic_vector (31 downto 0);
					LD, CLK: in std_logic
					);
					
end g25_Hash_Core;

architecture implementation of g25_Hash_Core is

signal reg_a, reg_b, reg_c, reg_d, reg_e, reg_f, reg_g, reg_h : std_logic_vector(31 downto 0);
signal SIG0, SIG1, CH, MAJ : std_logic_vector(31 downto 0);
signal reg_a_0, reg_e_0 : std_logic_vector(31 downto 0);

component g25_SIG_CH_MAJ
	 port (A_o, B_o, C_o, E_o, F_o, G_o : in std_logic_vector(31 downto 0);
		SIG0, SIG1, CH, MAJ	    : out std_logic_vector(31 downto 0)
		);
end component;
```

To make the implementation more clear, "SIG_CH_MAJ" divides parts of the logic into another circuit which will be wired into the main hash core. The Maj function is the “Majority” operation, which outputs the bit value (0 or 1) that
is most common in the 3 inputs.
The Ch function is merely a 2-input multiplexer. Please check the diagrams and code below.

![maj](https://github.com/AntoineWY/ECSE-325-Digital-Systems/blob/main/diagrams/hashcore%20-%20maj.PNG)
![ch](https://github.com/AntoineWY/ECSE-325-Digital-Systems/blob/main/diagrams/hashcore%20-%20CH.PNG)

```vhdl
entity g25_SIG_CH_MAJ is
 port (A_o, B_o, C_o, E_o, F_o, G_o : in std_logic_vector(31 downto 0);
	SIG0, SIG1, CH, MAJ	    : out std_logic_vector(31 downto 0)
);
end g25_SIG_CH_MAJ;

```

### Kt_i and Wt_i signals
Two additional signals need to be fed in the main hash core logics. The
**Kt_i** i = 0,1,..63) are a set of 64 constant 32 bit values. The index i is
 the “ round_count".These magical numbers are the first 32 bits of the fractional parts of the
cube roots of the first 64 prime numbers.
These can be stored in a constant signal array, as shown in the following
VHDL snippet.
```vhdl
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

```

The
**Wt_i** array of 64 32-bit values is called the Message Schedule
It is created by mixing up and transforming the 32
bit words in the message
block as the hashing rounds proceed. The logic is illustrated by the diagram below.
![wt_i](https://github.com/AntoineWY/ECSE-325-Digital-Systems/blob/main/diagrams/wt-i.PNG)

Below displays the port mapping of the scheduler circuit logic.

```vhdl
entity g25_SHA256_Message_Scheduler is
 port (
	clk : in std_logic;
	M_i : in std_logic_vector(31 downto 0);
	ld_i:	in std_logic;
	Wt_o:	out std_logic_vector(31 downto 0)
 );
end g25_SHA256_Message_Scheduler;
```


## Usage
This project requires the use of [Quartus prime version 16.1](https://fpgasoftware.intel.com/16.1/?edition=lite) and 
[Platform Designer (Qsys)](https://www.intel.com/content/www/us/en/programmable/support/support-resources/design-software/qsys.html) to define the overall system structure. Below shows one of our result from the Qsys content plane.
![qsys](https://github.com/AntoineWY/ECSE-325-Digital-Systems/blob/main/diagrams/42_3.png)

Code snippet below is part of the port map generated in SHA256 system, connecting pins and interfaces from different sections of the hardware.


```vhdl
-- g25_SHA256_system.vhd

-- Generated using ACDS version 16.1 196

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity g25_SHA256_system is
	port (
		clk_clk                         : in    std_logic                     := '0';             --       clk.clk
		hex3_hex0_export                : out   std_logic_vector(31 downto 0);                    -- hex3_hex0.export
		hex5_hex4_export                : out   std_logic_vector(15 downto 0);                    -- hex5_hex4.export
		hps_io_hps_io_emac1_inst_TX_CLK : out   std_logic;                                        --    hps_io.hps_io_emac1_inst_TX_CLK
		hps_io_hps_io_emac1_inst_TXD0   : out   std_logic;                                        --          .hps_io_emac1_inst_TXD0
		hps_io_hps_io_emac1_inst_TXD1   : out   std_logic;                                        --          .hps_io_emac1_inst_TXD1
		hps_io_hps_io_emac1_inst_TXD2   : out   std_logic;                                        --          .hps_io_emac1_inst_TXD2
		hps_io_hps_io_emac1_inst_TXD3   : out   std_logic;     
...                                   --          

```

The entire compiled project is contained in this directory containing all compiled components, all code sections and the [Quartus header file](https://github.com/AntoineWY/ECSE-325-Digital-Systems/blob/main/g25_SHA256_system.qpf). Clone the project, make sure Quartus (above 16.1) is installed and click the **.qpf** to run the entire project.

## Result
We captured the test result below using the messaging example provided on website qvault.io.
We achieved the desired operating behavior. The circuit spent 16 cycles taking in 16 messages.
Then, 64 cycles after the calculation the hash result pop out in 8 cycles, 32-bit per cycle. Please refer to testing outputs provided below.

![test1](https://github.com/AntoineWY/ECSE-325-Digital-Systems/blob/main/diagrams/test_output_data.png)
![test2](https://github.com/AntoineWY/ECSE-325-Digital-Systems/blob/main/diagrams/test_output_data_2.png)

## License
Course content by [Prof J.Clark](http://www.cim.mcgill.ca/~clark/) at McGill University  

## Contributors
Yujie Qin (yujie.qin@mail.mcgill.ca)

Yicheng Song (yicheng.song@mail.mcgill.ca)

Yinuo Wang (yinuo.wang@mail.mcgill.ca)


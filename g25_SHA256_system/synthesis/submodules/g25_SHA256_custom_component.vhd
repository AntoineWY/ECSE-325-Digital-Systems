LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY g25_SHA256_custom_component IS
PORT (
	clock, resetn: 				IN STD_LOGIC;
	read, write, chipselect: 	IN STD_LOGIC;
	address: 						IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	writedata:						IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	readdata: 						OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);
END g25_SHA256_custom_component;

ARCHITECTURE Structure OF g25_SHA256_custom_component IS

SIGNAL to_component, from_component : STD_LOGIC_VECTOR(31 DOWNTO 0);

COMPONENT g25_SHA256 
	PORT (clock, resetn: 				IN STD_LOGIC;
			read, write, chipselect: 	IN STD_LOGIC;
			address: 						IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			in_data: 						IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			out_data: 						OUT STD_LOGIC_VECTOR(31 DOWNTO 0) );
END COMPONENT;

BEGIN
	to_component <= writedata;
	component_inst: g25_SHA256 PORT MAP (clock, resetn, read, write,
			chipselect, address, to_component, from_component);
	readdata <= from_component;
END Structure;
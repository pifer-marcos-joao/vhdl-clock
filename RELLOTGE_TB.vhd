library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity RELLOTGE_TB is
end RELLOTGE_TB;



architecture tb of RELLOTGE_TB is

component RELLOTGE
	port(CLK,SET, OK, UP, DOWN: in std_logic;
		SD: out std_logic_vector(3 downto 0);
		SSEG: out std_logic_vector(7 downto 0));
end component;

signal CLK,SET, OK, UP, DOWN:  std_logic:='0';
signal SD:  std_logic_vector(3 downto 0);
signal SSEG:  std_logic_vector(7 downto 0);
signal timebase : integer:=0;

begin
	uut: RELLOTGE port map(
		CLK => CLK,
		SET => SET,
		OK => OK,
		UP => UP,
		DOWN => DOWN,
		SSEG => SSEG,
		SD => SD);

	process
	begin
		wait for 5 ns;
		CLK <= not CLK;
		wait for 5 ns;
		CLK <= not CLK;

		if timebase = 100 then SET<='1'; end if;
		if timebase = 150 then SET<='0'; end if;

		if timebase = 2300 then UP<='1'; end if;
		if timebase = 2800 then UP<='0'; end if;
		
		if timebase = 4000 then SET<='1'; end if;
		if timebase = 9000 then SET<='0'; end if;
		

		

		if timebase = 13000 then UP<='1'; end if;
		if timebase = 14000 then UP<='0'; end if;

		if timebase = 16000 then UP<='1'; end if;
		if timebase = 17000 then UP<='0'; end if;
		
		
		if timebase = 20000 then DOWN<='1'; end if;
		if timebase = 22000 then DOWN<='0'; end if;

		if timebase = 24000 then DOWN<='1'; end if;
		if timebase = 26000 then DOWN<='0'; end if;

		if timebase = 28000 then DOWN<='1'; end if;
		if timebase = 30000 then DOWN<='0'; end if;

		if timebase = 32000 then DOWN<='1'; end if;
		if timebase = 45000 then DOWN<='0'; end if;

		if timebase = 50000 then OK<='1'; end if;
		if timebase = 51000 then OK<='0'; end if;
		
	
		timebase <= timebase + 1;
	end process;


end tb;
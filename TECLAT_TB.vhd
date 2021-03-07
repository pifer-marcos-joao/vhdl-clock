library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;


entity TECLAT_TB is
end TECLAT_TB;


architecture beh of TECLAT_TB is

	component TECLAT
	Port (CLK,SET, OK, UP, DOWN: in std_logic;
		TECLA: out std_logic_vector(3 downto 0));
	end component;

signal CLK,SET, OK, UP, DOWN: std_logic := '0';
signal TECLA: std_logic_vector(3 downto 0):= (others=>'0');
signal timebase : integer:=0;

begin
	uut: TECLAT port map(
		CLK => CLK,
		SET => SET,
		OK => OK,
		UP => UP,
		TECLA=>TECLA,
		DOWN => DOWN);
	process
	begin
		wait for 5 ns;
		CLK <= not CLK;
		wait for 5 ns;
		CLK <= not CLK;

		if timebase = 100 then SET<='1'; end if;
		if timebase = 150 then SET<='0'; end if;
		
		if timebase = 4000 then SET<='1'; end if;
		if timebase = 9000 then SET<='0'; end if;
		

		if timebase = 800 then UP<='1'; end if;
		if timebase = 1000 then UP<='0'; end if;
		
		if timebase = 5000 then UP<='1'; end if;
		if timebase = 20000 then UP<='0'; end if;
	
		timebase <= timebase + 1;
	end process;

end beh;
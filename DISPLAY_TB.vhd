library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;


entity DISPLAY_TB is
end DISPLAY_TB;


architecture beh of DISPLAY_TB is

	component DISPLAY
	Port (	CLK,ENABLE: in std_logic;
		SD: out std_logic_vector(3 downto 0);
		SSEG: out std_logic_vector(7 downto 0));
	end component;

signal CLK,ENABLE: std_logic := '0';
signal SD:  std_logic_vector(3 downto 0):= (others=>'0');
signal SSEG:  std_logic_vector(7 downto 0):= (others=>'0');
signal timebase : integer:=0;



begin
	uut: DISPLAY port map(
		CLK => CLK,
		SSEG => SSEG,
		SD => SD,
		ENABLE=>ENABLE
		);
	process
	begin
		wait for 5 ns;
		CLK <= not CLK;
		wait for 5 ns;
		CLK <= not CLK;

		if timebase = 100 then ENABLE<='1';end if;
		timebase <= timebase + 1;
	end process;

end beh;

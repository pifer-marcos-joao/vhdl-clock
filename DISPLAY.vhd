
-- Declaració de llibreries

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity DISPLAY is

	Port (	CLK,ENABLE: in std_logic;
		M0,M1,H0,H1: in std_logic_vector(3 downto 0);
		SD: out std_logic_vector(3 downto 0);
		SSEG: out std_logic_vector(7 downto 0));

end DISPLAY;

architecture beh of DISPLAY is

signal presc_200hz: std_logic:= '0';
signal presc_1hz: std_logic:= '0';
signal SECS: std_logic:= '0';

signal SSEG_AUX: std_logic_vector(6 downto 0):= (others=>'0');
signal c500k: std_logic_vector(18 downto 0):= (others=>'0');
signal c100M: std_logic_vector(27 downto 0):= (others=>'0');

--signal M0,M1,H0,H1: std_logic_vector(3 downto 0); -- se pueden separar
signal c_xif: std_logic_vector(2 downto 0):= (others=>'0');
signal number: std_logic_vector(3 downto 0):= (others=>'0');


begin



-- Prescaler de 1 Hz

presc_1hz_process: process(CLK)
begin
	if (CLK='1' and CLK'event)then
		
		if c100M = 49999999 then --49999999
			presc_1hz<='1';
			c100M<=c100M+1;
			
		elsif c100M = 99999999 then --99999999
			presc_1hz<='0';
			c100M<=(others=>'0');
		else
			c100M<=c100M+1;
		end if;
	end if;
end process;


presc_200hz_process: process(CLK)
begin
	if (CLK='1' and CLK'event)then
		if c500k = 499999 then
			presc_200hz<='1';
			c500k<=(others=>'0');
		else
			c500k<=c500k+1;
			presc_200hz<='0';
		end if;
	end if;
end process;



c_xif_process: process(CLK)
begin
	if (CLK='1' and CLK'event)then
		if presc_200hz='1' then
			if c_xif=3 then
				c_xif<=(others=>'0');
			else
				c_xif<= c_xif+1;
			end if; 
		end if;
	end if;
end process;


with c_xif select SD <=
	
	"1110" when "000",
	"1101" when "001",
	"1011" when "010",
	"0111" when "011",
	"1111" when others;


with c_xif select number <=
	
	M0 when "000",
	M1 when "001",
	H0 when "010",
	H1 when "011",
	"1111" when others;



with number select SSEG_AUX <=

	"0000001" when "0000" , --0
	"1001111" when "0001" , --1
	"0010010" when "0010" , --2
	"0000110" when "0011" , --3
	"1001100" when "0100" , --4
	"0100100" when "0101" , --5
	"1100000" when "0110" , --6
	"0001111" when "0111" , --7
	"0000000" when "1000" , --8
	"0001100" when "1001" , --9
	"1111111" when others;


SECS <= '0' when (presc_1hz='1' and c_xif=2) else '1';


SSEG <= SSEG_AUX & SECS when enable='1' else "11111111";

end beh;










-- Declaració de llibreries

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;


entity TECLAT is
	Port (  CLK,SET, OK, UP, DOWN: in std_logic;
		TECLA: out std_logic_vector(3 downto 0));

end TECLAT;

architecture beh of TECLAT is

-- FSM que controla el comportament basic d'un botó
type TIPUS is (NP,P0,P1);
signal ESTAT: TIPUS;

-- Senyals de prescalat
signal presc_1hz: std_logic:='0';
signal c100M: std_logic_vector(27 downto 0):= (others=>'0');
signal presc_3hz: std_logic:='0'; -- Prescaler per incrementar amb frequencia de 3 Hz després de 5s
signal c33M: std_logic_vector(25 downto 0):= (others=>'0');


signal SET_5s,UP_5s,DOWN_5s,OK_5s: std_logic_vector(2 downto 0):= (others=>'0'); -- Comptadors de tecla pitjada 5s
signal speed: std_logic:='0'; -- Modes de velocitat d'increment '0'(increment per pitjada) y '1' increment a 3Hz



begin


process_presc_1hz: process(CLK)
begin
	if (CLK='1' and CLK'event)then
		
		if c100M = 99999999 then --99999999
			presc_1hz<='1';
			c100M<=(others=>'0');
		else
			c100M<=c100M+1;
			presc_1hz<='0';
		end if;
	end if;
end process;

presc_3hz_process: process(CLK)
begin
	if (CLK='1' and CLK'event)then
		
		if c33M = 33333333 then --33333333
			presc_3hz<='1';
			c33M<=(others=>'0');
		else
			c33M<=c33M+1;
			presc_3hz<='0';
		end if;
	end if;
end process;


-- Proces de polsació del teclat
process(CLK)
begin
	if (CLK='1' and CLK'event)then
		
		case ESTAT is
			when NP =>
				if SET='1' or OK='1' or UP='1' or DOWN='1' then
					ESTAT<= P0;
				else
					TECLA<= "0000";
					speed <='0';
					SET_5s<= (others=>'0');
					UP_5s<= (others=>'0');
					DOWN_5s <= (others=>'0');
					ESTAT<=NP;
				end if;
				
			when P0 =>
				ESTAT<=P1;
				
				if UP='1' then
					TECLA<="0010";
				elsif DOWN='1' then
					TECLA<="0001";
				else
					TECLA<="0000";	
				end if;	
			when P1 =>
				if SET='1' then
					if presc_1hz='1' then
						if SET_5s = 4 then
							TECLA <= "1000";
						else
							SET_5s <= SET_5s +1;
						end if;
					end if;
					ESTAT<= P1;
				elsif UP='1' then
					if (presc_1hz='1' and speed='0')then
						if UP_5s >= 4 then
							speed<='1';
						else
							UP_5s <= UP_5s +1;
						end if;
					elsif speed='1' then
						if presc_3hz='1' then
							TECLA<="0010";
						else
							TECLA<="0000";
						end if;
					else 
						TECLA <= "0000";
					end if;

					
					ESTAT<= P1;
				
				elsif DOWN='1' then
					if (presc_1hz='1' and speed='0')then
						if DOWN_5s >= 4 then
							speed<='1';
						else
							DOWN_5s <= DOWN_5s +1;
						end if;
					elsif speed='1' then
						if presc_3hz='1' then
							TECLA<="0001";
						else
							TECLA<="0000";
						end if;
					else
						TECLA <= "0000";
					end if;
					ESTAT<= P1;
				elsif OK='1' then
				    if presc_1hz='1' then
                        if OK_5s = 4 then
                             TECLA <= "0100";
                        else
                             OK_5s <= OK_5s +1;
                        end if;
                    else 
                        TECLA <= "0000";
                    end if;
					
					ESTAT<= P1;
				else
					TECLA <= "0000";
					ESTAT<=NP;
				end if;	
		end case;
	end if;
end process;

end beh;






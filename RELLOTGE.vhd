library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity RELLOTGE is

	port(CLK,SET, OK, UP, DOWN: in std_logic;
		SD: out std_logic_vector(3 downto 0);
		SSEG: out std_logic_vector(7 downto 0));


end RELLOTGE;


architecture beh of RELLOTGE is

-- Declaració de components
component TECLAT
	-- Component TECLAT que s'encarrega de la gestió dels diferents botons
	Port (CLK,SET, OK, UP, DOWN: in std_logic;
		TECLA: out std_logic_vector(3 downto 0));
	end component;
component DISPLAY
	-- Component DISPLAY que s'encarrega de mostrar els resultats al display de la placa
	Port (	CLK,ENABLE: in std_logic;
		SD: out std_logic_vector(3 downto 0);
		M0,M1,H0,H1: in std_logic_vector(3 downto 0);
		SSEG: out std_logic_vector(7 downto 0));
	end component;




signal ENABLE: std_logic:='1'; -- Senyal que fa parpallejar el DISPLAY en estat de CONFIG.
signal TECLA: std_logic_vector(3 downto 0); -- Senyal preprocessada que indica la el botó pitjat

-- Senyals que indiquen el l'hora
signal M0: std_logic_vector(3 downto 0):="1001"; --(others=>'0'); -- Senyal que indica les unitats de minut
signal M1: std_logic_vector(3 downto 0):="0101";--(others=>'0'); -- Senyal que indica les desenes de minut
signal H0: std_logic_vector(3 downto 0):="0011";--(others=>'0'); -- Senyal que indica les unitats d'hora
signal H1: std_logic_vector(3 downto 0):="0010"; --(others=>'0'); -- Senyal que indica les desenes d'hora
signal S: std_logic_vector(5 downto 0):="111010";--(others=>'0'); -- Senyal que compta els segons

-- Senyals de prescalat
signal presc_1hz: std_logic:='0'; -- Prescaler d'1 Hz pel funcionament basic de rellotge
signal presc_1hz_dc50: std_logic:='0'; -- Prescaler d'1 Hz amb DUTY CYCLE DEL 50% per activar l'ENABLE
signal c100M: std_logic_vector(27 downto 0):= (others=>'0'); -- Comptador pel prescaler de 1Hz
signal c100M_dc50: std_logic_vector(27 downto 0):= (others=>'0');-- Comptador pel prescaler de 1Hz DC 50%

-- Senyals de sortida
signal SD_aux:  std_logic_vector(3 downto 0):= (others=>'0'); -- Senyal auxiliar de la sortida SD
signal SSEG_aux:  std_logic_vector(7 downto 0):= (others=>'0'); -- Senyal auxiliar de la sortida SSEG



-- FSM de funcionament general del rellotge
type FSM is (RELOJ,ASC,DESC,CONFIG);
signal ESTAT: FSM;


begin

KEYBOARD: TECLAT port map(
		CLK => CLK,
		SET => SET,
		OK => OK,
		UP => UP,
		TECLA=>TECLA,
		DOWN => DOWN);
DSPLY: DISPLAY port map(
		CLK => CLK,
		SSEG =>SSEG_aux,
		SD => SD_aux,
		ENABLE=>ENABLE,
		M0=>M0,M1=>M1,H0=>H0,H1=>H1
		);



presc_1hz_process: process(CLK)
begin
	if (CLK='1' and CLK'event)then
		if c100M = 999 then --99999999
			presc_1hz<='1';
			c100M<=(others=>'0');
		else
			c100M<=c100M+1;
			presc_1hz<='0';
		end if;
	end if;
end process;

presc_1hz_DC50_process: process(CLK)
begin
	if (CLK='1' and CLK'event)then
		if c100M_dc50 = 499 then --49999999
			presc_1hz_dc50<='1';
			c100M_dc50<=c100M_dc50+1;
		elsif c100M_dc50 = 999 then --99999999
			c100M_dc50<=(others=>'0');
			presc_1hz_dc50<='0';
		else
			c100M_dc50<=c100M_dc50+1;
		end if;
	end if;
end process;


FSM_process: process(CLK)
begin
	if (CLK='1' and CLK'event) then
		case ESTAT is

			when RELOJ =>
				if TECLA="1000" then -- SET
					ESTAT <= CONFIG;
					S<=(others=>'0');
				else 
					if presc_1hz='1' then

						if S>=59 then
							M0<=M0+1;
							S<=(others=>'0');
						else
							S <= S+1;
						end if;
					

						if (M0>=9 and S>=59) then
							M1<=M1+1;
							M0<=(others=>'0');
						end if;


						if (M1>=5 and M0>=9 and S>=59) then
							H0<=H0+1;
							M1<=(others=>'0');
						end if;
						

						if (H1>=2 and H0>=3 and M1>=5 and M0>=9 and S>=59) then
							H1<=(others=>'0');
							H0<=(others=>'0');
							M1<=(others=>'0');
							M0<=(others=>'0');
						elsif (H0=9 and M1>=5 and M0>=9 and S>=59) then
							H1<=H1+1;
							H0<=(others=>'0');
						end if;

					end if;
				end if;
					
			when ASC   =>
				ENABLE<='1';
				if TECLA="0100" then -- OK
					ESTAT <= RELOJ;
				elsif TECLA="0010" then -- UP
					ESTAT <= ASC;
					M0<=M0+1;
					if (M0>=9) then
						M1<=M1+1;
						M0<=(others=>'0');
					end if;

					if (M1>=5 and M0>=9) then
						H0<=H0+1;
						M1<=(others=>'0');
					end if;
					
					if (H1>=2 and H0>=3 and M1>=5 and M0>=9) then
						H1<=(others=>'0');
						H0<=(others=>'0');
						M1<=(others=>'0');
						M0<=(others=>'0');
					elsif (H0=9 and M1>=5 and M0>=9) then
						H1<=H1+1;
						H0<=(others=>'0');
					end if;

				elsif TECLA="0001" then -- DOWN
					ESTAT <= DESC;
					M0<=M0-1;
					if (M0=0) then
						M1<=M1-1;
						M0<="1001";
					end if;

					if (M1=0 and M0=0) then
						H0<=H0-1;
						M1<="0101";
					end if;
					
					if (H1=0 and H0=0 and M1=0 and M0=0) then
						H1<="0010";
						H0<="0011";
						M1<="0101";
						M0<="1001";
					elsif (H0=0 and M1=0 and M0=0) then
						H1<=H1-1;
						H0<="1001";
					end if;
				end if;

			when DESC  =>
				if TECLA="0100" then -- OK
					ESTAT <= RELOJ;
				elsif TECLA="0010" then -- UP
					ESTAT <= ASC;
					M0<=M0+1;
					if (M0>=9) then
						M1<=M1+1;
						M0<=(others=>'0');
					end if;

					if (M1>=5 and M0>=9) then
						H0<=H0+1;
						M1<=(others=>'0');
					end if;
					
					if (H1>=2 and H0>=3 and M1>=5 and M0>=9) then
						H1<=(others=>'0');
						H0<=(others=>'0');
						M1<=(others=>'0');
						M0<=(others=>'0');
					elsif (H0=9 and M1>=5 and M0>=9) then
						H1<=H1+1;
						H0<=(others=>'0');
					end if;
				elsif TECLA="0001" then -- DOWN
					ESTAT <= DESC;
					M0<=M0-1;
					if (M0=0) then
						M1<=M1-1;
						M0<="1001";
					end if;

					if (M1=0 and M0=0) then
						H0<=H0-1;
						M1<="0101";
					end if;
					
					if (H1=0 and H0=0 and M1=0 and M0=0) then
						H1<="0010";
						H0<="0011";
						M1<="0101";
						M0<="1001";
					elsif (H0=0 and M1=0 and M0=0) then
						H1<=H1-1;
						H0<="1001";
					end if;
				end if;

			when CONFIG=>

				if presc_1hz_dc50='1' then
					ENABLE<='0';
				else
					ENABLE<='1';
				end if;

				if TECLA="0100" then -- OK
					ESTAT <= RELOJ;
				elsif TECLA="0010" then -- UP
					ESTAT <= ASC;
					M0<=M0+1;
					if (M0>=9) then
						M1<=M1+1;
						M0<=(others=>'0');
					end if;

					if (M1>=5 and M0>=9) then
						H0<=H0+1;
						M1<=(others=>'0');
					end if;
					
					if (H1>=2 and H0>=3 and M1>=5 and M0>=9) then
						H1<=(others=>'0');
						H0<=(others=>'0');
						M1<=(others=>'0');
						M0<=(others=>'0');
					elsif (H0=9 and M1>=5 and M0>=9) then
						H1<=H1+1;
						H0<=(others=>'0');
					end if;
				elsif TECLA="0001" then -- DOWN
					ESTAT <= DESC;
					M0<=M0-1;
					if (M0=0) then
						M1<=M1-1;
						M0<="1001";
					end if;

					if (M1=0 and M0=0) then
						H0<=H0-1;
						M1<="0101";
					end if;
					
					if (H1=0 and H0=0 and M1=0 and M0=0) then
						H1<="0010";
						H0<="0011";
						M1<="0101";
						M0<="1001";
					elsif (H0=0 and M1=0 and M0=0) then
						H1<=H1-1;
						H0<="1001";
					end if;
				end if;

		end case;
	end if;
end process;


SSEG <= SSEG_aux;
SD <= SD_aux;


end beh;












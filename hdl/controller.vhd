library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
  port(
    btn : in  std_logic_vector(3 downto 0);
    sw : in  std_logic_vector(0 downto 0);
    o_mins, o_secs, o_wmins : out integer range 0 to 59;
    o_hours, o_whours : out integer range 0 to 23;
    alarm : out std_logic;
    state : out std_logic_vector(1 downto 0);
    clk : in  std_logic;
    reset : in  std_logic
  );
end controller;

architecture Behavioral of controller is

  component trigger_gen is
    generic(Delta : integer);
    port(
      clk   : in std_logic;
      reset : in std_logic;
      trigger : out std_logic
    );
  end component trigger_gen;

  -- pro Viertelsekunde einen Takt lang '1'
  signal fasttrigger : std_logic;
  -- fasttrigger wird zurueckgesetzt, wenn BTN2 oder BTN3 gedrueckt werden
  signal fasttimer_reset : std_logic;
  -- pro Sekunde einen Takt lang '1'
  signal sectrigger : std_logic;

  signal hours, whours     : integer range 0 to 23;
  signal secs, mins, wmins : integer range 0 to 59;

  -- fuer Flankenerkennung der Taster
  signal btn_shift : std_logic_vector(3 downto 0);
  signal btn_triggered : std_logic_vector(3 downto 0);

  type state_type is (NTIME, SET_TIME, SET_ALARM, error);
  signal current_state : state_type;

begin
  fasttimer_reset <= reset or
        btn_triggered(2) or btn_triggered(3);

  fasttimer : trigger_gen
    generic map(11)
    port map(clk, fasttimer_reset, fasttrigger);

  sectimer : trigger_gen
    generic map(13)
    port map(clk, reset, sectrigger);

  FSM : process(clk, reset)
    variable next_state : state_type;
  begin
    if reset = '1' then
      hours  <= 0;
      mins   <= 0;
      secs   <= 0;
      whours <= 0;
      wmins  <= 0;
      alarm  <= '0';
      current_state <= NTIME;
    elsif clk'event and clk = '1' then
      for i in 0 to 3 loop
        btn_shift(i) <= btn(i);
        btn_triggered(i) <= not btn_shift(i) and btn(i);
      end loop;

        -- TODO: Zaehle Uhr hoch
        IF (selectrigger = '1') THEN 
        	IF (secs < 59) THEN
            	secs <= secs + 1;
            ELSE
            	secs <= 0;
        		IF(mins < 59) THEN
                	mins <= mins + 1;
                ELSE
                	mins <= 0;
                    IF (hours < 23) THEN
                    	hours <= hours + 1;
                    ELSE
                    	hours <= 0;
                   	END IF;
                 END IF;
             END IF;
          END IF;
          
      -- TODO: Pruefe, ob Alarm ausgeloest werden muss
      	IF (sw(0) = '1' AND hours = whours AND mins = wmins) THEN
        	alarm <= '1'; -- Alarm is initialized with '0', as it is currently off
        ELSE
        	alarm <= '0'; -- It should stay off, if the alarmtime is not the current time
        END IF;
      
      case current_state is
        -- Zustand Time
        when NTIME =>
          -- TODO: Setze naechsten Zustand
          -- from current state Time --(BTN_1)--> State_SetAlarm OR Time --(BTN_0)--> State_SetTime (the other button mustn't be pressed)
          IF (btn_triggered(1) = '1' AND btn_triggered(0) = '0') THEN
          	next_state := SET_TIME;
          	ELSIF (btn_triggered(0) = '1' AND btn_triggered(1) = '0') THEN
          		next_state := SET_ALARM;
          		ELSE
          			next_state := NTIME; -- we remain in the given state
           END IF;
           
        -- Zustand SetTime
        when SET_TIME =>
          -- TODO: Setze naechsten Zustand
          -- from current state SetTime --(BTN_1)--> State_SetAlarm OR Time --(BTN_0)--> State_Time (the other button mustn't be pressed)
          IF (btn_triggered(1) = '1' AND btn_triggered(0) = '0') THEN
          	next_state := SET_ALARM;
            ELSIF (btn_triggered(0) = '1' AND btn_triggered(1) = '0') THEN
            	next_state := NTIME;
                ELSE
                	next_state := SET_TIME; -- we remain in the given state
          END IF;
          
          -- TODO: Setze Minute und Stunde mit BTN(2) bzw. BTN(3)
          IF (fasttrigger = '1' AND btn_triggered(2) = '1') THEN -- btn_2 increments the minutes
          	IF (mins < 59) THEN
            	mins <= mins + 1;
            ELSE
            	mins <= 0;
            END IF;
           END IF;
            -- we are done with the minutes, as increasing one more after 59, sets the minutes to 0 but doesn't change the hour
            
            IF (fasttrigger = '1' AND btn_triggered(3) = '1') THEN
            	IF (hours < 23) THEN
                	hours <= hours + 1;
                ELSE 
                	hours <= 0;
                END IF;
            END IF;
             -- same with hours as it is with minutes

        -- Zustand SetAlarm
        when SET_ALARM =>
          -- TODO: Setze naechsten Zustand
          -- from current state SET_ALARM --(BTN_1)--> State_Time OR Time --(BTN_0)--> State_SetTime (the other button mustn't be pressed)
          IF (btn_triggered(1) = '1' AND btn_triggered(0) = '0') THEN
          	next_state := NTIME;
            ELSIF (btn_triggered(0) = '1' AND btn_triggered(1) = '0') THEN
            	next_state := SET_TIME;
            	ELSE
                	nex_state := SET_ALARM;
           END IF;
          -- TODO: Setze Minute und Stunde mit BTN(2) bzw. BTN(3)
          IF (fasttrigger = '1' AND btn_triggered(2) = '1') THEN
          	IF (wmins < 59) THEN
            	wmins <= wmins + 1;
            ELSE 
            	wmins <= 0;
            END IF;
          END IF;
          
          IF(fasttrigger = '1' AND btn_triggered(3) = '1') THEN
          	IF(whours < 23) THEN
            	whours <= whours + 1;
            ELSE
            	whours <= 0;
            END IF;
          END IF;

          -- Illegale Zustaende
        when others =>
          next_state := NTIME;
      end case;

      current_state <= next_state;
    end if;
  end process FSM;

  o_hours  <= hours;
  o_mins   <= mins;
  o_secs   <= secs;
  o_whours <= whours;
  o_wmins  <= wmins;

  with current_state select
    state <= "00" when NTIME,
             "01" when SET_TIME,
             "10" when SET_ALARM,
             "11" when others;
end architecture Behavioral;



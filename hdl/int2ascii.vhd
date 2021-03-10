LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_unsigned.all;
USE IEEE.numeric_std.all;

ENTITY int2ascii IS
    Port ( i_number : IN  integer RANGE 0 TO 59;
           o_ascii0   : OUT std_logic_vector(7 downto 0);
           o_ascii1   : OUT std_logic_vector(7 downto 0));
END ENTITY int2ascii;

ARCHITECTURE behavioral OF int2ascii IS
    SIGNAL s_bcd0 : unsigned(3 DOWNTO 0);
    SIGNAL s_bcd1 : unsigned(3 DOWNTO 0);
BEGIN
    PROCESS (i_number)
        VARIABLE v_bcd0   : unsigned(3 DOWNTO 0);
        VARIABLE v_bcd1   : unsigned(3 DOWNTO 0);
        VARIABLE v_number : unsigned(7 DOWNTO 0);
    BEGIN
        v_bcd0 := "0000";
        v_bcd1 := "0000";
        v_number := to_unsigned(i_number, v_number'length);
        
        -- pseudocode line 1 to 7 is already implemented (hardcoded)

        FOR i IN 0 TO v_number'length - 1 LOOP -- Looping through the vector // length = 7 (2^(4-1) -1) -> line 7
        
        	-- hardcoding the inner for loop as we have a fixed size of two of our vector -> line 8 to 10
            IF (v_bcd0 > "0100") THEN
            	v_bcd0 := v_bcd0 + "0011";
            END IF;
            
            IF (v_bcd1 > "0100") THEN
            	v_bcd1 := v_bcd1 + "0011";
            END IF;    
                
            -- passing on implementing the loop as it is just one iteration with v_bcd1 : NumberOfBCDValues (( == 2) - 1) = 1 -> line 12 to 14
            v_bcd1 := SHIFT_LEFT(v_bcd1, 1); Alternative: -- sll 1; we can use the sll operation here, as we have unsigned values
            v_bcd1(0) := v_bcd0(3);
            
            -- implementing line 16 and 17
            v_bcd0 := SHIFT_LEFT(v_bcd0, 1); Alternative: -- sll 1; we can use the sll operation here, as we have unsigned values
            v_bcd0(0) := v_number(v_number'length - 1 - i);
            
        END LOOP;
        
        
        s_bcd0 <= v_bcd0;
        s_bcd1 <= v_bcd1;
    END PROCESS;
    o_ascii0 <= std_logic_vector("0011" & s_bcd0); -- in ASCII 0 is 48 in decimal --> 48 == 0011 0000 (2^5 + 2^4)
    o_ascii1 <= std_logic_vector("0011" & s_bcd1);
END ARCHITECTURE behavioral;



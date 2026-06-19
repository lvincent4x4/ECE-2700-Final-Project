library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_fsm is
    Port ( 
        clk       : in STD_LOGIC;
        rst_in    : in STD_LOGIC; -- Hardware reset to initialize the FSM
        A         : in STD_LOGIC_VECTOR (1 downto 0);
        B         : in STD_LOGIC;
        z         : in STD_LOGIC;
        R1, R2, R3, R4 : out STD_LOGIC;
        G1, G2, G3, G4 : out STD_LOGIC;
        Y1, Y2, Y3, Y4 : out STD_LOGIC;
        S         : out STD_LOGIC;
        E         : out STD_LOGIC;
        reset_out : out STD_LOGIC
    );
end traffic_fsm;

architecture Behavioral of traffic_fsm is
    
    -- Define the 9 states
    type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S8,S9);
    signal current_state, next_state : state_type;
    signal blink_counter : integer range 0 to 50000000 := 0;
    signal blink_toggle  : STD_LOGIC := '0';

begin

    -- Process 1: Synchronous state register
    -- Handles the hardware reset before entering S0
    state_register: process(clk, rst_in)
    begin
        if rst_in = '1' then
            current_state <= S0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Process 2: Combinational logic for next state and outputs
    next_state_and_output: process(current_state, A, B,z,blink_toggle)
    begin
        -- Default output assignments to prevent latches
        R1 <= '1'; R2 <= '1'; R3 <= '1'; R4 <= '1';
        G1 <= '0'; G2 <= '0'; G3 <= '0'; G4 <= '0';
        Y1 <= '0'; Y2 <= '0'; Y3 <= '0'; Y4 <= '0';
        S <= '0';
        E <= '0';
        reset_out <= '0';
        next_state <= current_state; -- Default to stay in current state

        case current_state is
            
            when S0 =>
            reset_out <= '0';
                if B = '1' then
                    reset_out <= '1'; -- Pulsed on the way out of S0
                    if A = "00" then
                        next_state <= S1;
                    elsif A = "01" then
                        next_state <= S3;
                    elsif A = "10" then
                        next_state <= S5;
                    elsif A = "11" then
                        next_state <= S7;
                    end if;
                end if;

            -- BRANCH 1 (A = "00")
            when S1 =>
               reset_out <= '0';
                R1 <= '0'; 
                G1 <= '1';
                if B = '1' then
                    reset_out <= '1'; -- Pulsed on the way to S2
                    next_state <= S2;
                end if;

            when S2 =>
                reset_out <= '0';
                R1 <= '0'; 
                Y1 <= '1'; 
                S <= '1';
                if B = '1' then
                    reset_out <= '1';
                    E <= '1'; -- E becomes 1 on the way to S0
                    next_state <= S0;
                end if;

            -- BRANCH 2 (A = "01")
            when S3 =>
            reset_out <= '0';
                R2 <= '0'; 
                G2 <= '1';
                if B = '1' then
                    reset_out <= '1'; 
                    next_state <= S4;
                end if;

            when S4 =>
            reset_out <= '0';
                R2 <= '0'; 
                Y2 <= '1'; 
                S <= '1';
                if B = '1' then
                reset_out <= '1';
                    E <= '1'; 
                    next_state <= S0;
                end if;

            -- BRANCH 3 (A = "10")
            when S5 =>
            reset_out <= '0';
                R3 <= '0'; 
                G3 <= '1'; 
                if B = '1' then
                    reset_out <= '1'; 
                    next_state <= S6;
                end if;

            when S6 =>
            reset_out <= '0';
                R3 <= '0'; 
                Y3 <= '1'; 
                S <= '1';
                if B = '1' then
                reset_out <= '1';
                    E <= '1'; 
                    next_state <= S0;
                end if;

            -- BRANCH 4 (A = "11")
            when S7 =>
            reset_out <= '0';
                R4 <= '0'; 
                G4 <= '1'; 
                if B = '1' then
                    reset_out <= '1'; 
                    next_state <= S8;
                end if;

            when S8 =>
            reset_out <= '0';
                R4 <= '0'; 
                Y4 <= '1'; 
                S <= '1';
                if B = '1' then
                reset_out <= '1';
                    E <= '1'; 
                    next_state <= S0;
                end if;

            when S9 =>
                    R1 <= blink_toggle;
                    R2 <= blink_toggle;
                    R3 <= blink_toggle;
                    R4 <= blink_toggle;
              if z = '0' then
                    reset_out <= '1';
                    next_state <= S0;
                end if;


            -- Fallback
            when others =>
                next_state <= S0;
                
        end case;
        
        if z = '1' then
            next_state <= S9;
        end if;
            
    end process;
    
   -- Process 3: Timer for the flashing LEDs
    blink_timer: process(clk, rst_in)
    begin
        if rst_in = '1' then
            blink_counter <= 0;
            blink_toggle <= '0';
        elsif rising_edge(clk) then
            if blink_counter = 50000000 then 
                blink_counter <= 0;
                blink_toggle <= not blink_toggle; -- Flip the LED state
            else
                blink_counter <= blink_counter + 1;
            end if;
        end if;
    end process; 
    
    

end Behavioral;
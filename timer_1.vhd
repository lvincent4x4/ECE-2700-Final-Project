-- =============================================================
-- N-Bit Timer for Traffic Light Controller
-- Clock: 100 MHz
-- Supports: 10s (1_000_000_000 cycles) and 5s (500_000_000 cycles)
-- Counter width: 30 bits (covers up to ~10.7 seconds at 100 MHz)
--
-- Behavior:
--   - rst = '1' clears the counter and re-arms the timer
--   - Counts up from 0 to target (N-1)
--   - done goes HIGH when count reaches N-1, stays HIGH until rst
-- =============================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n_bit_timer is
    generic (
        WIDTH : integer := 30  -- Counter bit width; 30 bits supports up to ~10.7s @ 100 MHz
    );
    port (
        clk  : in  std_logic;
        rst  : in  std_logic;                                -- Synchronous reset; clears and re-arms timer
        N    : in  std_logic_vector(WIDTH-1 downto 0);      -- Target count from FSM (number of clock cycles)
        done : out std_logic                                 -- HIGH when timer has expired, stays HIGH until rst
    );
end entity n_bit_timer;

architecture rtl of n_bit_timer is

    signal count    : unsigned(WIDTH-1 downto 0) := (others => '0');
    signal done_reg : std_logic := '0';

begin

    timer_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Synchronous reset: clear counter and re-arm
                count    <= (others => '0');
                done_reg <= '0';

            elsif done_reg = '0' then
                -- Only count while not yet done
                if count = unsigned(N) - 1 then
                    done_reg <= '1';    -- Latch done HIGH; stays until rst
                else
                    count <= count + 1;
                end if;
            end if;
            -- Once done_reg = '1' and no rst, counter freezes and done stays HIGH
        end if;
    end process;

    done <= done_reg;

end architecture rtl;
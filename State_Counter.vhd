-- =============================================================
-- 2-Bit Branch Selector Counter
-- 
-- Behavior:
--   - clr = '1' synchronously resets counter to "00"
--   - On each rising edge where ENB = '1', counter increments
--   - Wraps from "11" back to "00" on next ENB pulse
--   - branch output feeds directly back to FSM to select active branch
-- =============================================================
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity branch_selector is
    port (
        clk    : in  std_logic;
        clr    : in  std_logic;                     
        ENB    : in  std_logic;                     
        branch : out std_logic_vector(1 downto 0)   
    );
end entity branch_selector;
 
architecture rtl of branch_selector is
 
    signal count : unsigned(1 downto 0) := "00";
 
begin
 
    branch_proc : process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                count <= "00";
            elsif ENB = '1' then
                count <= count + 1;  
            end if;
        end if;
    end process;
 
    branch <= std_logic_vector(count);
 
end architecture rtl;
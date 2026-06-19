library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( 
        clk       : in  STD_LOGIC;
        rst_in    : in  STD_LOGIC; -- Global hardware reset
        z         : in  STD_LOGIC; -- Emergency/Flash override
        R1, R2, R3, R4 : out STD_LOGIC;
        G1, G2, G3, G4 : out STD_LOGIC;
        Y1, Y2, Y3, Y4 : out STD_LOGIC
    );
end top;

architecture Structural of top is

    -- ==========================================
    -- Component Declarations
    -- ==========================================
    component traffic_fsm is
        Port ( 
            clk       : in STD_LOGIC;
            rst_in    : in STD_LOGIC;
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
    end component;

    component branch_selector is
        port (
            clk    : in  std_logic;
            clr    : in  std_logic;                     
            ENB    : in  std_logic;                     
            branch : out std_logic_vector(1 downto 0)   
        );
    end component;

    component n_bit_timer is
        generic (
            WIDTH : integer := 30
        );
        port (
            clk  : in  std_logic;
            rst  : in  std_logic;                                
            N    : in  std_logic_vector(WIDTH-1 downto 0);      
            done : out std_logic                                 
        );
    end component;

    -- ==========================================
    -- Interconnect Signals
    -- ==========================================
    signal sig_A         : STD_LOGIC_VECTOR(1 downto 0); -- FSM(A) <-> branch_selector(branch)
    signal sig_B         : STD_LOGIC;                    -- FSM(B) <-> n_bit_timer(done)
    signal sig_E         : STD_LOGIC;                    -- FSM(E) <-> branch_selector(ENB)
    signal sig_S         : STD_LOGIC;                    -- FSM(S) -> mux -> n_bit_timer(N)
    signal sig_reset_out : STD_LOGIC;                    -- FSM(reset_out) <-> n_bit_timer(rst)
    signal sig_N         : STD_LOGIC_VECTOR(29 downto 0);-- Target timer count

begin

    -- ==========================================
    -- Timer Logic Multiplexer (S to N mapping)
    -- ==========================================
    -- If S = '0', duration is 10s (1,000,000,000 cycles at 100MHz)
    -- If S = '1', duration is 5s  (500,000,000 cycles at 100MHz)
    sig_N <= std_logic_vector(to_unsigned(1000000000, 30)) when sig_S = '0' else --1000000000
             std_logic_vector(to_unsigned(500000000, 30));--500000000

    -- ==========================================
    -- Component Instantiations
    -- ==========================================
    
    -- 1. Main Finite State Machine
    U_FSM: traffic_fsm
        port map (
            clk       => clk,
            rst_in    => rst_in,
            A         => sig_A,          -- From branch_selector
            B         => sig_B,          -- From timer 'done'
            z         => z,
            R1        => R1, R2 => R2, R3 => R3, R4 => R4,
            G1        => G1, G2 => G2, G3 => G3, G4 => G4,
            Y1        => Y1, Y2 => Y2, Y3 => Y3, Y4 => Y4,
            S         => sig_S,          -- To timer target MUX
            E         => sig_E,          -- To branch_selector ENB
            reset_out => sig_reset_out   -- To timer reset
        );

    -- 2. 2-Bit Branch Selector (A)
    U_BRANCH_SEL: branch_selector
        port map (
            clk    => clk,
            clr    => rst_in,            -- Tied to global reset
            ENB    => sig_E,             -- From FSM 'E'
            branch => sig_A              -- To FSM 'A'
        );

    -- 3. N-Bit Timer (B)
    U_TIMER: n_bit_timer
        generic map (
            WIDTH => 30
        )
        port map (
            clk  => clk,
            rst  => sig_reset_out,       -- Pulsed by FSM 'reset_out'
            N    => sig_N,               -- Target count from MUX
            done => sig_B                -- To FSM 'B'
        );

end Structural;
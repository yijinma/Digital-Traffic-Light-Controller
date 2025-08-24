--Group 8: Dongyue Zhou, Yijin Ma
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
  PORT (
    clkin_50 : in  std_logic;                      -- The 50 MHz FPGA clock input
    rst_n    : in  std_logic;                      -- The RESET input (ACTIVE LOW)
    pb_n     : in  std_logic_vector(3 downto 0);   -- The push-button inputs (ACTIVE LOW)
    sw       : in  std_logic_vector(7 downto 0);   -- The switch inputs
    leds     : out std_logic_vector(7 downto 0);   -- For displaying the lab4 project details

    sm_clken_temp, blink_sig_temp : out std_logic;
    NS_aa, NS_gg, NS_dd           : out std_logic;
    EW_aa, EW_gg, EW_dd           : out std_logic;

    seg7_data  : out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
    seg7_char1 : out std_logic;                    -- seg7 digit selectors
    seg7_char2 : out std_logic                     -- seg7 digit selectors
  );
END LogicalStep_Lab4_top;

ARCHITECTURE simpleCircuit OF LogicalStep_Lab4_top IS

  component segment7_mux 
    port (
      clk   : in  std_logic := '0';
      DIN2  : in  std_logic_vector(6 downto 0);
      DIN1  : in  std_logic_vector(6 downto 0);
      DOUT  : out std_logic_vector(6 downto 0);
      DIG2  : out std_logic;
      DIG1  : out std_logic
    );
  end component;

  component clock_generator
    port (
      sim_mode : in  boolean;
      reset    : in  std_logic;
      clkin    : in  std_logic;
      sm_clken : out std_logic;
      blink    : out std_logic
    );
  end component;

  component pb_filters
    port (
      clkin          : in  std_logic;
      rst_n          : in  std_logic;
      rst_n_filtered : out std_logic;
      pb_n           : in  std_logic_vector(3 downto 0);
      pb_n_filtered  : out std_logic_vector(3 downto 0)
    );
  end component;

  component pb_inverters
    port (
      rst_n        : in  std_logic;
      rst          : out std_logic;
      pb_n_filtered: in  std_logic_vector(3 downto 0);
      pb           : out std_logic_vector(3 downto 0)
    );
  end component;

  component synchronizer
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      din   : in  std_logic;
      dout  : out std_logic
    );
  end component;

  component holding_register
    port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      register_clr : in  std_logic;
      din        : in  std_logic;
      dout       : out std_logic
    );
  end component;

  component State_Machine_Example
    port (
      clk_input, enable, reset, blink_sig, NS_Req, EW_Req : in  std_logic;
      NS_A, NS_D, NS_G, EW_A, EW_D, EW_G : out std_logic;
      clear1, clear : out std_logic;
      NS_crossing_signal, EW_crossing_signal : out std_logic;
      State_Number : out std_logic_vector(3 downto 0)
    );
  end component;

  CONSTANT sim_mode : boolean := TRUE;  -- TRUE for SIM, FALSE for download

  SIGNAL rst, rst_n_filtered, synch_rst : std_logic;
  SIGNAL sm_clken, blink_sig            : std_logic;
  SIGNAL pb_n_filtered, pb              : std_logic_vector(3 downto 0);
  SIGNAL NS_sync, EW_sync               : std_logic;
  SIGNAL NS_crossing, EW_crossing       : std_logic;
  SIGNAL hex_NS, hex_EW                 : std_logic_vector(6 downto 0);
  SIGNAL NS_G, NS_D, NS_A               : std_logic;
  SIGNAL EW_G, EW_D, EW_A               : std_logic;
  SIGNAL EW_Req, NS_Req                 : std_logic;
  SIGNAL State_Number                   : std_logic_vector(3 downto 0);
  SIGNAL clear, clear1                  : std_logic;

BEGIN

  leds(2) <= EW_crossing;  -- leds(2) shows EW crossing
  leds(0) <= NS_crossing;  -- leds(0) shows NS crossing
  leds(1) <= NS_req;       -- leds(1) shows NS request
  leds(3) <= EW_req;       -- leds(3) shows EW request
  leds(7 downto 4) <= State_Number; -- assign state number to LEDs

  INST0: pb_filters 
    port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);

  INST1: pb_inverters 
    port map (rst_n, rst, pb_n_filtered, pb);

  INST2: clock_generator 
    port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig);

  INST3: synchronizer 
    port map (clkin_50, '0', rst, synch_rst);

  INST4: synchronizer 
    port map (clkin_50, synch_rst, pb(0), NS_sync);

  INST5: holding_register 
    port map (clkin_50, synch_rst, clear, NS_sync, NS_Req);

  INST6: synchronizer 
    port map (clkin_50, synch_rst, pb(1), EW_sync);

  INST7: holding_register 
    port map (clkin_50, synch_rst, clear1, EW_sync, EW_Req);

  INST8: State_Machine_Example 
    port map (clkin_50, sm_clken, synch_rst, blink_sig, NS_Req, EW_Req,
              NS_A, NS_D, NS_G, EW_A, EW_D, EW_G, clear1, clear,
              NS_crossing, EW_crossing, State_Number);

  hex_NS <= NS_G & "00" & NS_D & "00" & NS_A; 
  hex_EW <= EW_G & "00" & EW_D & "00" & EW_A;

  INST9: segment7_mux 
    port map (clkin_50, hex_NS, hex_EW, seg7_data(6 downto 0), seg7_char2, seg7_char1);

  -- For simulation purposes only
  NS_aa <= NS_A;
  NS_gg <= NS_G;
  NS_dd <= NS_D;
  EW_aa <= EW_A;
  EW_gg <= EW_G;
  EW_dd <= EW_D;
  blink_sig_temp <= blink_sig;
  sm_clken_temp  <= sm_clken;

END simpleCircuit;

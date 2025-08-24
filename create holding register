--Group 8: Dongyue Zhou, Yijin Ma
library ieee;
use ieee.std_logic_1164.all;

entity holding_register is
  port (
    clk         : in  std_logic;  -- clock
    reset       : in  std_logic;  -- reset button
    register_clr: in  std_logic;
    din         : in  std_logic;
    dout        : out std_logic   -- output
  );
end holding_register;

architecture circuit of holding_register is
  signal sreg : std_logic;
  signal temp : std_logic;
begin
  process(clk, reset) is
  begin
    if rising_edge(clk) then
      sreg <= (din OR sreg) AND (NOT(register_clr OR reset));
    end if;
  end process;
  dout <= sreg;
end circuit;

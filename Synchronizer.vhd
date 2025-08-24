--Group 8: Dongyue Zhou, Yijin Ma
library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
  port (
    clk   : in  std_logic;  -- clock
    reset : in  std_logic;  -- reset
    din   : in  std_logic;  -- input
    dout  : out std_logic   -- output
  );
end synchronizer;

architecture circuit of synchronizer is
  signal sreg : std_logic_vector(1 downto 0);
begin
  process(clk, reset) is
  begin
    if rising_edge(clk) then
      if reset = '1' then
        sreg(0) <= '0';
        sreg(1) <= '0';
      else
        sreg(0) <= din;
        sreg(1) <= sreg(0);
      end if;
    end if;
  end process;
  dout <= sreg(1);
end circuit;

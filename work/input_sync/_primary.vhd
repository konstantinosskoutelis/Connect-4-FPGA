library verilog;
use verilog.vl_types.all;
entity input_sync is
    generic(
        inv             : integer := 1
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        enable          : in     vl_logic;
        signal_in       : in     vl_logic;
        signal_out      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of inv : constant is 1;
end input_sync;

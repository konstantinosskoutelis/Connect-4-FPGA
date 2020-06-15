library verilog;
use verilog.vl_types.all;
entity get_inputs is
    generic(
        N               : integer := 3
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        left            : in     vl_logic;
        right           : in     vl_logic;
        put             : in     vl_logic;
        lrp_self        : out    vl_logic_vector(2 downto 0);
        left_data       : in     vl_logic;
        right_data      : in     vl_logic;
        receive_data    : in     vl_logic;
        lrp_opponent    : out    vl_logic_vector(2 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of N : constant is 1;
end get_inputs;

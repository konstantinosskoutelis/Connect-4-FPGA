library verilog;
use verilog.vl_types.all;
entity input_handling is
    generic(
        inv             : integer := 1;
        N               : integer := 6
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        left            : in     vl_logic;
        right           : in     vl_logic;
        put             : in     vl_logic;
        lrp             : out    vl_logic_vector(2 downto 0);
        l_64            : out    vl_logic;
        r_64            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of inv : constant is 1;
    attribute mti_svvh_generic_type of N : constant is 1;
end input_handling;

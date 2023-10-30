module sx (out, a);
    input [16:0] a;
    output [31:0] out;

    wire [14:0] extend;
    assign extend = a[16] ? 15'hffff : 15'b0;
    assign out[16:0] = a[16:0];
    assign out[31:17] = extend[14:0];
endmodule

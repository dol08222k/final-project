module trng(
    input clk,
    output [3:0] q
    );
    
    wire out_1, out_2, rb_past, rb, in, fb;
    
    eleventh_oscillator(
        .enable(1),
        .out(out_1)
    );
    
    fifth_oscillator(
        .enable(1),
        .out(out_2)
    );
    
    xor_gate xor_1(
        .a(out_1),
        .b(out_2),
        .c(rb_past)
    );
    
    dff dff_rb(
        .clk(clk),
        .D(rb_past),
        .Q(rb),
        .Qbar()
    );
    
    xor_gate xor_2(
        .a(rb),
        .b(fb),
        .c(in)
    );
    
    dff dff_3(
        .clk(clk),
        .D(in),
        .Q(q[3]),
        .Qbar()
    );
    
    dff dff_2(
        .clk(clk),
        .D(q[3]),
        .Q(q[2]),
        .Qbar()
    );
    
    dff dff_1(
        .clk(clk),
        .D(q[2]),
        .Q(q[1]),
        .Qbar()
    );
    
    dff dff_0(
        .clk(clk),
        .D(q[1]),
        .Q(q[0]),
        .Qbar()
    );
    
    xor_gate xor_3(
        .a(q[0]),
        .b(q[1]),
        .c(fb)
    );
    
endmodule

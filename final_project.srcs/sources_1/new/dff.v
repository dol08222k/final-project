module dff (
	input clk,    // Enable
	input D,	 // Data input
	output Q,
	output Qbar
);
    
    reg a ,b;
    
    always @(posedge clk) 
    begin 
        a <= D;
        b <= ~D;
    end
    
    assign Q = a;
    assign Qbar = b;

endmodule
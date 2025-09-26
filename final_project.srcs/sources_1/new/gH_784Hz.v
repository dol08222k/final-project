module gH_784Hz(
    input clk,
    output o_784Hz
    );
    
    reg r_784Hz = 0;
    reg [31:0] r_counter = 0;
    
    always @(posedge clk)
        if(r_counter == 100000000 / 784) begin
            r_counter <= 0;
            r_784Hz <= ~r_784Hz;
            end
        else
            r_counter <= r_counter + 1;

    assign o_784Hz = r_784Hz;
    
endmodule
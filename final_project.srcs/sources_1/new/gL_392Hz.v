module gL_392Hz(
    input clk,
    output o_392Hz
    );
    
    reg r_392Hz = 0;
    reg [31:0] r_counter = 0;
    
    always @(posedge clk)
        if(r_counter == 100000000 / 392) begin
            r_counter <= 0;
            r_392Hz <= ~r_392Hz;
            end
        else
            r_counter <= r_counter + 1;

    assign o_392Hz = r_392Hz;
    
endmodule
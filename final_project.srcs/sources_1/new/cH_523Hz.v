module cH_523Hz(
    input clk,
    output o_523Hz
    );
    
    reg r_523Hz = 0;
    reg [31:0] r_counter = 0;
    
    always @(posedge clk)
        if(r_counter == 100000000 / 523) begin
            r_counter <= 0;
            r_523Hz <= ~r_523Hz;
            end
        else
            r_counter <= r_counter + 1;

    assign o_523Hz = r_523Hz;
    
endmodule
`timescale 1ns / 1ps

module debounce(
    input clk,
    input button,
    output db_button
    );
    
    reg a, b, c;
	
	always @(posedge clk) begin
        begin
            a <= button;
            b <= a;
            c <= b;
        end
	end
	
	assign db_button = c;
	
endmodule

module random_generator(
    input clk,
    output reg [3:0] random
    );
    
    wire [3:0] out;
    
    trng( //4bit 난수 생성
        .clk(clk),
        .q(out)
    );
    
    always @(*) begin
        random = (out % 10) + 1;
    end

    
endmodule

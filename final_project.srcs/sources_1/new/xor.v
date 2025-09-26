module xor_gate(
    input a, b,
    output c
    );

    assign c=(a&~b)|(~a&b);
    
endmodule
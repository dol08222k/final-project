module fifth_oscillator(
    input enable,
    output out
    );
    
    wire w1;
    wire w2;
    wire w3;
    wire w4;
    wire w5;
    wire w6;
    wire feedback;

    assign w1 = (enable & feedback);
    assign w2 = ~w1;
    assign w3 = ~w2;
    assign w4 = ~w3;
    assign w5 = ~w4;
    assign w6 = ~w5;
    assign feedback = w6;
    assign out = w6;
    
endmodule

module eleventh_oscillator(
    input enable,
    output out
    );
    
    wire w1, w2 ,w3 ,w4 ,w5, w6, w7, w8, w9, w10, w11, w12, feedback;
    
    assign w1 = (enable & feedback);
    assign w2 = ~w1;
    assign w3 = ~w2;
    assign w4 = ~w3;
    assign w5 = ~w4;
    assign w6 = ~w5;
    assign w7 = ~w6;
    assign w8 = ~w7;
    assign w9 = ~w8;
    assign w10 = ~w9;
    assign w11 = ~w10;
    assign w12 = ~w11;
    assign feedback = w12;
    assign out = w12;


endmodule
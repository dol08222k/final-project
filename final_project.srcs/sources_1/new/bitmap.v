module number_bitmap(
    input [5:0] hour, min, sec,
    input [7:0] c_temp_data,
    input [3:0] c_temp_frac_data,
    input [4:0] dealer_score, user_score,
    output wire [1023:0] mmap_hour_10s, mmap_hour_1s, mmap_min_10s, mmap_min_1s, 
                         mmap_sec_10s, mmap_sec_1s, mmap_c_tens, mmap_c_ones,
                         mmap_frac, mmap_dealer_tens, mmap_dealer_ones, mmap_user_tens,
                         mmap_user_ones
);

    // CONVERT CLOCK DATA
    wire [3:0] sec_10s, sec_1s, min_10s, min_1s, hour_10s, hour_1s;
    assign sec_10s = sec / 10;
    assign sec_1s = sec % 10;
    assign min_10s = min / 10;
    assign min_1s = min % 10;
    assign hour_10s = hour / 10;
    assign hour_1s = hour % 10;
    
    // CONVERT TEMPERATURE DATA
    wire [3:0] c_tens, c_ones;
    assign c_tens = c_temp_data / 10;
    assign c_ones = c_temp_data % 10;
    
    wire [3:0] frac;
    assign frac = c_temp_frac_data * 625 / 1000; //0011(3) * 625
    
    // CONVERT SCORE DATA
    wire [3:0] dealer_tens, dealer_ones, user_tens, user_ones;
    assign dealer_tens = dealer_score / 10;
    assign dealer_ones = dealer_score % 10;
    assign user_tens = user_score / 10;
    assign user_ones = user_score % 10;
    
    // VGA DECODER INSTANCES
    vga_decoder decode_hour_10s(
        .data(hour_10s),
        .data_out(mmap_hour_10s)
    );
    
    vga_decoder decode_hour_1s(
        .data(hour_1s),
        .data_out(mmap_hour_1s)
    );
    
    vga_decoder decode_min_10s(
        .data(min_10s),
        .data_out(mmap_min_10s)
    );
    
    vga_decoder decode_min_1s(
        .data(min_1s),
        .data_out(mmap_min_1s)
    );
    
    vga_decoder decode_sec_10s(
        .data(sec_10s),
        .data_out(mmap_sec_10s)
    );
    
    vga_decoder decode_sec_1s(
        .data(sec_1s),
        .data_out(mmap_sec_1s)
    );
    
    vga_decoder decode_c_tens(
        .data(c_tens),
        .data_out(mmap_c_tens)
    );
    
    vga_decoder decode_c_ones(
        .data(c_ones),
        .data_out(mmap_c_ones)
    );
    
    vga_decoder decode_frac(
        .data(frac),
        .data_out(mmap_frac)
    );
    
    vga_decoder decode_dealer_tens(
        .data(dealer_tens),
        .data_out(mmap_dealer_tens)
    );
    
    vga_decoder decode_dealer_ones(
        .data(dealer_ones),
        .data_out(mmap_dealer_ones)
    );
    
    vga_decoder decode_user_tens(
        .data(user_tens),
        .data_out(mmap_user_tens)
    );
    
    vga_decoder decode_user_ones(
        .data(user_ones),
        .data_out(mmap_user_ones)
    );

endmodule

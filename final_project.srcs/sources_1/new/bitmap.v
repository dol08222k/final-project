module number_bitmap(
    input clk,
    input [5:0] hour, min, sec,
    input [7:0] c_temp_data,
    input [3:0] c_temp_frac_data,
    input [6:0] st_dpsec, st_sec, st_min, st_hour,
    input [5:0] alarm_hour, alarm_min, alarm_set_hour, alarm_set_min,
    input [4:0] dealer_score, user_score,
    output reg [1023:0] mmap_hour_10s, mmap_hour_1s, mmap_min_10s, mmap_min_1s, 
                        mmap_sec_10s, mmap_sec_1s, mmap_c_tens, mmap_c_ones,
                        mmap_frac, mmap_dealer_tens, mmap_dealer_ones, mmap_user_tens,
                        mmap_user_ones, mmap_alarm_hour_tens, mmap_alarm_hour_ones,
                        mmap_alarm_set_hour_tens, mmap_alarm_set_hour_ones,
                        mmap_alarm_min_tens, mmap_alarm_min_ones, mmap_alarm_set_min_tens,
                        mmap_alarm_set_min_ones
);

    // CONVERT CLOCK DATA
    wire [3:0] sec_10s, sec_1s, min_10s, min_1s, hour_10s, hour_1s;
    assign sec_10s = sec / 10;
    assign sec_1s = sec % 10;
    assign min_10s = min / 10;
    assign min_1s = min % 10;
    assign hour_10s = hour / 10;
    assign hour_1s = hour % 10;
    
    // CONVERT STOPWATCH DATA
    wire [3:0] st_hour_10s, st_hour_1s, st_min_10s, st_min_1s, st_sec_10s, st_sec_1s, st_dpsec_10s, st_dpsec_1s;
    assign st_dpsec_10s = st_dpsec / 10;
    assign st_dpsec_1s = st_dpsec % 10;
    assign st_sec_10s = st_sec / 10;
    assign st_sec_1s = st_sec % 10;
    assign st_min_10s = st_min / 10;
    assign st_min_1s = st_min % 10;
    assign st_hour_10s = st_hour / 10;
    assign st_hour_1s = st_hour % 10;
    
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
    
    // CONVERT ALARM DATA
    wire [3:0] alarm_hour_tens, alarm_hour_ones, alarm_set_hour_tens, alarm_set_hour_ones;
    wire [3:0] alarm_min_tens, alarm_min_ones, alarm_set_min_tens, alarm_set_min_ones;
    assign alarm_hour_tens = alarm_hour / 10;
    assign alarm_hour_ones = alarm_hour % 10;
    assign alarm_set_hour_tens = alarm_set_hour / 10;
    assign alarm_set_hour_ones = alarm_set_hour % 10;
    assign alarm_min_tens = alarm_min / 10;
    assign alarm_min_ones = alarm_min % 10;
    assign alarm_set_min_tens = alarm_set_min / 10;
    assign alarm_set_min_ones = alarm_set_min % 10;
    
    // VGA Decoder Instances
    vga_decoder decode_hour_tens(
        .data(hour_10s),
        .data_out(mmap_hour_10s)
    );
    
    vga_decoder decode_hour_ones(
        .data(hour_1s),
        .data_out(mmap_hour_1s)
    );
    
    vga_decoder decode_min_tens(
        .data(min_10s),
        .data_out(mmap_min_10s)
    );
    
    vga_decoder decode_min_ones(
        .data(min_1s),
        .data_out(mmap_min_1s)
    );
    
    vga_decoder decode_sec_tens(
        .data(sec_10s),
        .data_out(mmap_sec_10s)
    );
    
    vga_decoder decode_sec_ones(
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
    
    vga_decoder decode_alarm_hour_tens(
        .data(alarm_hour_tens),
        .data_out(mmap_alarm_hour_tens)
    );
    
    vga_decoder decode_alarm_hour_ones(
        .data(alarm_hour_ones),
        .data_out(mmap_alarm_hour_ones)
    );
    
    vga_decoder decode_alarm_set_hour_tens(
        .data(alarm_set_hour_tens),
        .data_out(mmap_alarm_set_hour_tens)
    );
    
    vga_decoder decode_alarm_set_hour_ones(
        .data(alarm_set_hour_ones),
        .data_out(mmap_alarm_set_hour_ones)
    );
    
    vga_decoder decode_alarm_min_tens(
        .data(alarm_min_tens),
        .data_out(mmap_alarm_min_tens)
    );
    
    vga_decoder decode_alarm_min_ones(
        .data(alarm_min_ones),
        .data_out(mmap_alarm_min_ones)
    );
    
    vga_decoder decode_alarm_set_min_tens(
        .data(alarm_set_min_tens),
        .data_out(mmap_alarm_set_min_tens)
    );
    
    vga_decoder decode_alarm_set_min_ones(
        .data(alarm_set_min_ones),
        .data_out(mmap_alarm_set_min_ones)
    );
    
endmodule

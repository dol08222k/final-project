`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: Kookmin Unv.
// Engineer: KIM HYEONWOOK
// 
// Create Date: 2024/12/11 15:58:58
// Design Name: Mutifunctional multimedia device using Nexys 4 ddr
// Project Name: Mutifunctional multimedia device
// Target Devices: Nexys 4 ddr
// Tool Versions: 2024.1
// Description: This project is for designing multimedia device have clock, stopwatch, alarm, temperature and game function.
//////////////////////////////////////////////////////////////////////////////////

module top(
    input clk,                                                              // NEXYS 4 DDR CLOCK(100MHz)
    input reset, right_button, left_button, up_button, down_button,         // BUTTON
    input cpu_resetn,
    input clock_sw, temp_sw, stopwatch_sw,alarm_sw, blackjack_sw,           // MODE SWITCH
    output LED16_R, LED16_G, LED16_B,                                       // RGB LED 1
    output LED17_R, LED17_G, LED17_B,                                       // RGB LED 2
    output [6:0] seg,                                                       // 7-SEGMENT ANODE/CATHODE
    output [7:0] an,
    output [15:0] led,                                                      // LED FOR ALRAM
    inout SDA,                                                              // I2C SDA BUS
    output SCL,                                                             // I2C SCL BUS
    output speaker,                                                         // PWM SIGNAL
    output [3:0] VGA_R, VGA_G, VGA_B,                                       // VGA RGB
    output VGA_HS, VGA_VS
    );
    
    // FSM
    
    parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;
				    
    reg [3:0] state_reg;
    
    initial begin
        state_reg <= POWER_UP;
    end
    
    always @(posedge clk) begin
        if(clock_sw && ~temp_sw && ~stopwatch_sw && ~alarm_sw && ~blackjack_sw)
            state_reg <= CLOCK;
        else if(~clock_sw && temp_sw && ~stopwatch_sw && ~alarm_sw && ~blackjack_sw)
            state_reg <= TEMP;
        else if(~clock_sw && ~temp_sw && stopwatch_sw && ~alarm_sw && ~blackjack_sw)
            state_reg <= STOPWATCH;
        else if(~clock_sw && ~temp_sw && ~stopwatch_sw && alarm_sw && ~blackjack_sw)
            state_reg <= ALARM;
        else if(~clock_sw && ~temp_sw && ~stopwatch_sw && ~alarm_sw && blackjack_sw)
            state_reg <= BLACKJACK;
        else
            state_reg <= STOP;
    end

    // WIRE TYPE DATA FOR CONNETING BETWEEN MODULES
    wire [5:0] hour, min, sec;
    wire clk_1Hz, clk_100Hz;
    wire [6:0] st_dpsec, st_sec, st_min, st_hour;
    wire [7:0] c_temp_data;
    wire [3:0] c_temp_frac_data;
    wire [5:0] alarm_hour, alarm_min, alarm_set_hour, alarm_set_min;
    wire db_reset, db_right, db_left, db_up, db_down;
    wire win, lose, draw;
    wire [4:0] dealer_score, user_score;

    // BUTTON DEBOUNCE
    
    debounce db_reset_button(
        .clk(clk),
        .button(reset),
        .db_button(db_reset)
    );
    
    debounce db_right_button(
        .clk(clk),
        .button(right_button),
        .db_button(db_right)
    );
    
    debounce db_left_button(
        .clk(clk),
        .button(left_button),
        .db_button(db_left)
    );

    debounce db_up_button(
        .clk(clk),
        .button(up_button),
        .db_button(db_up)
    );
    
    debounce db_down_button(
        .clk(clk),
        .button(down_button),
        .db_button(db_down)
    );
    
    // VGA DISPLAY
    supply0 zero0;
    //make cloc
    wire clk_pix, clk_locked;
    clock_gen_480p clkk (
        clk,
        !cpu_resetn,
        clk_pix,
        clk_locked
    );
    
    //make signals
    wire hsync, vsync, de;
    wire [9:0] sx;
    wire [9:0] sy;
    display_timings dispp(
        clk_pix,
        !clk_locked,
        hsync,
        vsync,
        de,
        sx,
        sy
    );
    
    wire [1023:0] mmap_hour_10s, mmap_hour_1s, mmap_min_10s, mmap_min_1s, 
                  mmap_sec_10s, mmap_sec_1s, mmap_c_tens, mmap_c_ones,
                  mmap_frac, mmap_dealer_tens, mmap_dealer_ones, mmap_user_tens,
                  mmap_user_ones;
    
    number_bitmap bitmap(
        .hour(hour),
        .min(min),
        .sec(sec),
        .c_temp_data(c_temp_data),
        .c_temp_frac_data(c_temp_frac_data),
        .dealer_score(dealer_score),
        .user_score(user_score),
        .mmap_hour_10s(mmap_hour_10s),
        .mmap_hour_1s(mmap_hour_1s),
        .mmap_min_10s(mmap_min_10s),
        .mmap_min_1s(mmap_min_1s),
        .mmap_sec_10s(mmap_sec_10s),
        .mmap_sec_1s(mmap_sec_1s),
        .mmap_c_tens(mmap_c_tens),
        .mmap_c_ones(mmap_c_ones),
        .mmap_frac(mmap_frac),
        .mmap_dealer_tens(mmap_dealer_tens),
        .mmap_dealer_ones(mmap_dealer_ones),
        .mmap_user_tens(mmap_user_tens),
        .mmap_user_ones(mmap_user_ones)
    );

    //instantiate drawer
    wire vga_hs, vga_vs;
    wire [3:0] vga_r;
    wire [3:0] vga_g;
    wire [3:0] vga_b;
    draw_module draww(
        clk_pix,
        win,
        lose,
        draw,
        mmap_hour_10s,
        mmap_hour_1s,
        mmap_min_10s,
        mmap_min_1s,
        mmap_sec_10s,
        mmap_sec_1s,
        mmap_c_tens,
        mmap_c_ones,
        mmap_frac,
        mmap_dealer_tens,
        mmap_dealer_ones,
        mmap_user_tens,
        mmap_user_ones,
        sx,
        sy,
        de,
        hsync,
        vsync,
        vga_hs,
        vga_vs,
        vga_r,
        vga_g,
        vga_b
    );
    assign VGA_HS=vga_hs;
    assign VGA_VS=vga_vs;
    assign VGA_R[3:0]=vga_r[3:0];
    assign VGA_G[3:0]=vga_g[3:0];
    assign VGA_B[3:0]=vga_b[3:0];
    
    // 7-SEGMENT DATA DISPLAY
    display display(
        .clk(clk),
        .state_reg(state_reg),
        .sec(sec),
        .min(min),
        .hour(hour),
        .st_hour(st_hour),
        .st_min(st_min),
        .st_sec(st_sec),
        .st_dpsec(st_dpsec),
        .c_temp_data(c_temp_data),
        .c_temp_frac_data(c_temp_frac_data),
        .alarm_hour(alarm_hour),
        .alarm_min(alarm_min),
        .alarm_set_hour(alarm_set_hour),
        .alarm_set_min(alarm_set_min),
        .dealer_score(dealer_score),
        .user_score(user_score),
        .seg(seg),
        .an(an),
        .dp(dp)
    );
    
    //CLOCK
    digital_clock clock(
        .clk(clk),
        .state_reg(state_reg),
        .reset(db_reset),
        .tick_hour(db_left),
        .tick_min(db_right),
        .clk_1Hz(clk_1Hz),
        .sec(sec),
        .min(min),
        .hour(hour)
        );
        
    // TEMPERATURE MEASUREMENT
    I2C_temp temp(
        .clk(clk),
        .SDA(SDA),
        .SCL(SCL),
        .temp_data(c_temp_data),
        .temp_frac_data(c_temp_frac_data),
        .clk_200kHz(),
        .SDA_ctr()
    );
    
    // STOPWATCH
    stopwatch stopwatch(
        .clk(clk),
        .reset(db_reset),
        .button_pause(db_right),
        .state_reg(state_reg),
        .clk_100Hz(clk_100Hz),
        .st_hour(st_hour),
        .st_min(st_min),
        .st_sec(st_sec),
        .st_dpsec(st_dpsec)
    );
    
    // ALARM
    alarm alarm(
        .select(db_reset),
        .up_hour(db_left),
        .up_min(db_right),
        .state_reg(state_reg),
        .alarm_hour(alarm_hour),
        .alarm_min(alarm_min),
        .alarm_set_hour(alarm_set_hour),
        .alarm_set_min(alarm_set_min)
    );
    
    // ALARM ALAERT
    check_alarm alert_alarm(
        .clk(clk),
        .state_reg(state_reg),
        .reset(db_down),
        .hour(hour),
        .min(min),
        .sec(sec),
        .alarm_set_hour(alarm_set_hour),
        .alarm_set_min(alarm_set_min),
        .led(led)
    );
    
    // GAME-BLACKJACK
    black_jack blackjack( // 블랙잭 모듈
        .clk(clk),
        .reset(db_reset),
        .state_reg(state_reg),
        .hit(db_up),
        .stand(db_down),
        .win(win),
        .lose(lose),
        .draw(draw),
        .dealer_score(dealer_score),
        .user_score(user_score)        
    );
    
    // GAME RESULT - LED, SOUND
    led_blackjack led_blackjack(
        .clk(clk),
        .state_reg(state_reg),
        .LED16_R(LED16_R),
        .LED16_G(LED16_G),
        .LED16_B(LED16_B),
        .LED17_R(LED17_R),
        .LED17_G(LED17_G),
        .LED17_B(LED17_B),
        .win(win),
        .lose(lose),
        .draw(draw)
    );
    
    blackjack_sound sound(
        .clk(clk),
        .state_reg(state_reg),
        .reset(db_reset),
        .win(win),
        .lose(lose),
        .draw(draw),
        .speaker(speaker)
    );
    
endmodule
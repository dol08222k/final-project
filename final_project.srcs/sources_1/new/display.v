`timescale 1ns / 1ps

module display(
    input clk,
    input [3:0] state_reg,
    input [5:0] hour, min, sec,
    input [7:0] c_temp_data,
    input [3:0] c_temp_frac_data,
    input [6:0] st_dpsec, st_sec, st_min, st_hour,
    input [5:0] alarm_hour, alarm_min, alarm_set_hour, alarm_set_min,
    input [4:0] dealer_score, user_score,
    output reg [6:0] seg,
    output reg [7:0] an,
    output wire dp
	);
	
	// FSM PARAMETER
	parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;
				    
    wire [2:0] s;	 
    reg [3:0] digit;
    wire [7:0] aen;
    reg [19:0] clkdiv;
    reg [3:0] digit_8, digit_7, digit_6, digit_5, digit_4, digit_3, digit_2, digit_1;
    
    assign dp = 1;
    assign s = clkdiv[19:17];
    assign aen = 8'b11111111; // all turned off initially
        
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
    
    wire [10:0] frac;
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
   
    
   always @(*) begin
        case(state_reg)
                CLOCK: begin
                       digit_8 <= 15;
                       digit_7 <= 15;
                       digit_6 <= hour_10s;
                       digit_5 <= hour_1s;
                       digit_4 <= min_10s;
                       digit_3 <= min_1s;
                       digit_2 <= sec_10s;
                       digit_1 <= sec_1s;
                       end
                TEMP: begin
                      digit_8 <= 15;
                      digit_7 <= 15;
                      digit_6 <= 15;
                      digit_5 <= c_tens;
                      digit_4 <= c_ones;
                      digit_3 <= frac;
                      digit_2 <= 10;
                      digit_1 <= 11;
                      end
            STOPWATCH: begin
                       digit_8 <= st_hour_10s;
                       digit_7 <= st_hour_1s;
                       digit_6 <= st_min_10s;
                       digit_5 <= st_min_1s;
                       digit_4 <= st_sec_10s;
                       digit_3 <= st_sec_1s;
                       digit_2 <= st_dpsec_10s;
                       digit_1 <= st_dpsec_1s;
                       end
              ALARM : begin
                      digit_8 <= alarm_set_hour_tens;
                      digit_7 <= alarm_set_hour_ones;
                      digit_6 <= alarm_set_min_tens;
                      digit_5 <= alarm_set_min_ones;
                      digit_4 <= alarm_hour_tens;
                      digit_3 <= alarm_hour_ones;
                      digit_2 <= alarm_min_tens;
                      digit_1 <= alarm_min_ones;
                      end
          BLACKJACK : begin
                      digit_8 <= user_tens;
                      digit_7 <= user_ones;
                      digit_6 <= 15;
                      digit_5 <= 15;
                      digit_4 <= 15;
                      digit_3 <= 15;
                      digit_2 <= dealer_tens;
                      digit_1 <= dealer_ones;
                      end
                STOP: begin
                      digit_8 <= 15;
                      digit_7 <= 15;
                      digit_6 <= 15;
                      digit_5 <= 15;
                      digit_4 <= 15;
                      digit_3 <= 15;
                      digit_2 <= 15;
                      digit_1 <= 15;
                      end
             default: begin
                      digit_8 <= 15;
                      digit_7 <= 15;
                      digit_6 <= 15;
                      digit_5 <= 15;
                      digit_4 <= 15;
                      digit_3 <= 15;
                      digit_2 <= 15;
                      digit_1 <= 15;
                      end
        endcase 
   end
			
    always @(posedge clk)
        case(s)
            0:digit = digit_1;
            1:digit = digit_2;
            2:digit = digit_3;
            3:digit = digit_4;
            4:digit = digit_5;
            5:digit = digit_6;
            6:digit = digit_7;
            7:digit = digit_8;
            default:digit = 10;
            endcase

    always @(*)
        case(digit)
        0:seg = 7'b1000000;////0000					
        1:seg = 7'b1111001;////0001
        2:seg = 7'b0100100;////0010
        3:seg = 7'b0110000;////0011
        4:seg = 7'b0011001;////0100
        5:seg = 7'b0010010;////0101
        6:seg = 7'b0000010;////0110
        7:seg = 7'b1111000;////0111
        8:seg = 7'b0000000;////1000
        9:seg = 7'b0010000;////1001
        10:seg = 7'b0011100; //DOT
        11:seg = 7'b1000110; //C
        15:seg = 7'b1111111;
        default: seg = 7'b1111111; // U
    endcase
    
    always @(*)begin
        an=8'b11111111;
        if(aen[s] == 1)
            an[s] = 0;
    end
    
    always @(posedge clk) begin
        clkdiv <= clkdiv+1;
    end
    
endmodule
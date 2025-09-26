`timescale 1ns / 1ps

module stopwatch(
    input clk,                                              // clock
    input [3:0] state_reg,                                  //state reg
    input reset, button_pause,                              // reset, start/pause button
    output reg [6:0] st_dpsec, st_sec, st_min, st_hour,     //시간 표시용 데이터(decimal type)
    output clk_100Hz
    );

    parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////

    // 100Hz clk 신호(rising edge사용시 0.01s 신호 제공)
    reg [31:0] cnt_100Hz = 0;
    reg clk_reg = 0;
    
    always @(posedge clk or posedge reset)
        if(reset && state_reg == STOPWATCH)
            cnt_100Hz <= 0;
        else
            if(cnt_100Hz == 499999) begin //100000000cycle
                cnt_100Hz <= 0;
                clk_reg <= ~clk_reg; //1Hz 펄스 신호
            end
            else
                cnt_100Hz <= cnt_100Hz + 1;
   
    assign clk_100Hz = clk_reg;

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 일시정지/재개 버튼 제어
    
    reg state_pause = 1;
    
    always @ (posedge button_pause)
    begin
        if(state_reg == STOPWATCH)
            state_pause <= ~state_pause;
    end
      

    /////////////////////////////////////////////////////////////////////////////////////////////////////
    // 스톱워치 알고리즘
    
    always @(posedge clk_100Hz or posedge reset)
        if(reset && state_reg == STOPWATCH)
            st_dpsec <= 0;
        else
            if(st_dpsec == 99)
                st_dpsec <= 0;
            else
                if(state_pause)
                    ;
                else
                    st_dpsec <= st_dpsec + 1;
    
    always @(posedge clk_100Hz or posedge reset)
        if(reset && state_reg == STOPWATCH)
            st_sec <= 0;
        else
            if((st_dpsec == 99))
                if(st_sec == 59)
                    st_sec <= 0;
                else
                    if(state_pause)
                        ;
                    else
                        st_sec <= st_sec + 1;
                 
    always @(posedge clk_100Hz or posedge reset)
        if(reset && state_reg == STOPWATCH)
            st_min <= 0;
        else
            if((st_sec == 59 && st_dpsec == 99))
                if(st_min == 59)
                    st_min <= 0;
                else
                    if(state_pause)
                        ;
                    else
                        st_min <= st_min + 1;
                    
    always @(posedge clk_100Hz or posedge reset)
        if(reset && state_reg == STOPWATCH)
            st_hour <= 0;  // 99
        else
            if((st_min == 59 && st_sec == 59 && st_dpsec == 99))
                if(st_hour == 99)
                    st_hour <= 0;
                else
                    if(state_pause)
                        ;
                    else
                        st_hour <= st_hour + 1;
 
 /////////////////////////////////////////////////////////////////////////////////////////////////////    

endmodule
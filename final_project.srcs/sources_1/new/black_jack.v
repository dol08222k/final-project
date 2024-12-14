`timescale 1ns / 1ps

module black_jack(
    input clk,                                  // clock
    input [3:0] state_reg,
    input reset, hit, stand,                     // 게임 제어 버튼
    output win, draw, lose,                     // 승패 상태 변수
    output reg [4:0] dealer_score, user_score   // 딜러/유저 스코어
    );
    
    parameter [3:0] POWER_UP   = 4'd0,
                    CLOCK      = 4'd1,
                    TEMP       = 4'd2,
					STOPWATCH  = 4'd3,
					ALARM      = 4'd4,
					BLACKJACK  = 4'd5,
				    STOP       = 4'd6;

    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // random card 값
    
    wire [3:0] dealer_rand_card_1, dealer_rand_card_2, user_rand_card_1, user_rand_card_2;
    
    random_generator dealer_card_1(
        .clk(clk),
        .random(dealer_rand_card_1)
    );
    
    random_generator dealer_card_2(
        .clk(clk),
        .random(dealer_rand_card_2)
    );
    
    random_generator user_card_1(
        .clk(clk),
        .random(user_rand_card_1)
    );
    
    random_generator user_card_2(
        .clk(clk),
        .random(user_rand_card_2)
    );
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // state machine parameter -> game progress
    
    parameter [1:0] start_state = 2'b00,
                    user_state = 2'b01,
                    dealer_state = 2'b10,
                    finish_state = 2'b11;
    
    reg [1:0] current_state = start_state;
    
    reg win_reg = 0;
    reg lose_reg = 0;
    reg draw_reg = 0;
    
    assign win = win_reg;
    assign lose = lose_reg;
    assign draw = draw_reg;
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // button state register - 상태 제어를 위한 버튼 펄스 형성
    
    wire hit_reg, stand_reg, reset_reg;
    assign hit_reg = hit;
    assign stand_reg = stand;
    assign reset_reg = reset;
    
    reg hit_before, stand_before, reset_before;
    reg hit_after = 0, stand_after = 0, reset_after = 0;
    reg hit_pulse, stand_pulse, reset_pulse;
    

    always @ (posedge clk)
    begin
        // hit pulse
        hit_before <= hit_reg;
        hit_after <= hit_before;
        if ((hit_before != hit_after && hit_before) && state_reg == BLACKJACK)
        begin
            hit_pulse <= 1'b1;
        end
        else
        begin
            hit_pulse <= 1'b0;
        end

        // stand pulse
        stand_before <= stand_reg;
        stand_after <= stand_before;
        if ((stand_before != stand_after && stand_before) && state_reg == BLACKJACK)
        begin
            stand_pulse <= 1'b1;
        end
        else
        begin
            stand_pulse <= 1'b0;
        end

        // reset pusle
        reset_before <= reset_reg;
        reset_after <= reset_before;
        if ((reset_before != reset_after && reset_before) && state_reg == BLACKJACK) 
        begin
            reset_pulse <= 1'b1;
        end
        else
        begin
            reset_pulse <= 1'b0;
        end
    end
    
    
    //////////////////////////////////////////////////////////
    // Statemachine -> game progress
    
     always @ (posedge clk)
     begin
         case(current_state)
             start_state:
             begin
                win_reg     <= 1'b0;
                lose_reg    <= 1'b0;
                draw_reg    <= 1'b0;
                
                if(user_score < 1 && dealer_score < 1) begin // 카드가 없을 경우 랜덤 카드 배부(초기 게임 세팅 상태)
                    //초기 카드 상태 공개 딜러 1 유저 2
                    dealer_score <= dealer_rand_card_1; // 딜러 카드는 하나만 공개 된 상태
                    user_score <= user_rand_card_1 + user_rand_card_2; // 유저카드는 둘다 볼 수 있고 두 카드 값의 합을 표시
                end
                
                // 카드가 이미 있고 hit 선언 후 돌아올 경우 카드는 새로 받지 않음
                
                if(stand_pulse) begin
                // 유저가 stand 선언 시 유저 카드 상태 유지, 딜러 카드 전부 공개 딜러 턴으로 이동
                    current_state <= dealer_state;
                end
                else if(hit_pulse) begin
                // 유저가 hit 선언 시 유저 턴으로 이동
                    current_state <= user_state;
                end
                else if(reset_pulse) begin // 게임 도중 리셋시 초기 세팅으로 이동
                    current_state <= start_state;
                    win_reg     <= 1'b0;
                    lose_reg    <= 1'b0;
                    draw_reg    <= 1'b0;
                    user_score <= 0;
                    dealer_score <= 0;
                end
                
                // 21이상일 경우 바로 승패 판별로 이동
                if(user_score >= 21) begin
                    current_state <= finish_state;
                end
             end
             user_state: // 유저 턴
             begin
                 win_reg     <= 1'b0;
                 lose_reg    <= 1'b0;
                 draw_reg    <= 1'b0;
                 
                 // 21미만일 경우 카드 한장 랜덤 받기 후 이전 상태로 돌아감
                 user_score <= user_score + user_rand_card_2;
                 current_state <= start_state;

             end
             dealer_state: // 딜러 턴
             begin
                 win_reg     <= 1'b0;
                 lose_reg    <= 1'b0;
                 draw_reg    <= 1'b0;
                 
                 //유저는 더이상 카드를 받을 수 없음(stand 선언)
                 
                 if(dealer_score >= 17) begin
                 // 카드 총 값이 17이상일 경우 승패 판별로 이동
                    current_state <= finish_state;
                 end
                 else if(dealer_score < 17) begin
                 // 딜러는 유저가 stand 한 경우 카드를 공개 -> 총합이 17미만일경우 카드를 랜덤으로 무조건 받음(17이상일 때까지 받음)
                    dealer_score <= dealer_score + dealer_rand_card_2;
                 end
             end
             finish_state: //게임 종료 - 점수 계산 및 승패 판별
             begin
                 if ((user_score < dealer_score && dealer_score <= 21) || user_score > 21) //user lose(유저가 21이상이거나 딜러가 21이하인데 유저가 더 낮을 경우)
                 begin
                     win_reg     <= 1'b0;
                     lose_reg    <= 1'b1;
                     draw_reg    <= 1'b0;
                 end
                 else if ((user_score > dealer_score && user_score <= 21) || dealer_score > 21) //user win(딜러가 21이상으로 burst이거나 유저가 21이하인데 유저가 더 높을 경우)
                 begin
                     win_reg     <= 1'b1;
                     lose_reg    <= 1'b0;
                     draw_reg    <= 1'b0;
                 end
                 else
                 begin //draw(이외는 동률 -> 비김)
                     win_reg     <= 1'b0;
                     lose_reg    <= 1'b0;
                     draw_reg    <= 1'b1;
                 end
                 if (reset_pulse) //게임 다시 시작을 위한 점수 값 및 승패 레지스터 현재 상태 레지스터 초기화
                    begin
                        current_state <= start_state;
                        win_reg     <= 1'b0;
                        lose_reg    <= 1'b0;
                        draw_reg    <= 1'b0;
                        user_score <= 0;
                        dealer_score <= 0;
                    end          
             end
             default: //오동작 방지
             begin
                 current_state <= start_state;
             end
         endcase
     end
    
endmodule
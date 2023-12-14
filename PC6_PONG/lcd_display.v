module lcd_display(
    input                clk        ,
    input                rstn       ,
    input                S_playerA_R,
    input                S_playerA_L,
    input                S_playerB_R,
    input                S_playerB_L,
    input                ps2_done   ,
    input     [7:0]      ps2_data   ,
    input                StartStop  ,
    output               beep       ,
    input     [10:0]     pixel_xpos ,  
    input     [10:0]     pixel_ypos ,  
    input     [10:0]     h_disp     ,  
    input     [10:0]     v_disp     ,  
    output reg[15:0]     pixel_data   
);
reg busy;
wire       done;   //fail
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            busy <= 0;
        end else begin
            busy <= StartStop;
        end
    end
parameter boundary_R = 20;   
parameter boundary_L = 270;  
parameter boundary_T = 450;
parameter boundary_D = 50;   
reg [10:0] ball_xpos;  
reg [10:0] ball_ypos; 
reg        direction_x; 
reg        direction_y;  
wire       flagA;  //playe A
wire       flagB;  //player B
reg [25:0] cnt_v;
parameter num = 999999;
always@(posedge clk or negedge rstn)    
    begin
        if(!rstn)begin
            cnt_v <= 0;
        end else begin
            if(cnt_v == num)begin
                cnt_v <= 0;
            end else begin
                cnt_v <= cnt_v+1;
            end
        end
    end
wire flag_V;
reg [2:0] shadow;
assign flag_V = (cnt_v == num) ? 1 : 0;
always@(posedge clk or negedge rstn)    
    begin
        if(!rstn)begin
            ball_xpos <= 318;
            ball_ypos <= 140;
            shadow   <= 0;
        end else if(done)begin  
            ball_xpos <= 318;
            ball_ypos <= 140;
            shadow   <= 0;
        end else if(flag_V && busy)begin  
            if(direction_x)begin
                if(direction_y)begin
                    ball_xpos <= ball_xpos+2;
                    ball_ypos <= ball_ypos+1;
                    shadow   <= 1;
                end else begin
                    ball_xpos <= ball_xpos+2;
                    ball_ypos <= ball_ypos-1;
                    shadow   <= 2;
                end
            end else begin
                if(direction_y)begin
                    ball_xpos <= ball_xpos-2;
                    ball_ypos <= ball_ypos+1;
                    shadow   <= 3;
                end else begin
                    ball_xpos <= ball_xpos-2;
                    ball_ypos <= ball_ypos-1;
                    shadow   <= 4;
                end
            end
        end
    end
reg state1;
reg state2;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            direction_x <= 1;
            state1      <= 0;
        end else begin
            case(state1)
                0:begin
                    if(ball_xpos <= 10 || ball_xpos >= 620 || flagA || flagB)begin
                        direction_x <= !direction_x;
                        state1 <= 1;
                    end else begin
                        direction_x <= direction_x;
                    end
                end
                1:begin
                    if(flag_V)begin
                        state1 <= 0;
                    end else begin
                        state1 <= state1;
                    end
                end
            endcase
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            direction_y <= 1;
            state2 <= 0;
        end else begin
            case(state2)
                0:begin
                    if(ball_ypos <= 20 || ball_ypos >= 260-8)begin
                        direction_y <= !direction_y;
                        state2 <= 1;
                    end else begin
                        direction_y <= direction_y;
                    end
                end 
                1:begin
                    if(flag_V)begin
                        state2 <= 0;
                    end else begin
                        state2 <= state2;
                    end
                end
            endcase
        end
    end
assign beep = (state1) ? 1 : 0;
parameter racket_A = 60;  //A racket
parameter racket_B = 580; //B racket
reg [10:0] racket_Axpos;  
reg [10:0] racket_Bxpos;  
assign flagA = (ball_xpos==racket_A && ball_ypos>=racket_Axpos && (ball_ypos<=racket_Axpos+25)) ? 1 : 0;//
assign flagB = (ball_xpos==racket_B && ball_ypos>=racket_Bxpos && (ball_ypos<=racket_Bxpos+25)) ? 1 : 0;
assign done = (ball_xpos <= 10 || ball_xpos >= 620) ? 1 : 0;
//assign done = 0;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            racket_Axpos <= 130;
        end else if(done)begin  
            racket_Axpos <= 130;
        end else if(busy)begin
            if(racket_Axpos == boundary_R && (S_playerA_R || (ps2_done && ps2_data==8'h15)))begin
                racket_Axpos <= racket_Axpos;
            end else if(S_playerA_R || (ps2_done && ps2_data==8'h15))begin
                racket_Axpos <= racket_Axpos-5;
            end else if(racket_Axpos >= boundary_L-25 && (S_playerA_L || (ps2_done && ps2_data==8'h1c)))begin
                racket_Axpos <= racket_Axpos;
            end else if((S_playerA_L || (ps2_done && ps2_data==8'h1c)))begin
                racket_Axpos <= racket_Axpos+5;
            end
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            racket_Bxpos <= 130;
        end else if(done)begin  
            racket_Bxpos <= 130;
        end else if(busy)begin
            if(racket_Bxpos == boundary_R && (S_playerB_R || (ps2_done && ps2_data==8'h4d)))begin
                racket_Bxpos <= racket_Bxpos;
            end else if(S_playerB_R || (ps2_done && ps2_data==8'h4d))begin
                racket_Bxpos <= racket_Bxpos-5;
            end else if(racket_Bxpos >= boundary_L-25 && (S_playerB_L || (ps2_done && ps2_data==8'h4b)))begin
                racket_Bxpos <= racket_Bxpos;
            end else if(S_playerB_L || (ps2_done && ps2_data==8'h4b))begin
                racket_Bxpos <= racket_Bxpos+5;
            end
        end
    end
reg [7:0] coreA;
reg [7:0] coreB;
reg [3:0] coreA_H;
reg [3:0] coreA_L;
reg [3:0] coreB_H;
reg [3:0] coreB_L;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            coreA <= 0;
        end else if(ball_xpos == 620)begin
            coreA <= coreA+1;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            coreB <= 0;
        end else if(ball_xpos == 10)begin
            coreB <= coreB+1;
        end
    end
always@(posedge clk or negedge rstn)
   begin
      if(!rstn)begin
         coreA_H <= 0;
         coreA_L <= 0;
         coreB_H <= 0;
         coreB_L <= 0;
      end else begin
         coreA_H <= coreA/10;
         coreA_L <= coreA%10;
         coreB_H <= coreB/10;
         coreB_L <= coreB%10;
      end
   end
wire [63:0] mydisplay[4:0];
assign mydisplay[0] = 64'h00183C7E7E3C1800;
assign mydisplay[1] = 64'h8040303E1F1F1F0F;
assign mydisplay[2] = 64'h0F1F1F1F3E304080;
assign mydisplay[3] = 64'h01020C7CF8F8F8F0;
assign mydisplay[4] = 64'hF0F8F8F87C0C0201;
wire [127:0] digital[9:0];
assign digital[0] = 128'h00000018244242424242424224180000;//0
assign digital[1] = 128'h000000083808080808080808083E0000;//1
assign digital[2] = 128'h0000003C4242420204081020427E0000;//2
assign digital[3] = 128'h0000003C4242020418040242423C0000;//3
assign digital[4] = 128'h000000040C0C142424447F04041F0000;//4
assign digital[5] = 128'h0000007E404040784402024244380000;//5
assign digital[6] = 128'h000000182440405C62424242221C0000;//6
assign digital[7] = 128'h0000007E420404080810101010100000;//7
assign digital[8] = 128'h0000003C4242422418244242423C0000;//8
assign digital[9] = 128'h0000003844424242463A020224180000;//9
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            pixel_data <= 0;
        end else begin
            if((pixel_xpos >= ball_xpos && pixel_xpos <= ball_xpos+7) && (pixel_ypos>=ball_ypos && pixel_ypos <= ball_ypos+7))begin
                if(mydisplay[shadow][(8+ball_ypos - pixel_ypos)*8 - ((pixel_xpos-ball_xpos)%8) -1])begin
                    pixel_data <= 16'hF0FF; 
                end else begin
                    pixel_data <= 0;
                end
            end else if((pixel_ypos >= racket_Axpos && pixel_ypos <= racket_Axpos+25) && (pixel_xpos>=racket_A && pixel_xpos <= racket_A+3))begin  
                pixel_data <= 16'h00FF;
            end else if((pixel_ypos >= racket_Bxpos && pixel_ypos <= racket_Bxpos+25) && (pixel_xpos>=racket_B && pixel_xpos <= racket_B+3))begin  
                pixel_data <= 16'h00FF;
            end else if((pixel_ypos >= boundary_R-2 && pixel_ypos <= boundary_R) && pixel_xpos)begin  //right boundary
                pixel_data <= 16'h000F;
            end else if((pixel_ypos >= boundary_L && pixel_ypos <= boundary_L+2) && pixel_xpos)begin  //left boundary
                pixel_data <= 16'h000F;
            end else if((pixel_xpos > 50 && pixel_xpos <= 58) && (pixel_ypos>300 && pixel_ypos <= 316))begin //A has higher score
                if(digital[coreA_H][(300 - pixel_ypos)*8 - ((pixel_xpos-50)%8) -1])begin
                    pixel_data <= 16'hF0FF; 
                end else begin
                    pixel_data <= 0;
                end
            end else if((pixel_xpos > 58 && pixel_xpos <= 66) && (pixel_ypos>300 && pixel_ypos <= 316))begin //A has lower score
                if(digital[coreA_L][(300 - pixel_ypos)*8 - ((pixel_xpos-58)%8) -1])begin
                    pixel_data <= 16'hF0FF; 
                end else begin
                    pixel_data <= 0;
                end
            end else if((pixel_xpos > 570 && pixel_xpos <= 578) && (pixel_ypos>300 && pixel_ypos <= 316))begin // B has higher score
                if(digital[coreB_H][(300 - pixel_ypos)*8 - ((pixel_xpos-50)%8) -1])begin
                    pixel_data <= 16'hF0FF; 
                end else begin
                    pixel_data <= 0;
                end
            end else if((pixel_xpos > 578 && pixel_xpos <= 586) && (pixel_ypos>300 && pixel_ypos <= 316))begin // B has lower score
                if(digital[coreB_L][(300 - pixel_ypos)*8 - ((pixel_xpos-58)%8) -1])begin
                    pixel_data <= 16'hF0FF; 
                end else begin
                    pixel_data <= 0;
                end
            end else if((pixel_xpos>=318 && pixel_xpos<=322) && (pixel_ypos>=20 && pixel_ypos<=270) && (pixel_ypos[3]))begin
                pixel_data <= 16'h000F; 
            end else begin
                pixel_data <= 0;
            end
        end
    end
endmodule

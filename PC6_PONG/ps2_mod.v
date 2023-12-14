module ps2_mod(
    input               clk      ,
    input               rstn     ,
    input               ps2_clk  ,
    input               ps2_dat  ,
    output  reg         ps2_done ,
    output  reg  [7:0]  ps2_data  
);

reg [2:0] ps2_clk_d;
reg [2:0] ps2_dat_d;
always@(posedge clk)
    begin
        ps2_clk_d <= {ps2_clk_d[1:0],ps2_clk};
        ps2_dat_d <= {ps2_dat_d[1:0],ps2_dat};
    end
reg [7:0] reg_data;
reg [3:0] state   ;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            reg_data <= 0;
            state    <= 0;
        end else if(ps2_clk_d[2:1] == 2)begin
            case(state)
                 0:begin state<=1 ; reg_data<=0; end
                 1:begin state<=2 ; reg_data[0]<=ps2_dat_d[2]; end
                 2:begin state<=3 ; reg_data[1]<=ps2_dat_d[2]; end
                 3:begin state<=4 ; reg_data[2]<=ps2_dat_d[2]; end
                 4:begin state<=5 ; reg_data[3]<=ps2_dat_d[2]; end
                 5:begin state<=6 ; reg_data[4]<=ps2_dat_d[2]; end
                 6:begin state<=7 ; reg_data[5]<=ps2_dat_d[2]; end
                 7:begin state<=8 ; reg_data[6]<=ps2_dat_d[2]; end
                 8:begin state<=9 ; reg_data[7]<=ps2_dat_d[2]; end
                 9:begin state<=10; end
                10:begin state<=0 ; end
            endcase
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            ps2_done <= 0;
            ps2_data <= 0;
        end else if(ps2_clk_d[2:1]==2 && state==10)begin
            ps2_done <= 1;
            ps2_data <= reg_data;
        end else begin
            ps2_done <= 0;
        end
    end
endmodule

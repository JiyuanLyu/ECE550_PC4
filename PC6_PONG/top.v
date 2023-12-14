module top(
    input                clk      ,
    input                rstn     ,
    input                playerA_R,
    input                playerA_L,
    input                playerB_R,
    input                playerB_L,
    input                ps2_clk  ,
    input                ps2_dat  ,
    input                StartStop,
    output               beep     ,
    output               vga_hs   ,       
    output               vga_vs   ,       
    output  reg          vga_clk  ,
    output               vga_blank,
    output               vga_sync ,
    output       [7:0]   vga_R    ,       
    output       [7:0]   vga_G    ,       
    output       [7:0]   vga_B            
);
wire S_playerA_R;  //player A
wire S_playerA_L;  
wire S_playerB_R;  //player B
wire S_playerB_L;  
wire        ps2_done;
wire [7:0]  ps2_data;
shake shake_u1(
    .clk    (clk        ),  //input     clk  ,
    .rstn   (rstn       ),  //input     rstn ,
    .key    (playerA_R  ),  //input     key  ,
    .shape  (S_playerA_R)   //output    shape 
);
shake shake_u2(
    .clk    (clk        ),  //input     clk  ,
    .rstn   (rstn       ),  //input     rstn ,
    .key    (playerA_L  ),  //input     key  ,
    .shape  (S_playerA_L)   //output    shape 
);
shake shake_u3(
    .clk    (clk        ),  //input     clk  ,
    .rstn   (rstn       ),  //input     rstn ,
    .key    (playerB_R  ),  //input     key  ,
    .shape  (S_playerB_R)   //output    shape 
);
shake shake_u4(
    .clk    (clk        ),  //input     clk  ,
    .rstn   (rstn       ),  //input     rstn ,
    .key    (playerB_L  ),  //input     key  ,
    .shape  (S_playerB_L)   //output    shape 
);
ps2_mod ps2_mod_u(
    .clk       (clk     ),  //input               clk      ,
    .rstn      (rstn    ),  //input               rstn     ,
    .ps2_clk   (ps2_clk ),  //input               ps2_clk  ,
    .ps2_dat   (ps2_dat ),  //input               ps2_dat  ,
    .ps2_done  (ps2_done),  //output  reg         ps2_done ,
    .ps2_data  (ps2_data)   //output  reg  [7:0]  ps2_data  
);         
wire  [10:0]  pixel_xpos;    
wire  [10:0]  pixel_ypos;    
wire  [10:0]  h_disp    ;   
wire  [10:0]  v_disp    ;    
wire  [15:0]  pixel_data;    
wire  [15:0]  lcd_rgb_o ;    
wire  [15:0]  lcd_rgb_i ;    

//*****************************************************
//**                    main code
//*****************************************************
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            vga_clk <= 0;
        end else begin
            vga_clk <= !vga_clk;
        end
    end
//VGA
wire [15:0] vga_rgb;
vga_driver vga_driver_u(
    .vga_clk     (vga_clk   ),  //vga_clk
    .sys_rst_n   (rstn      ),  //input sys_rst_n     
    .vga_hs      (vga_hs    ),  //output  vga_hs  
    .vga_vs      (vga_vs    ),  //output   vga_vs   
    .vga_rgb     (vga_rgb   ),  //output  [15:0]  vga_rgb 
    .pixel_data  (pixel_data),  //input   [15:0]  pixel_data
    .data_req    (data_req  ),  //output          data_req   
    .pixel_xpos  (pixel_xpos),  //output  [10:0]  pixel_xpos
    .pixel_ypos  (pixel_ypos),  //output  [10:0]  pixel_ypos     
);   
    
lcd_display lcd_display_u(
    .clk          (clk        ),  //input clk        
    .rstn         (rstn       ),  //input rstn       
    .StartStop    (StartStop  ),  //input StartStop  
    .S_playerA_R  (S_playerA_R),  //input S_playerA_R
    .S_playerA_L  (S_playerA_L),  //input S_playerA_L
    .S_playerB_R  (S_playerB_R),  //input S_playerB_R
    .S_playerB_L  (S_playerB_L),  //input S_playerB_L
    .ps2_done     (ps2_done   ),  //input ps2_done 
    .ps2_data     (ps2_data   ),  //input [7:0] ps2_data  
    .beep         (beep       ),  //output  beep       
    .pixel_xpos   (pixel_xpos ),  //input [10:0] pixel_xpos 
    .pixel_ypos   (pixel_ypos ),  //input [10:0] pixel_ypos 
    .h_disp       (h_disp     ),  //input [10:0] h_disp     
    .v_disp       (v_disp     ),  //input [10:0] v_disp     
    .pixel_data   (pixel_data )   //output[15:0] pixel_data   
);
assign vga_blank = 1;
assign vga_sync  = 1;
assign vga_R = {vga_rgb[15:11],{3{vga_rgb[15]}}};
assign vga_G = {vga_rgb[10:5 ],{2{vga_rgb[10]}}};
assign vga_B = {vga_rgb[4 :0 ],{3{vga_rgb[4 ]}}};
endmodule

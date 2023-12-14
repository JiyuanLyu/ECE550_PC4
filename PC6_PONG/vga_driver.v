module vga_driver(
    input           vga_clk,      //VGA clock
    input           sys_rst_n,    //reset signal
    //VGA                          
    output          vga_hs,       //horizontal signal
    output          vga_vs,       //vertical signal
    output  [15:0]  vga_rgb,      //rgb output

    input   [15:0]  pixel_data,   
    output          data_req  ,    
    output  [10:0]  pixel_xpos,   //pixel horizontal
    output  [10:0]  pixel_ypos    //pixel vertical    
);                             
  

//640*480 VGA
parameter  H_SYNC   =  10'd96;    
parameter  H_BACK   =  10'd48;    
parameter  H_DISP   =  10'd640;   
parameter  H_FRONT  =  10'd16;    
parameter  H_TOTAL  =  10'd800;  

parameter  V_SYNC   =  10'd2;     
parameter  V_BACK   =  10'd33;    
parameter  V_DISP   =  10'd480;   
parameter  V_FRONT  =  10'd10;    
parameter  V_TOTAL  =  10'd525;   

//reg define                                     
reg  [10:0] cnt_h;               
reg  [10:0] cnt_v;

//wire define
wire       vga_en;


//main code

//VGA signal
assign vga_hs  = (cnt_h <= H_SYNC - 1'b1) ? 1'b0 : 1'b1;
assign vga_vs  = (cnt_v <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;


assign vga_en  = (((cnt_h >= H_SYNC+H_BACK) && (cnt_h < H_SYNC+H_BACK+H_DISP))
                 &&((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                 ?  1'b1 : 1'b0;
                 
//RGB output                 
assign vga_rgb = vga_en ? pixel_data : 16'd0;

//pixel              
assign data_req = (((cnt_h >= H_SYNC+H_BACK-1'b1) && (cnt_h < H_SYNC+H_BACK+H_DISP-1'b1))
                  && ((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                  ?  1'b1 : 1'b0;

//pixel coordinate               
assign pixel_xpos = data_req ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 10'd0;
assign pixel_ypos = data_req ? (cnt_v - (V_SYNC + V_BACK - 1'b1)) : 10'd0;

//horizontal pixel clock
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)
        cnt_h <= 10'd0;                                  
    else begin
        if(cnt_h < H_TOTAL - 1'b1)                                               
            cnt_h <= cnt_h + 1'b1;                               
        else 
            cnt_h <= 10'd0;  
    end
end

//vertical pixel clock
always @(posedge vga_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)
        cnt_v <= 10'd0;                                  
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)                                               
            cnt_v <= cnt_v + 1'b1;                               
        else 
            cnt_v <= 10'd0;  
    end
end

endmodule 
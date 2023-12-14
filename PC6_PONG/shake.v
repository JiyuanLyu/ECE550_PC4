module shake(
    input     clk  ,
    input     rstn ,
    input     key  ,
    output    shape 
);

reg [25:0] cnt;
parameter num = 299999;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt <= 0;
        end else begin
            if(cnt == num)begin
                cnt <= 0;
            end else begin
                cnt <= cnt+1;
            end
        end
    end
assign shape = (cnt == num) ? (!key) : 0;


endmodule


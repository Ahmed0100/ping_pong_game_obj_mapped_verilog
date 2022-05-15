module pong_text(clk,reset,x_pixel,y_pixel,ball,dig0,dig1,text_rgb,text_on);
input clk,reset;
input [9:0] x_pixel,y_pixel;
input [1:0] ball;
input [3:0] dig0,dig1;
output reg [2:0] text_rgb;
output wire [3:0] text_on;
wire font_bit;
wire score_on;
wire [3:0] row_addr_score;
reg [3:0] row_addr;
wire [2:0] bit_addr_score;
wire [7:0] font_word;
reg [6:0] char_word_score,char_word_logo,char_word;
wire logo_on;
wire [3:0] row_addr_logo;
wire [2:0] bit_addr_logo;
reg [2:0] bit_addr;
wire [10:0] rom_addr;
font_rom u1(.clk(clk),.addr(rom_addr),.data_reg(font_word));

assign score_on=(y_pixel<32) &&(x_pixel<256);
assign row_addr_score=y_pixel[4:1];
assign bit_addr_score=x_pixel[3:1];


always @*
	case(x_pixel[7:4])
		0: char_word_score=7'd0; //S
		1: char_word_score=7'd1;//c
		2: char_word_score=7'd2;//o
		3: char_word_score=7'd3;//r
		4: char_word_score=7'd4;//e
		5: char_word_score=7'd5;//:
		6: char_word_score=7'd6;
		7: char_word_score=7'd7;   
		8: char_word_score=7'd8;
		9: char_word_score=7'd9;//
		10: char_word_score=7'd10;//b
		11: char_word_score=7'd11;//a
		12: char_word_score=7'd12;//l
		13: char_word_score=7'd13;//l
		14: char_word_score=7'd14;//:
		15: char_word_score=7'd15;
	endcase   

//logo region 
assign logo_on=(y_pixel[9:7]==2)&&(x_pixel[9:6]>=3)&&(x_pixel[9:6]<=6);
assign row_addr_logo=y_pixel[6:3];
assign bit_addr_logo=x_pixel[5:3];
always @*
	case(x_pixel[8:6])
		3: char_word_logo=7'd16;
		4: char_word_logo=7'd17;
		5: char_word_logo=7'd18;
		6: char_word_logo=7'd19;
	endcase
		
always @*
begin
	text_rgb=3'b000;
	if(score_on)
		begin
		char_word=char_word_score;
		row_addr=row_addr_score;
		bit_addr=bit_addr_score;
		if(font_bit)
			text_rgb=3'b001;
		end
	else if(logo_on)
		begin
		char_word=char_word_logo;
		row_addr=row_addr_logo;
		bit_addr=bit_addr_logo;
		if(font_bit)
			text_rgb=3'b011;
		end
end

assign rom_addr={char_word,row_addr};
assign text_on={score_on,logo_on,1'b0,1'b0};
assign font_bit=font_word[~bit_addr];

endmodule 
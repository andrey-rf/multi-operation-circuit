module ex0(clk, number, control, LEDG, LEDR);

input [4:0]number;
input control, clk;

wire change;
wire cancel;
wire enter;

wire [17:0] s;

output reg[7:0] LEDG;
output reg[17:0] LEDR;

reg[7:0] outg = 0;
reg[17:0] outr = 0;

parameter 
	select_al = 0,
	select_am = 1,
	select_bl = 2,
	select_bm = 3,
	result_l = 4,
	result_m = 5;
	
reg[2:0] state, next_state; 
	
virtual_input VI (.number(number), .control(control), .button0(change), .button1(enter), .button2(cancel),
	.switch0(s[0]), .switch1(s[1]), .switch2(s[2]), .switch3(s[3]), .switch4(s[4]), .switch5(s[5]),
	.switch6(s[6]), .switch7(s[7]), .switch8(s[8]), .switch9(s[9]), .switch10(s[10]), .switch11(s[11]),
	.switch12(s[12]), .switch13(s[13]), .switch14(s[14]), .switch15(s[15]), .switch16(s[16]), .switch17(s[17]));

always @(*)
begin
	if (cancel)
		next_state <= select_al;
	else
	begin
		if (!change && !enter)
		begin
			state <= next_state;
		end
		
		case(state)
		select_al:
			if (change)
			begin
				next_state <= select_am;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
		
		select_am:
			if (change)
			begin
				next_state <= select_bl;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
			
		select_bl:
			if (change)
			begin
				next_state <= select_bm;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
			
		select_bm:
			if (change)
			begin
				next_state <= select_al;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
			
		result_l:
			if (change)
			begin
				next_state <= result_l;
			end
			else if (enter)
			begin
				next_state <= result_m;
			end
			
		result_m:
			if (change)
			begin
				next_state <= result_m;
			end
			else if (enter)
			begin
				next_state <= result_l;
			end
		endcase
	end
end

always @(posedge clk or posedge cancel)
begin
	if (cancel)
	begin
		outg <= 0;
		s <= 0;
	end
	else
	begin
		outr <= s;
		
		if (state == select_al)
			outg <= 8'b10000000;
		else if (state == select_am)
			outg <= 8'b01000000;
		else if (state == select_bl)
			outg <= 8'b00100000;
		else if (state == select_bm)
			outg <= 8'b00010000;
		else if (state == result_l)
			outg <= 8'b00000010;
		else if (state == result_m)
			outg <= 8'b00000001;
	end
	
	LEDR <= outr;
	LEDG <= outg;
end

endmodule
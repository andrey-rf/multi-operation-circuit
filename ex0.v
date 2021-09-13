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
reg[31:0] a = 0;
reg[31:0] b = 0;
reg[31:0] result = 0;

wire[1:0] op;

assign op = s[1:0];

parameter 
	select_al = 0,
	select_am = 1,
	select_bl = 2,
	select_bm = 3,
	result_l = 4,
	result_m = 5;
	
reg[2:0] state;
reg[2:0] next_state = select_al; 
	
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
				next_state <= select_bm;
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

always @(posedge clk or posedge cancel or posedge change or posedge enter)
begin
	if (cancel)
	begin
		outg <= 0;
	end
	else
	begin
		case (state)
			select_al:
			begin
				outr <= s;
				outg <= 8'b10000000;
				
				if (change)
					a[15:0] <= s[17:2];
				else if (enter)
					case (op)
					0: result <= a + b;
					1: result <= a - b;
					2: result <= a | b;
					3: result <= a & b;
					endcase
			end
			
			select_am:
			begin
				outr <= s;
				outg <= 8'b01000000;
				
				if (change)
					a[31:16] <= s[17:2];
				else if (enter)
					case (op)
					0: result <= a + b;
					1: result <= a - b;
					2: result <= a | b;
					3: result <= a & b;
					endcase
			end
			
			select_bl:
			begin
				outr <= s;
				outg <= 8'b00100000;
				
				if (change)
					b[15:0] <= s[17:2];
				else if (enter)
					case (op)
					0: result <= a + b;
					1: result <= a - b;
					2: result <= a | b;
					3: result <= a & b;
					endcase
			end
			
			select_bm:
			begin
				outr <= s;
				outg <= 8'b00010000;
				
				if (change)
					b[31:16] <= s[17:2];
				else if (enter)
				begin
					b[31:16] <= s[17:2];
					
					case (op)
					0: result <= a + b;
					1: result <= a - b;
					2: result <= a | b;
					3: result <= a & b;
					endcase
				end
			end
			
			result_l:
			begin
				outr[17:2] <= result[15:0];
				outg <= 8'b00000010;
			end
			
			result_m:
			begin
				outr[17:2] <= result[31:16];
				outg <= 8'b00000001;
			end
		endcase
	end
	
	LEDR <= outr;
	LEDG <= outg;
end

endmodule
`timescale 1ns / 1ps
//////////////////////
module hemming(
    input wire [11:1] ACC_DATA, 			//данные на входе
    output reg	[6:1] COR_DATA,				//данные после проверки и коррекции
	output reg [4:1] ERROR_CODE,			//номер бита с ошибкой
    output reg DOUBLE_ERROR					//уведомление о более чем одном неправильном бите
    );
	 
	reg P1;
	reg P2;
	reg P4;
	reg P8;
	
	reg CONTROL_BIT;
	reg SINGLE_ERROR_REG;
	reg DOUBLE_ERROR_REG;
	
	always@(ACC_DATA) begin
		P1 = ACC_DATA[1] ^ ACC_DATA[3] ^ ACC_DATA[5] ^ ACC_DATA[7] ^ ACC_DATA[9];
		P2 = ACC_DATA[2] ^ ACC_DATA[3] ^ ACC_DATA[6] ^ ACC_DATA[7] ^ ACC_DATA[10];
		P4 = ACC_DATA[4] ^ ACC_DATA[5] ^ ACC_DATA[6] ^ ACC_DATA[7];
		P8 = ACC_DATA[8] ^ ACC_DATA[9] ^ ACC_DATA[10];
		
		CONTROL_BIT = ^ACC_DATA;
		
		SINGLE_ERROR_REG = CONTROL_BIT & (P1 | P2 | P4 | P8);
		DOUBLE_ERROR_REG = ~(CONTROL_BIT | ~(P1 | P2 | P4 | P8));
		
		
		if((SINGLE_ERROR_REG || DOUBLE_ERROR_REG) == 0) begin
			COR_DATA[1] <= ACC_DATA[3];
			COR_DATA[2] <= ACC_DATA[5];
			COR_DATA[3] <= ACC_DATA[6];
			COR_DATA[4] <= ACC_DATA[7];
			COR_DATA[5] <= ACC_DATA[9];
			COR_DATA[6] <= ACC_DATA[10];
			
			ERROR_CODE <= 4'b0000;
			
			SINGLE_ERROR_REG <= 1'b0;
			DOUBLE_ERROR <= 1'b0;
		end
		else if (DOUBLE_ERROR_REG == 1) begin
			DOUBLE_ERROR <= DOUBLE_ERROR_REG;
			COR_DATA <= 6'bzzzzzz;
			ERROR_CODE <= 4'bzzzz;
			SINGLE_ERROR_REG <= 1'b0;
		end
		else if (SINGLE_ERROR_REG == 1) begin
			COR_DATA[1] <= ACC_DATA[3]^(P1 & P2 & ~P4 & ~P8);
			COR_DATA[2] <= ACC_DATA[5]^(P1 & ~P2 & P4 & ~P8);
			COR_DATA[3] <= ACC_DATA[6]^(~P1 & P2 & P4 & ~P8);
			COR_DATA[4] <= ACC_DATA[7]^(P1 & P2 & P4 & ~P8);
			COR_DATA[5] <= ACC_DATA[9]^(P1 & ~P2 & ~P4 & P8);
			COR_DATA[6] <= ACC_DATA[10]^(~P1 & P2 & ~P4 & P8);
			
			ERROR_CODE[1] <= P1;
			ERROR_CODE[2] <= P2;
			ERROR_CODE[3] <= P4;
			ERROR_CODE[4] <= P8;
			
			DOUBLE_ERROR <= 1'b0;
		end
	end
	

endmodule

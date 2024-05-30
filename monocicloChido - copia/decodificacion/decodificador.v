//Encabezado

module decodificador(
	input		[6:0] opcode_i,
	output reg		regwrite_o,
	output reg		alusrc_o,
	output reg		branch_0
);

	always @(*)
	begin
		case (opcode_i)
			7'b0010011:		//Tipo I
				begin
					regwrite_o = 1'b1;
					alusrc_o = 1'b1;
					branch_o=0'b0;
					//memread_o=
					//memwrite_o=
				end
			7'b0110011:		//Tipo R
				begin
					regwrite_o = 1'b1;
					alusrc_o = 1'b1;
					branch_o=0'b0;
				end
			7'b0110011:		//Tipo B
				begin
					regwrite_o = 0'b0;
					alusrc_o = 0'b0;
					branch_o=1'b1;
				end
			default: 		//Instrucción no soportada
				begin
					regwrite_o = 1'b0;
					alusrc_o = 1'b0;
					branch_o=0'b0;
				end
		endcase
	end

endmodule
/*
	Grupo:			5CV3
	Proyecto:		Monociclo
	Archivo:			monociclo.v
	Equipo:			Equipo 2
	Integrantes:	Alcaraz Cuevas Victor Hugo
					Montoya Morales Luis Antonio
					Navarrete Becerril Sharon Anette
					Quintana Romero Roberto
					Urdaneta Villalobos Paul Alejandro

	Descripcion:	Encapsulamiento para la obtención de la instrucción
*/

module monociclo(
	input					clk_i,
	input					rst_ni,
	output	[31:0]			salida_o
);

	// Fetch Instruction
	wire 	[31:0]		if_pc_w;
	wire 	[31:0]		if_pcnext_sum_w;
	wire	[31:0]		if_pcnext_branch_w;
	wire	[31:0]		if_pcnext_w;
	wire 	[31:0]		if_shift_w;
	wire				if_pcselector_w;
	// Register File & Instruction Decoder
	wire 	[31:0]		rf_inst_w;
	wire	[31:0]		ex_datars1_w;
	wire	[31:0]		ex_datars2_w;
	wire				ex_zero_w;
	wire 				id_regwrite_w;
	wire	[31:0]		es_data_w;
	wire 	[31:0]		muxalu_data_w;
	wire				id_alusrc_w;
	wire 	[31:0]		ex_alurs_w;
	wire 	[31:0]		mem_rddata_w;
	wire	[31:0]		wb_data_w;
	wire				id_memtoreg_w;
	wire				id_memwrite_w;
	wire				id_memread_w;
	wire				id_branch_i;
	wire	[4:0]		aluop_w;

	// Fetch Instruction
	PC pc1(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.pcnext_i(if_pcnext_w),
		.pc_o(if_pc_w)
	);
	
	sll1bit sllmod(
		.entrada_i(es_data_w),
		.salida_o(if_shift_w)
	);

	assign if_pcnext_sum_w = if_pc_w + 32'h4;
	assign if_pcnext_branch_w = if_shift_w + if_pc_w;
	assign if_pcselector_w = id_branch_i & ex_zero_w;
	assign if_pcnext_w = if_pcselector_w ? if_pcnext_branch_w : if_pcnext_sum_w;
	
	icache IC(
		.rdaddr_i(if_pc_w[7:2]),
		.inst_o(rf_inst_w)
	);
	
	// Register File & Instruction Decoder
	decoder deco(
		.opcode_i(rf_inst_w[6:0]),
		.regwrite_o(id_regwrite_w),
		.branch_o(id_branch_w),
		.alusrc_o(id_alusrc_w),
		.memtoreg_o(id_memtoreg_w),
		.memwrite_o(id_memwrite_w),
		.memread_o(id_memread_w)
	);
	
	// Tarea
	regfile register(
		.clk_i(clk_i),
		.rs1_i(rf_inst_w[19:15]),
		.rs2_i(rf_inst_w[24:20]),
		.rd_i(rf_inst_w[11:7]),
		.we_i(id_regwrite_w),
		.datord_i(wb_data_w),
		.dators1_o(ex_datars1_w),
		.dators2_o(ex_datars2_w)
	);
	
	ALUControl aluctr(
		.opcode_i(rf_inst_w[6:0]),
		.fun3_i(rf_inst_w[14:12]),
		.fun7_i(rf_inst_w[30]),
		.aluop_o(aluop_w)
	);
	
	signextend sigex(
		.inst_i(rf_inst_w),
		.imm_o(es_data_w)
	);
	
	
	// Multiplexor segundo operando de la alu
	assign muxalu_data_w = id_alusrc_w ? es_data_w : ex_datars2_w;
	
	// Execution & Write Back
	ALUNBits #(
		.N(32)
	)
	(
		.a_i(ex_datars1_w),
		.b_i(muxalu_data_w),
		.c_i(aluop_w[4]),
		.invert_i(aluop_w[4]),
		.operacion_i(aluop_w[3:0]),
		.resultado_o(ex_alurs_w),
		.c_o(ex_zero_w)
	);

	// Memory
	memory mem(
		.clk_i(clk_i),
		.address_i(ex_alurs_w),
		.wdata_i(ex_datars2_w),
		.memwrite_i(id_memwrite_w),
		.memread_i(id_memread_w),
		.rdata_o(mem_rddata_w)
	);
	
	assign wb_data_w = id_memtoreg_w ? mem_rddata_w : ex_alurs_w;
	assign salida_o = ex_alurs_w;

endmodule

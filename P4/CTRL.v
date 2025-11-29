`include "def.v"
`define SPECIAL 6'b0
`define ADD 6'b100000 // func
`define SUB 6'b100010 // func
`define ORI 6'b001101
`define LW 6'b100011
`define SW 6'b101011
`define BEQ 6'b000100
`define LUI 6'b001111
`define SLL 6'b000000 //func
`define J 6'b000010
`define JAL 6'b000011
`define JR 6'b001000
`define JALR 6'b001001
`define TFTC 6'b011101
`define LBOEZ 6'b111110
`define PCADD 6'b110001

module CTRL (
    input [5:0] opcode,
    input [5:0] func,
    output [2:0] NPCOp,
    output [2:0] WDSel,
    output WESel,
    output [2:0] WRA3Sel,
    output [2:0] ALUOp,
    output BSel,
    output EXTOp,
    output DMWr
);

wire add,sub,ori,lw,sw,beq,lui,sll,j,jal,jr,jalr,tftc,lboez;

assign add = (opcode == `SPECIAL) && (func == `ADD);
assign sub = (opcode == `SPECIAL) && (func == `SUB);
assign ori = (opcode == `ORI);
assign lw = (opcode == `LW);
assign sw = (opcode == `SW);
assign beq = (opcode == `BEQ);
assign lui = (opcode == `LUI);
assign sll = (func == `SLL) && (opcode == `SPECIAL);
assign j = (opcode == `J);
assign jal = (opcode == `JAL);
assign jr = (func == `JR) && (opcode == `SPECIAL);
assign jalr = (func == `JALR) && (opcode == `SPECIAL);
assign tftc = (opcode == `SPECIAL) && (func == `TFTC);
assign lboez = (opcode == `LBOEZ);
assign pcadd = (opcode == `SPECIAL) && (func == `PCADD);

// 3'b000	PC+4作为次地址
// 3'b001	beq
// 3'b010	j,jal
// 3'b011	jr,jalr
assign NPCOp[0] = beq | jalr | jr;
assign NPCOp[1] = j | jal | jalr | jr;
assign NPCOp[2] = 0;

// 3'b000	写入寄存器的数据来自ALU的运算结果
// 3'b001	写入寄存器的数据来自DM
// 3'b010	写入寄存器的数据是PC+4
// 3'b011   写入寄存器的数据来自 sub_RD
assign WDSel[0] = lw | lboez;
assign WDSel[1] = jal | jalr | lboez;
assign WDSel[2] = 0;

assign WESel = add | sub | ori | lw | lui | sll | jal | jalr | tftc | lboez | pcadd;

// 3'b000	rt作为写入数据的目标寄存器
// 3'b001	rd作为写入数据的目标寄存器
// 3'b010	$31作为写入数据的目标寄存器
assign WRA3Sel[0] = add | sub | sll | jalr | tftc | pcadd;
assign WRA3Sel[1] = jal;
assign WRA3Sel[2] = 0;

// 3'b000	add
// 3'b001	sub
// 3'b010	ori
// 3'b011	lui
// 3'b100	sll
// 3'b101   tftc
// 3'b110   pcadd
assign ALUOp[0] = sub | beq | lui | tftc ;
assign ALUOp[1] = ori | lui | pcadd;
assign ALUOp[2] = sll| tftc | pcadd;

assign BSel = ori | lw | sw | lui | lboez;

assign EXTOp = lw | sw | lboez;

assign DMWr = sw ;

endmodule

// always @(*) begin
//     if (add == 1) begin
//         WESel = 1;
//         WRA3Sel[0] = 1;
//     end
// end
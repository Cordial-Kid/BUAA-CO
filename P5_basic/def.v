//define of D_CMP
`define CMP_BEQ 3'b000

//define of D_NPC
`define NPC_PC4 3'b000
`define NPC_BEQ 3'b001
`define NPC_J_Jal 3'b010
`define NPC_Jr_Jalr 3'b011

//define of ALUOp
`define ALU_add 3'b000
`define ALU_sub 3'b001
`define ALU_ori 3'b010
`define ALU_sll 3'b011
`define ALU_lui 3'b100

//define of instruction
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
`define JR 6'b001000  //func
`define JALR 6'b001001   //func

//define of EXTOp
`define EXT_ZERO 1'b0
`define EXT_SIGN 1'b1


//define of ALUB
`define ALUBrt 1'b0
`define ALUBimm 1'b1


//define of GRFWD
`define GRFWDALU 3'b000
`define GRFWDDM 3'b001
`define GRFWDPC8 3'b010

//define of GRFA3
`define GRFA3rt 3'b000
`define GRFA3rd 3'b001
`define GRFA331 3'b010
`define GRFA30 3'b011

//define of DMWE
`define DMWE_ZERO 1'b0
`define DMWE_ONE 1'b1
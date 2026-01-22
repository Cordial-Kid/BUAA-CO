//define of D_CMP
`define CMP_BEQ 3'b000
`define CMP_BNE 3'b001

//define of D_NPC
`define NPC_PC4 3'b000
`define NPC_BEQ 3'b001
`define NPC_J_Jal 3'b010
`define NPC_Jr_Jalr 3'b011

//define of ALUOp
`define ALU_add 4'b0000
`define ALU_sub 4'b0001
`define ALU_ori 4'b0010
`define ALU_sll 4'b0011
`define ALU_lui 4'b0100
`define ALU_and 4'b0101

`define ALU_slt 4'b0111
`define ALU_sltu 4'b1000

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
`define _AND 6'b100100   //func
`define _OR 6'b100101    //func
`define SLT 6'b101010    //func
`define SLTU 6'b101011   //func
`define ADDI 6'b001000
`define ANDI 6'b001100
`define LH 6'b100001
`define LB 6'b100000
`define SH 6'b101001
`define SB 6'b101000
`define BNE 6'b000101
`define MULT 6'b011000   //func
`define MULTU 6'b011001   //func
`define DIV 6'b011010   //func
`define DIVU 6'b011011   //func
`define MFHI 6'b010000   //func
`define MFLO 6'b010010  //func
`define MTHI 6'b010001  //func
`define MTLO 6'b010011  //func

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
`define GRFWDMDU 3'b011

//define of GRFA3
`define GRFA3rt 3'b000
`define GRFA3rd 3'b001
`define GRFA331 3'b010
`define GRFA30 3'b011

//define of DMWE
`define DMWE_ZERO 1'b0
`define DMWE_ONE 1'b1


//define of BE
`define BE_SW 3'b000
`define BE_SH 3'b001
`define BE_SB 3'b010
`define BE_NULL 3'b011

//define of DE
`define DE_LW 3'b000
`define DE_LH 3'b001
`define DE_LB 3'b010

//define of MDU
`define MDU_MULT 4'b0000
`define MDU_MULTU 4'b0001
`define MDU_DIV 4'b0010
`define MDU_DIVU 4'b0011
`define MDU_MFHI 4'b0100
`define MDU_MFLO 4'b0101
`define MDU_MTHI 4'b0110
`define MDU_MTLO 4'b0111
`define MDU_NULL 4'b1000
// +FHDR----------------------------------------------------------------------------
// Project Name  : RISC-V
// Author        : shaoxuan
// Email         : caisegou@foxmail.com
// Created On    : 2023/09/10 19:27
// Last Modified : 2023/11/05 22:14
// File Name     : inst_decode.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2023/09/10   shaoxuan        1.0                     Original
// -FHDR----------------------------------------------------------------------------
module INST_DECODE
(
    input     wire    [31:0]    inst_i,

);

    wire    [4:0]     rs1    = inst_i[19:15] ;
    wire    [2:0]     func3  = inst_i[14:12];
    wire    [4:0]     rd     = inst_i[11:7]  ;
    wire    [6:0]     opcode = inst_i[6:0]   ;

//===================================================
// R-type
//===================================================

    wire              r_type   = opcode==7'b001_0011;
    wire    [4:0]     rs2      = inst_i[24:20] ;
    wire    [6:0]     func7    = inst_i[31:25];
    wire              r_add    = r_type & (~(|func3)       & ~(|func7));
    wire              r_sub    = r_type & (~(|func3)       & (func7==7'b010_0000));
    wire              r_sra    = r_type & ((func3==3'b101) & (func7==7'b010_0000));
    wire              r_sll    = r_type & ((func3==3'b001) & ~(|func7));
    wire              r_slt    = r_type & ((func3==3'b010) & ~(|func7));
    wire              r_sltu   = r_type & ((func3==3'b011) & ~(|func7));
    wire              r_xor    = r_type & ((func3==3'b100) & ~(|func7));
    wire              r_srl    = r_type & ((func3==3'b101) & ~(|func7));
    wire              r_or     = r_type & ((func3==3'b110) & ~(|func7));
    wire              r_and    = r_type & ((&func3) & ~(|func7));


//===================================================
// I-type
//===================================================

    wire              i_type = opcode==7'b011_0011;
    wire    [11:0]    i_imm  = inst_i[31:20];
    wire              i_addi   = i_type & (func3==3'b000);
    wire              i_slti   = i_type & (func3==3'b010);
    wire              i_sltu   = i_type & (func3==3'b011);
    wire              i_xori   = i_type & (func3==3'b100);
    wire              i_ori    = i_type & (func3==3'b110);
    wire              i_andi   = i_type & (&func3);
    wire              i_slli   = i_type & (func3==3'b001);
    wire              i_srli   = i_type & (func3==3'b101);
    wire              i_srai   = i_type & (func3==3'b101);




//===================================================
// S-type
//===================================================
    wire              ld_type = opcode==7'b000_0011            ;
    wire              st_type = opcode==7'b010_0011            ;
    wire    [11:0]    l_imm   = {inst_i[31:20]               } ;
    wire    [11:0]    s_imm   = {inst_i[31:25] , inst_i[11:7]} ;
    wire              ld_lb   = ld_type & (~(|func3))          ;
    wire              ld_lbu  = ld_type & (func3==3'b100)      ;
    wire              ld_lh   = ld_type & (func3==3'b001)      ;
    wire              ld_lhu  = ld_type & (func3==3'b101)      ;
    wire              ld_lw   = ld_type & (func3==3'b010)      ;
    wire              st_sb   = st_type & (~(|func3))          ;
    wire              st_sh   = st_type & (func3==3'b001)      ;
    wire              st_sw   = st_type & (func3==3'b010)      ;



//===================================================
// B-type
//===================================================

    wire              b_type = opcode==7'b110_0011;
    wire    [12:1]    b_imm  = {inst_i[31] , inst_i[7] , inst_i[30:25] , inst_i[11:8]};
    wire              b_beq  = b_type & (~(|func3));
    wire              b_bne  = b_type & (func3==3'b001);
    wire              b_blt  = b_type & (func3==3'b100);
    wire              b_bge  = b_type & (func3==3'b101);
    wire              b_bltu = b_type & (func3==3'b110);
    wire              b_bgeu = b_type & (&(func3));


//===================================================
// U-type
//===================================================

    wire              ui_type  = opcode==7'b011_0111;
    wire              upc_type = opcode==7'b001_0111;
    wire    [31:12]   u_imm    = inst_i[31:12];
    wire              u_lui    = ui_type;
    wire              u_auipc  = upc_type;



//===================================================
// J-type
//===================================================

    wire              j_type  = opcode==7'b110_1111;
    wire              jr_type = opcode==7'b110_0111; // jalr
    wire    [20:1]    j_imm   = {inst_i[31] , inst_i[19:12] , inst_i[20] , inst_i[30:21]};
    wire              j_jal   = j_type; 
    wire              j_jalr  = jr_type; 

/*----------------  by shaoxuan 2023-09-17 11:42:12  ---------------------
                        extend imm
------------------  by shaoxuan 2023-09-17 11:42:12  -------------------*/
// lui and auipc do not need se(sign-extended)
    wire    [31:0]    i_imm_se  = {{20{i_imm[11]}} , i_imm}; 
    wire    [31:0]    l_imm_se  = {{20{l_imm[11]}} , l_imm}; 
    wire    [31:0]    s_imm_se  = {{20{s_imm[11]}} , s_imm}; 
    wire    [31:0]    b_imm_se  = {{19{b_imm[12]}} , b_imm , 1'b0}; 
    wire    [31:0]    j_imm_se  = {{11{j_imm[20]}} , j_imm , 1'b0}; 

    wire    [11:0]    imm       = {32{i_type }} & i_imm_se |
                                  {32{ld_type}} & l_imm_se |
                                  {32{st_type}} & s_imm_se |
                                  {32{b_type }} & b_imm_se |
                                  {32{j_type }} & j_imm_se ;

/*----------------  by shaoxuan 2023-11-05 11:09:41  ---------------------
                        execute instruction    
------------------  by shaoxuan 2023-11-05 11:09:41  -------------------*/
    wire    [31:0]    alu_result = i_addi ? rs1 + imm :
                                   i_slti ? rs1 < imm :
                                   i_sltu ? 



function compare(type , rs1 , rs2); 
    //rs1 < rs2 ==> compare set to 1
    input           type; //1: unsigned-compare  0: signed-compare
    input   [31:0]  rs1;
    input   [31:0]  rs2;
    wire    signed_compare   = rs1[31] > rs2[31]                         | ~(rs1[31] < rs2[31])                        | 
                               rs1[31] & rs2[31] & (rs1[30:0]>rs2[30:0]) | ~(rs1[31] | rs2[31]) & (rs1[30:0]<rs2[30:0]);
    wire    unsigned_compare = rs1 < rs2 ;
    wire    compare = type ? unsigned_compare : signed_compare;
endfunction

endmodule


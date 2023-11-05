// +FHDR----------------------------------------------------------------------------
// Project Name  : RISC-V
// Author        : shaoxuan
// Email         : caisegou@foxmail.com
// Created On    : 2023/09/10 18:49
// Last Modified : 2023/10/16 22:19
// File Name     : inst_fetch.v
// Description   :
//         
// 
// ---------------------------------------------------------------------------------
// Modification History:
// Date         By              Version                 Change Description
// ---------------------------------------------------------------------------------
// 2023/09/10   shaoxuan        1.0                     Original
// -FHDR----------------------------------------------------------------------------
module INST_FETCH
(
    input     wire              sclk_i     ,
    input     wire              srst_i     ,
    input     wire    [31:0]    inst_i     ,
    input     wire              pc_sel_i   , //1: pc jump to pc+jump_imm_i 0: use the cur_pc
    input     wire    [31:0]    jump_imm_i ,
    output    reg     [31:0]    pc_o   

);

//===================================================
// PC Mux
//===================================================

    wire    [31:0]    nxt_pc = pc_sel_i ? pc_o + jump_imm_i : pc_o + 32'h4;

    always @ ( posedge sclk_i or posedge srst_i ) begin
        if( srst_i )begin
            pc_o <= 32'h0;
        end
        else begin
            pc_o <= nxt_pc; 
        end
    end


endmodule


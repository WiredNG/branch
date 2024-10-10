package WiredL1BTB;

`define _BRPACKAGES
`include "WiredBranchHeader.bsv"

    import WiredParam::*;
    import WiredTypes::*;
    import WiredBranchDefines::*;

    // Wired 一级快速预测器
    // 用于连续生成取指包
    // 该预测器结构非常简单
    // 由寄存器堆构成

    typedef struct {
        Bit#(PC_WIDTH) pc; 
        Bit#(PC_WIDTH) br_history;
        Bit#(PC_WIDTH) target;
        Bit#(FID_WIDTH) id;
    } L1BTBUpdate
    #(`_BRPREDPARMSDEF)
    deriving (Bits, Eq, FShow, Bounded);

    interface L1BTB#(`_BRPREDPARMSDEF, numeric type ENTRY_IDX_WIDTH);
        method BranchPredict#(`_BRPREDPARMS) get_predict; // 返回当周期预测结果
        method Action upd(L1BTBUpdate#(`_BRPREDPARMS) upd_info);
        method Action step(); //  预测下一个块
    endinterface

    typedef struct {
        Bool valid;
        Bit#(TAG_WIDTH) tag;
        UInt#(TLog#(FETCH_WIDTH)) offset;
        Bit#(TARGET_WIDTH) target;
    } L1BTBEntry
    #(`_BRPREDPARMSDEF)
    deriving (Bits, Eq, FShow, Bounded);

    module mkL1BTB(L1BTB#(`_BRPREDPARMSDEF, numeric type ENTRY_IDX_WIDTH));
        // 寄存器定义
        Reg#(Bit#(PC_WIDTH)) pc <- mkReg(PC_WIDTH'h1c00_0000); // 复位 PC
        Reg#(Bit#(PC_WIDTH)) br_history <- mkReg('0);

        // 寄存器堆定义
        RegFile_nwmr#(Bit#(ENTRY_IDX_WIDTH), L1BTBEntry#(PC_WIDTH, TAG_WIDTH, TARGET_WIDTH, FETCH_WIDTH), 1, 1) rf <- mkRegFile_nwmr(?);

        method ActionValue#(BranchPredict#(PC_WIDTH, TAG_WIDTH, TARGET_WIDTH, FETCH_WIDTH)) predict;
            Bit#(PC_WIDTH) new_pc = ?;
            Bit#(FETCH_WIDTH) mask = ?;
            let info <- rf.rp[0].r(pc[TAdd#(TLog#(FETCH_WIDTH), TAdd#(1, ENTRY_IDX_WIDTH)): TAdd#(TLog#(FETCH_WIDTH), 2)]);
            if(info.valid && info.tag == get_tag(pc, br_history) && info.offset <= unpack(pc[TAdd#(1, TLog#(FETCH_WIDTH))):2]) begin
                // 需要跳转
                new_pc = {pc[PC_WIDTH : TAdd#(TARGET_WIDTH, 2)], info.target, 2'b00};
                br_history <- br_history ^ new_pc;
                for(Integer i = 0 ; i < valueOf(FETCH_WIDTH) ; i = i + 1) begin
                    mask[i] = info.offset <= fromInteger(i);
                end
            end else begin
                // 不需要跳转
                new_pc = {pc[PC_WIDTH : TAdd#(TLog#(FETCH_WIDTH), 2)] + 1, {TLog#(FETCH_WIDTH){1'b0}}, 2'b00};
                mask = '1;
            end
            // 根据当前 PC 修正 mask
            for(Integer i = 0 ; i < valueOf(FETCH_WIDTH) ; i = i + 1) begin
                mask[i] = mask[i] && (unpack(pc[TAdd#(1, TLog#(FETCH_WIDTH)):2]) <= fromInteger(i));
            end
            return BranchPredict {
                pc: pc;
                br_history : br_history;
                mask: mask;
            };
        endmethod
    endmodule

endpackage : WiredL1BTB
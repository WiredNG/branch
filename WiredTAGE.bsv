package WiredTAGE;

`define _BRPACKAGES
`include "WiredBranchHeader.bsv"

    import WiredParam::*;
    import WiredTypes::*;
    import WiredBranchDefines::*;
    // Wired TAGE 预测器

    typedef struct {
        Bit#(PC_WIDTH) pc;         // 发生跳转的 PC
        Bit#(PC_WIDTH) br_history; // 最新的 br_history
        Bit#(PC_WIDTH) target;
        Bit#(FETCH_WIDTH) mask;
        Bit#(FID_WIDTH) id;
    } BranchPredict
    #(`_BRPREDPARMSDEF)
    deriving (Bits, Eq, FShow, Bounded);

    typedef struct {
        Bit#(PC_WIDTH) pc; 
        Bit#(PC_WIDTH) br_history;
        Bit#(PC_WIDTH) target;
    } TAGEUpdate
    #(`_BRPREDPARMSDEF)
    deriving (Bits, Eq, FShow, Bounded);

    interface L1BTB#(numeric type PC_WIDTH, numeric type TAG_WIDTH, numeric type TARGET_WIDTH, numeric type FETCH_WIDTH, numeric type ENTRY_IDX_WIDTH);
        method L1BTBPredict#(PC_WIDTH, TAG_WIDTH, TARGET_WIDTH, FETCH_WIDTH) get_predict; // 返回当周期预测结果
        method Action upd(L1BTBUpdate#(PC_WIDTH, TAG_WIDTH, TARGET_WIDTH, FETCH_WIDTH) upd_info);
        method Action step(); //  预测下一个块
    endinterface

endpackage : WiredTAGE
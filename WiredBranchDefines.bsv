package WiredBranchDefines;

`define _BRPACKAGES
`include "WiredBranchHeader.bsv"

`define _BRPREDPARMSDEF numeric type TARGET_WIDTH, type INFO_T
`define _BRPREDPARMS TARGET_WIDTH, INFO_T

`define _FETCHREQPARMSDEF numeric type PC_WIDTH, numeric type FETCH_WIDTH, numeric type FID_WIDTH, numeric type FQID_WIDTH

    // 取指包定义
    typedef struct {
        Bit#(FID_WIDTH)     id;
        Bit#(PC_WIDTH)      pc;
        Bit#(FETCH_WIDTH) mask;
    } FetchRequest
    #(`_FETCHREQPARMSDEF)
    deriving (Bits, Eq, FShow, Bounded);

    typedef struct {
        Bool                 jump; // 是否发生跳转
        Bit#(TARGET_WIDTH) target; // 用于生成跳转目标
        INFO_T               info; // 用于更新分支预测器的其它额外信息
    } BranchPredict
    #(`_BRPREDPARMSDEF)
    deriving (Bits, Eq, FShow, Bounded);

    // 下一拍使用的 FetchRequest 即为 FetchUpdate 的结构

    typedef struct {
        FINFO_T   finfo; // 原预测 BranchPredict 所对应的取指信息
        BPINFO_T bpinfo; // 原预测 BranchPredict 所包含的用于更新的信息
    } BranchPredictUpdate
    #(`_BRPREDPARMSDEF)
    deriving (Bits, Eq, FShow, Bounded);
    /*
        FINFO For BTB:
        原始 id，原始 pc，原始 mask，是否发生跳转
        BPINFO For BTB:
        原始 brHistory（此 brHistory 可以视为正确 brHistory）
     */
    /*
        FINFO For TAGE:
        原始 id，原始 pc，原始 mask，是否发生跳转
        BPINFO For BTB:
        原始 brHistory（此 brHistory 可以视为正确 brHistory）、SRAM 中读出的多组值
     */

    // 后端或者解码更新时，后端传来新的更新后的 FetchRequest 及 BranchPreductUpdate。
    // 其中 finfo 为 id 指针
    // bpinfo 为跳转类型说明（异常、条件跳转、无条件跳转、函数调用、函数返回）
    // 对于非异常跳转，需要生成 BranchPredictUpdate 给 TAGE 预测器进行更新。
    // 其中对于无条件跳转、函数调用，函数返回还需要给 L1-BTB 预测器进行更新。
    // 实际传给 TAGE 预测器与 BTB 预测器的 BranchPredictUpdate 通过读取 F&BP INFO RF 获得。


    // TAGE 预测器更新时，finfo 原样传给 BTB，bpinfo 为原 brHistory。


endpackage : WiredBranchDefines
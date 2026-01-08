//
// Created by tanawin on 29/12/25.
//

#include "simStateRide.h"



namespace kathryn::o3{

    pipStat SimStateRide::generatePipState(CData invalidVal,
                                           CData stallVal){

        bool isInvalid = invalidVal != 0;
        bool isStall   = stallVal   != 0;

        return isInvalid ? PS_IDLE :
               isStall   ? PS_STALL:
                           PS_RUNNING;
    }

    void SimStateRide::recruitRsvAlu(int idx){

        ///// alu 1
        Vpipeline_pipeline* pl = core.pipeline;
        Vpipeline_rs_alu* vrsv1  = (idx == 1) ? pl->reserv_alu1: pl->reserv_alu2;
        RSV_BASE_ENTRY*   desRsv = (idx == 1) ? rsvAlu1: rsvAlu2;
        recruitRsvBaseEntry(desRsv[0], vrsv1->ent0, vrsv1->busyvec, vrsv1->sortbit, vrsv1->specbitvec, 0);
        recruitRsvBaseEntry(desRsv[1], vrsv1->ent1, vrsv1->busyvec, vrsv1->sortbit, vrsv1->specbitvec, 1);
        recruitRsvBaseEntry(desRsv[2], vrsv1->ent2, vrsv1->busyvec, vrsv1->sortbit, vrsv1->specbitvec, 2);
        recruitRsvBaseEntry(desRsv[3], vrsv1->ent3, vrsv1->busyvec, vrsv1->sortbit, vrsv1->specbitvec, 3);
        recruitRsvBaseEntry(desRsv[4], vrsv1->ent4, vrsv1->busyvec, vrsv1->sortbit, vrsv1->specbitvec, 4);
        recruitRsvBaseEntry(desRsv[5], vrsv1->ent5, vrsv1->busyvec, vrsv1->sortbit, vrsv1->specbitvec, 5);
        recruitRsvBaseEntry(desRsv[6], vrsv1->ent6, vrsv1->busyvec, vrsv1->sortbit, vrsv1->specbitvec, 6);
        recruitRsvBaseEntry(desRsv[7], vrsv1->ent7, vrsv1->busyvec, vrsv1->sortbit, vrsv1->specbitvec, 7);
        
    }

    void SimStateRide::recruitRsvMul(){
        Vpipeline_pipeline* pl = core.pipeline;
        Vpipeline_rs_mul* vrsv1 = pl->reserv_mul;
        recruitRsvMulEntry(rsvMul[0], vrsv1->ent0, vrsv1->busyvec, vrsv1->specbitvec, 0);
        recruitRsvMulEntry(rsvMul[1], vrsv1->ent1, vrsv1->busyvec, vrsv1->specbitvec, 1);
    }

    void SimStateRide::recruitRsvBranch(){
        Vpipeline_pipeline* pl = core.pipeline;
        Vpipeline_rs_branch* vrsv1 = pl->reserv_branch;
        recruitRsvBranchEntry(rsvBranch[0], vrsv1->ent0, vrsv1->busyvec, vrsv1->specbitvec, 0);
        recruitRsvBranchEntry(rsvBranch[1], vrsv1->ent1, vrsv1->busyvec, vrsv1->specbitvec, 1);
        recruitRsvBranchEntry(rsvBranch[2], vrsv1->ent2, vrsv1->busyvec, vrsv1->specbitvec, 2);
        recruitRsvBranchEntry(rsvBranch[3], vrsv1->ent3, vrsv1->busyvec, vrsv1->specbitvec, 3);

    }

    void SimStateRide::recruitRsvLdSt(){
        Vpipeline_pipeline* pl = core.pipeline;
        Vpipeline_rs_ldst* vrsv1 = pl->reserv_ldst;
        recruitRsvLdstEntry(rsvLdSt[0], vrsv1->ent0, vrsv1->busyvec, vrsv1->specbitvec, 0);
        recruitRsvLdstEntry(rsvLdSt[1], vrsv1->ent1, vrsv1->busyvec, vrsv1->specbitvec, 1);
        recruitRsvLdstEntry(rsvLdSt[2], vrsv1->ent2, vrsv1->busyvec, vrsv1->specbitvec, 2);
        recruitRsvLdstEntry(rsvLdSt[3], vrsv1->ent3, vrsv1->busyvec, vrsv1->specbitvec, 3);

    }


    void SimStateRide::recruitRsvBaseEntry(RSV_BASE_ENTRY& des,
                                           Vpipeline_rs_alu_ent* entry,
                                           CData busyVec,
                                           CData sortbit,
                                           CData specBit,
                                           int idx){

        des.busy     =     (busyVec >> idx) & 1;
        des.sortbit  =     (sortbit >> idx) & 1;
        des.pc       =     entry->pc;
        des.imm      =     entry->imm;
        des.rrftag   =     entry->rrftag;
        des.dstval   =     entry->dstval;
        des.alu_op   =     entry->alu_op;
        des.specBit  =     (specBit >> idx) & 1;
        des.spectag  =     entry->spectag;
        des.src1     =     entry->src1;
        des.src1_sel =     entry->src_a;
        des.valid1   =     entry->valid1;
        des.src2     =     entry->src2;
        des.src2_sel =     entry->src_b;
        des.valid2   =     entry->valid2;

    }

    


    void SimStateRide::recruitRsvMulEntry(RSV_MUL_ENTRY& des,
                                          Vpipeline_rs_mul_ent* entry,
                                          CData busyVec,
                                          CData specBit,
                                          int idx){
        des.busy        = (busyVec >> idx) & 1;
        //des.sortbit     = (sortbit >> idx) & 1;
        //des.pc        = entry->pc;
        //des.imm       = entry->imm;
        des.rrftag      = entry->rrftag;
        des.dstval      = entry->dstval;
        //des.alu_op    = entry->alu_op;
        des.specBit     = (specBit >> idx) & 1;
        des.spectag     = entry->spectag;
        des.src1        = entry->src1;
        //des.src1_sel  = entry->src_a;
        des.valid1      = entry->valid1;
        des.src2        = entry->src2;
        //des.src2_sel  = entry->src_b;
        des.valid2      = entry->valid2;
        des.src1_signed = entry->src1_signed;
        des.src2_signed = entry->src2_signed;
        des.sel_lohi    = entry->sel_lohi;
    }

    void SimStateRide::recruitRsvBranchEntry(RSV_BRANCH_ENTRY& des,
                                             Vpipeline_rs_branch_ent* entry,
                                             CData busyVec,
                                             CData specBit,
                                             int idx){
        des.busy       =     (busyVec >> idx) & 1;
        //des.sortbit  =     (sortbit >> idx) & 1;
        des.pc         =     entry->pc;
        //des.imm      =     entry->imm;
        des.rrftag     =     entry->rrftag;
        des.dstval     =     entry->dstval;
        des.alu_op     =     entry->alu_op;
        des.specBit    =     (specBit >> idx) & 1;
        des.spectag    =     entry->spectag;
        des.src1       =     entry->src1;
        //des.src1_sel =     entry->src_a;
        des.valid1     =     entry->valid1;
        des.src2       =     entry->src2;
        //des.src2_sel =     entry->src_b;
        des.valid2     =     entry->valid2;
        des.imm_br     =     entry->imm;
        des.praddr     =     entry->praddr;
        des.opcode     =     entry->opcode;

    }

    void SimStateRide::recruitRsvLdstEntry(RSV_BASE_ENTRY& des,
                                           Vpipeline_rs_ldst_ent* entry,
                                           CData busyVec,
                                           CData specBit,
                                           int   idx){

        des.busy     =     (busyVec >> idx) & 1;
        //des.sortbit  =     (sortbit >> idx) & 1;
        des.pc       =     entry->pc;
        des.imm      =     entry->imm;
        des.rrftag   =     entry->rrftag;
        des.dstval   =     entry->dstval;
        //des.alu_op   =     entry->alu_op;
        des.specBit  =     (specBit >> idx) & 1;
        des.spectag  =     entry->spectag;
        des.src1     =     entry->src1;
        //des.src1_sel =     entry->src_a;
        des.valid1   =     entry->valid1;
        des.src2     =     entry->src2;
        //des.src2_sel =     entry->src_b;
        des.valid2   =     entry->valid2;

    }




    void SimStateRide::recruitValue(){

        Vpipeline_pipeline* pl = core.pipeline;
        ///// BC value
        bcState.misPred  = pl->prmiss;
        bcState.succPred = pl->prsuccess;

        bcPrev.misPred  = isLastCycleMisPred;
        bcPrev.succPred = isLastCycleSucc;

        /////////////////////
        ///// Fetch /////////
        /////////////////////
        fetch.st = generatePipState(0, pl->stall_IF | pl->kill_IF);
        fetch.pc = pl->pc;

        /////////////////////
        ///// Decode ////////
        /////////////////////
        decode.st        = generatePipState(pl->inv1_if, pl->stall_ID | pl->kill_ID | pl->stall_DP);
        decode.inst1     = ull(pl->inst1_if);
        decode.invalid2  = ull(pl->inv2_if);
        decode.inst2     = ull(pl->inst2_if);
        decode.pc        = ull(pl->pc_if);
        decode.npc       = ull(pl->npc_if);
        decode.isGenable = ull(pl->attachable);

        /////////////////////
        ///// Dispatch //////
        /////////////////////
        dispatch.st = generatePipState(pl->inv1_id, pl->stall_DP | pl->kill_DP);
        dispatch.pc = ull(pl->pc_id);
        dispatch.desEqSrc1 = ull(pl->rs1_2_eq_dst1_id);
        dispatch.desEqSrc2 = ull(pl->rs2_2_eq_dst1_id);
        ///////// dp 1   and dp2
        dispatch.dp1.invalid   = ull(pl->inv1_id        ); dispatch.dp2.invalid   = ull(pl->inv2_id        );
        dispatch.dp1.imm_type  = ull(pl->imm_type_1_id  ); dispatch.dp2.imm_type  = ull(pl->imm_type_2_id  );
        dispatch.dp1.aluOp     = ull(pl->alu_op_1_id    ); dispatch.dp2.aluOp     = ull(pl->alu_op_2_id    );
        dispatch.dp1.rsEnt     = ull(pl->rs_ent_1_id    ); dispatch.dp2.rsEnt     = ull(pl->rs_ent_2_id    );
        dispatch.dp1.isBranch  = ull(pl->isbranch1_id   ); dispatch.dp2.isBranch  = ull(pl->isbranch2_id   );
        dispatch.dp1.pred_addr = ull(pl->praddr1_id     ); dispatch.dp2.pred_addr = ull(pl->praddr2_id     );
        dispatch.dp1.spec      = ull(pl->spec1_id       ); dispatch.dp2.spec      = ull(pl->spec2_id       );
        dispatch.dp1.specTag   = ull(pl->sptag1_id      ); dispatch.dp2.specTag   = ull(pl->sptag2_id      );
        dispatch.dp1.rdIdx     = ull(pl->rd_1_id        ); dispatch.dp2.rdIdx     = ull(pl->rd_2_id        );
        dispatch.dp1.rdUse     = ull(pl->wr_reg_1_id    ); dispatch.dp2.rdUse     = ull(pl->wr_reg_2_id    );
        dispatch.dp1.rsIdx_1   = ull(pl->rs1_1_id       ); dispatch.dp2.rsIdx_1   = ull(pl->rs1_2_id       );
        dispatch.dp1.rsSel_1   = ull(pl->src_a_sel_1_id ); dispatch.dp2.rsSel_1   = ull(pl->src_a_sel_2_id );
        dispatch.dp1.rsUse_1   = ull(pl->uses_rs1_1_id  ); dispatch.dp2.rsUse_1   = ull(pl->uses_rs1_2_id  );
        dispatch.dp1.rsIdx_2   = ull(pl->rs2_1_id       ); dispatch.dp2.rsIdx_2   = ull(pl->rs2_2_id       );
        dispatch.dp1.rsSel_2   = ull(pl->src_b_sel_1_id ); dispatch.dp2.rsSel_2   = ull(pl->src_b_sel_2_id );
        dispatch.dp1.rsUse_2   = ull(pl->uses_rs2_1_id  ); dispatch.dp2.rsUse_2   = ull(pl->uses_rs2_2_id  );

        dispatch.isAluRsvAllocatable    = pl->allocatable_alu;
        dispatch.isBranchRsvAllocatable = pl->allocatable_branch;
        dispatch.isRenamable            = (pl->alloc_rrf != 0);

        /////////////////////
        ///// RSV      //////
        /////////////////////
        recruitRsvAlu(1);
        recruitRsvAlu(2);
        recruitRsvMul();
        recruitRsvBranch();
        recruitRsvLdSt();

        //////////////////////
        /// ISSUE ////////////
        //////////////////////
        st_issue_alu1    = generatePipState(0, pl->issue_alu1   == 0);
        st_issue_alu2    = generatePipState(0, pl->issue_alu2   == 0);
        st_issue_mul     = generatePipState(0, pl->issue_mul    == 0);
        st_issue_branch  = generatePipState(0, pl->issue_branch == 0);
        st_issue_ldst    = generatePipState(0, pl->issue_ldst   == 0);
        idx_issue_alu1   = ull(1 << pl->issueent_alu1);
        idx_issue_alu2   = ull(1 << pl->issueent_alu2);
        idx_issue_mul    = ull(1 << pl->issueent_mul);
        idx_issue_branch = ull(pl->issueent_branch);
        idx_issue_ldst   = ull(pl->issueent_ldst);

        //////////////////////
        /// EXEC  ////////////
        //////////////////////

        /////// alu1
        exec_alu1.st = generatePipState(pl->byakko->busy == 0, 0);
        RSV_BASE_ENTRY& aluEt1 = exec_alu1.entry;
        aluEt1.busy     =     0;   /// TODO delete from Kathryn
        aluEt1.sortbit  =     0;   /// TODO delete from Kathryn
        aluEt1.pc       =     ull(pl->buf_pc_alu1);
        aluEt1.imm      =     ull(pl->buf_imm_alu1);
        aluEt1.rrftag   =     ull(pl->buf_rrftag_alu1);
        aluEt1.dstval   =     ull(pl->buf_dstval_alu1);
        aluEt1.alu_op   =     ull(pl->buf_alu_op_alu1);
        aluEt1.specBit  =     ull(pl->buf_specbit_alu1);
        aluEt1.spectag  =     ull(pl->buf_spectag_alu1);
        aluEt1.src1     =     ull(pl->buf_ex_src1_alu1);
        aluEt1.src1_sel =     ull(pl->buf_src_a_alu1);
        aluEt1.valid1   =     0;   /// TODO delete from Kathryn
        aluEt1.src2     =     ull(pl->buf_ex_src2_alu1);
        aluEt1.src2_sel =     ull(pl->buf_src_b_alu1);
        aluEt1.valid2   =     0;   /// TODO delete from Kathryn
        /////// alu2
        exec_alu2.st = generatePipState(pl->suzaku->busy == 0, 0);
        RSV_BASE_ENTRY& aluEt2 = exec_alu2.entry;
        aluEt2.busy     =     0;   /// TODO delete from Kathryn
        aluEt2.sortbit  =     0;   /// TODO delete from Kathryn
        aluEt2.pc       =     ull(pl->buf_pc_alu2);
        aluEt2.imm      =     ull(pl->buf_imm_alu2);
        aluEt2.rrftag   =     ull(pl->buf_rrftag_alu2);
        aluEt2.dstval   =     ull(pl->buf_dstval_alu2);
        aluEt2.alu_op   =     ull(pl->buf_alu_op_alu2);
        aluEt2.specBit  =     ull(pl->buf_specbit_alu2);
        aluEt2.spectag  =     ull(pl->buf_spectag_alu2);
        aluEt2.src1     =     ull(pl->buf_ex_src1_alu2);
        aluEt2.src1_sel =     ull(pl->buf_src_a_alu2);
        aluEt2.valid1   =     0;   /// TODO delete from Kathryn
        aluEt2.src2     =     ull(pl->buf_ex_src2_alu2);
        aluEt2.src2_sel =     ull(pl->buf_src_b_alu2);
        aluEt2.valid2   =     0;   /// TODO delete from Kathryn
        //////// mul
        exec_mul.st = generatePipState(pl->genbu->busy == 0, 0);
        RSV_MUL_ENTRY& mulEt1 = exec_mul.entry;
        mulEt1.busy     = 0                   ;
        mulEt1.sortbit  = 0                   ;
        mulEt1.pc       = pl->buf_pc_mul      ;
        mulEt1.imm      = 0                   ;
        mulEt1.rrftag   = pl->buf_rrftag_mul  ;
        mulEt1.dstval   = pl-> buf_dstval_mul ;
        mulEt1.alu_op   = 0                   ;
        mulEt1.specBit  = pl->buf_specbit_mul ;
        mulEt1.spectag  = pl->buf_spectag_mul ;
        mulEt1.src1     = pl->buf_ex_src1_mul ;
        mulEt1.src1_sel = 0                   ;
        mulEt1.valid1   = 0                   ;
        mulEt1.src2     = pl->buf_ex_src2_mul ;
        mulEt1.src2_sel = 0                   ;
        mulEt1.valid2   = 0                   ;

        mulEt1.src1_signed = pl->buf_src1_signed_mul;
        mulEt1.src2_signed = pl->buf_src2_signed_mul;
        mulEt1.sel_lohi    = pl->buf_sel_lohi_mul   ;



        //////// branch
        exec_branch.st = generatePipState(pl->kirin->busy == 0, 0);
        RSV_BRANCH_ENTRY& brEt1 =  exec_branch.entry;
        brEt1.busy     = 0;
        brEt1.sortbit  = 0;
        brEt1.pc       = ull(pl->buf_pc_branch);
        brEt1.imm      = 0;
        brEt1.rrftag   = ull(pl->buf_rrftag_branch);
        brEt1.dstval   = ull(pl->buf_dstval_branch);
        brEt1.alu_op   = ull(pl->buf_alu_op_branch);
        brEt1.specBit  = ull(pl->buf_specbit_branch);
        brEt1.spectag  = ull(pl->buf_spectag_branch);
        brEt1.src1     = ull(pl->buf_ex_src1_branch);
        brEt1.src1_sel = 0;
        brEt1.valid1   = 0;
        brEt1.src2     = ull(pl->buf_ex_src2_branch);
        brEt1.src2_sel = 0;
        brEt1.valid2   = 0;

        brEt1.imm_br   = ull(pl->buf_imm_branch);
        brEt1.praddr   = ull(pl->buf_praddr_branch);
        brEt1.opcode   = ull(pl->buf_opcode_branch);

        //////// ldst
        Vpipeline_exunit_ldst* vldstExt = pl->seiryu;
        exec_ldst.st1 = generatePipState(pl->seiryu->busy == 0, pl->seiryu->killspec1);
        exec_ldst.st2 = generatePipState(pl->seiryu->insnvalid_latch == 0, 0);
        RSV_BASE_ENTRY& ldstEt = exec_ldst.entry;
        ldstEt.busy     =     0;/// TODO delete from Kathryn
        ldstEt.sortbit  =     0;/// TODO delete from Kathryn
        ldstEt.pc       =     ull(pl->buf_pc_ldst);
        ldstEt.imm      =     ull(pl->buf_imm_ldst);
        ldstEt.rrftag   =     ull(pl->buf_rrftag_ldst);
        ldstEt.dstval   =     ull(pl->buf_dstval_ldst);
        ldstEt.alu_op   =     0;/// TODO delete from Kathryn
        ldstEt.specBit  =     ull(pl->buf_specbit_ldst);
        ldstEt.spectag  =     ull(pl->buf_spectag_ldst);
        ldstEt.src1     =     ull(pl->buf_ex_src1_ldst);
        ldstEt.src1_sel =     0;/// TODO delete from Kathryn
        ldstEt.valid1   =     0;/// TODO delete from Kathryn
        ldstEt.src2     =     ull(pl->buf_ex_src2_ldst);
        ldstEt.src2_sel =     0;/// TODO delete from Kathryn
        ldstEt.valid2   =     0;/// TODO delete from Kathryn
        exec_ldst.effAddr = ull(vldstExt->effaddr);
        //////// ldst2
        exec_ldst.rrftag    = ull(vldstExt->rrftag_latch);
        exec_ldst.rdUse     = ull(vldstExt->dstval_latch);
        exec_ldst.spec      = ull(vldstExt->specbit_latch);
        exec_ldst.specTag   = ull(vldstExt->spectag_latch);
        exec_ldst.stBufData = ull(vldstExt->lddatasb_latch);
        exec_ldst.stBufHit  = ull(vldstExt->hitsb_latch);
        exec_ldst.loadData  = ull(vldstExt->lddatamem);


        //////////////////////
        /// COMMIT STATE /////
        //////////////////////
        rob.comPtr = ull(pl->rob->comptr);
        rob.com1Status = (pl->rob->commit1 != 0) && (!pl->prmiss);
        rob.com2Status = (pl->rob->commit2 != 0) && (!pl->prmiss);

        for(int idx = 0; idx < RRF_NUM; idx++){
            COMMIT_ENTRY& cmEntry = rob.comEntries[idx];
            cmEntry.wbFin    = ull( (pl->rob->finish   >> idx) & 1 );
            cmEntry.storeBit = ull( (pl->rob->storebit >> idx) & 1 );
            cmEntry.rdUse    = ull( (pl->rob->dstvalid >> idx) & 1 );
            cmEntry.rdIdx    = ull(pl->rob->dst[idx]);
        }

        rob.isPrevCycleDp1 = isLastCycleDisp1;
        rob.isPrevCycleDp2 = isLastCycleDisp2;
        rob.dpPointer      = ull(lastDispatchPtr);

        //////////////////////
        /// STORE BUF    /////
        //////////////////////

        stbuf.finPtr = ull(pl->sb->finptr);
        stbuf.comPtr = ull(pl->sb->comptr);
        stbuf.retPtr = ull(pl->sb->retptr);

        for(int i = 0; i < STBUF_ENT_NUM; i++){
            STORE_BUF_ENTRY& sbEntry = stbuf.entries[i];
            sbEntry.busy       = ull((pl->sb->valid     >> i) & 1);
            sbEntry.complete   = ull((pl->sb->completed >> i) & 1);
            sbEntry.spec       = ull((pl->sb->specbit   >> i) & 1);
            sbEntry.specTag    = ull(pl->sb->spectag[i]);
            sbEntry.mem_addr   = ull(pl->sb->addr[i]);
            sbEntry.mem_data   = ull(pl->sb->data[i]);
        }

        stbuf.nb1          = ull(pl->sb->nb1);
        stbuf.ne1          = ull(pl->sb->ne1);
        stbuf.nb0          = ull(pl->sb->nb0);
        stbuf.fullNext     = pl->sb->notfull_next == 0;
        stbuf.emptyNext    = pl->sb->notempty_next == 0;

        //////////////////////
        /// MPFT         /////
        //////////////////////

        for(int row = 0; row < SPECTAG_LEN; row++){
            mpft.valids[row] = ull((pl->mpft->mpft_valid >> row) & 1);

            mpft.fixTable[row][0] = ull((pl->mpft->value0 >> row) & 1);
            mpft.fixTable[row][1] = ull((pl->mpft->value1 >> row) & 1);
            mpft.fixTable[row][2] = ull((pl->mpft->value2 >> row) & 1);
            mpft.fixTable[row][3] = ull((pl->mpft->value3 >> row) & 1);
            mpft.fixTable[row][4] = ull((pl->mpft->value4 >> row) & 1);
        }

        //////////////////////
        /// TAG_GEN      /////
        //////////////////////

        tagGen.brdepth = ull(pl->taggen->brdepth);
        tagGen.tagReg  = ull(pl->taggen->tagreg);


        //////////////////////
        /// ARF          /////
        //////////////////////

        Vpipeline_renaming_table* rtm = pl->aregfile->rt;


        for(int tableIdx = 0; tableIdx < (SPECTAG_LEN+1); tableIdx++){
            for(int archIdx = 0; archIdx < REG_NUM; archIdx++){
                arf.busy[tableIdx][archIdx] = (rtm->busy[tableIdx][archIdx] != 0);
                arf.rename[tableIdx][archIdx] = ull(rtm->rem[tableIdx][archIdx]);
            }
        }


        //////////////
        //// RRF /////
        //////////////

        for (int phyIdx = 0; phyIdx < RRF_NUM; phyIdx++){
            rrf.busy[phyIdx] = ull((pl->rregfile->valid >> phyIdx) & 1);
            rrf.data[phyIdx] = ull(pl->rregfile->datarr[phyIdx]);
        }
        rrf.freenum      = pl->rrf_fl->freenum;
        rrf.reqPtr       = pl->rrf_fl->rrfptr;
        rrf.nextRrfCycle = pl->rrf_fl->nextrrfcyc;

    }

    void SimStateRide::recruitNextCycle(){
        /////////// temporary data
        Vpipeline_pipeline* pl = core.pipeline;
        isLastCycleMisPred = (pl->prmiss    != 0);
        isLastCycleSucc    = (pl->prsuccess != 0);
        ///////// state recorder for next cycle
        isLastCycleDisp1   = (dispatch.st == PS_RUNNING);
        isLastCycleDisp2   = (dispatch.st == PS_RUNNING) && ( pl->inv2_id == 0);
        lastDispatchPtr    = ull(pl->rrf_fl->rrfptr);
    }



}

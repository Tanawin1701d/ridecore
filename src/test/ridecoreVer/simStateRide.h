//
// Created by tanawin on 29/12/25.
//

#ifndef EXTSIM_RIDECORE_SRC_TEST_RIDECOREVER_SIMSTATERIDE_H
#define EXTSIM_RIDECORE_SRC_TEST_RIDECOREVER_SIMSTATERIDE_H

#include "example/o3/simCompare/simState.h"
#include "Vpipeline.h"
///// reservation station
#include "Vpipeline_pipeline.h"
#include "Vpipeline_rs_alu.h"
#include "Vpipeline_rs_branch.h"
#include "Vpipeline_rs_mul.h"
#include "Vpipeline_rs_ldst.h"

///// reservation station entry
#include "Vpipeline_rs_alu_ent.h"
#include "Vpipeline_rs_branch_ent.h"
#include "Vpipeline_rs_ldst_ent.h"
#include "Vpipeline_rs_mul_ent.h"

///// execunit
#include "Vpipeline_exunit_alu.h"
#include "Vpipeline_exunit_ldst.h"
#include "Vpipeline_reorderbuf.h"
#include "Vpipeline_exunit_branch.h"
#include "Vpipeline_rrf_freelistmanager.h"
#include "Vpipeline_exunit_mul.h"

///// storeBuf
#include "Vpipeline_storebuf.h"

///// mpft
#include "Vpipeline_miss_prediction_fix_table.h"
///// arf
#include "Vpipeline_arf.h"
#include "Vpipeline_renaming_table.h"
///// rrf
#include "Vpipeline_rrf.h"
///// taggen
#include "Vpipeline_tag_generator.h"



namespace kathryn::o3{

    struct SimStateRide: SimState{

        Vpipeline& core;

        bool isLastCycleMisPred = false;
        bool isLastCycleSucc    = false;

        bool isLastCycleDisp1 = false;
        bool isLastCycleDisp2 = false;
        ull  lastDispatchPtr  = 0;

        SimStateRide(Vpipeline& core): SimState(), core(core){}

        ///// please check the killed usecase
        pipStat generatePipState(CData invalidVal, CData stallVal);

        void recruitRsvAlu(int idx = 1); /// start from 1
        void recruitRsvMul();
        void recruitRsvBranch();
        void recruitRsvLdSt();

        void recruitRsvBaseEntry(RSV_BASE_ENTRY& des,
                                 Vpipeline_rs_alu_ent* entry,
                                 CData busyVec,
                                 CData sortbit,
                                 CData specBit,
                                 int idx);

        void recruitRsvMulEntry(RSV_MUL_ENTRY& des,
                                Vpipeline_rs_mul_ent* entry,
                                CData busyVec,
                                CData specBit,
                                int idx);
        void recruitRsvBranchEntry(RSV_BRANCH_ENTRY& des,
                                   Vpipeline_rs_branch_ent* entry,
                                   CData busyVec,
                                   CData specBit,
                                   int idx
        );
        void recruitRsvLdstEntry(RSV_BASE_ENTRY& des,
                                 Vpipeline_rs_ldst_ent* entry,
                                 CData busyVec,
                                 CData specBit,
                                 int   idx
        );

        void recruitValue()     override;
        void recruitNextCycle() override;


    };

}

#endif //EXTSIM_RIDECORE_SRC_TEST_RIDECOREVER_SIMSTATERIDE_H
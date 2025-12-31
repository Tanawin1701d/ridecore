//
// Created by tanawin on 31/12/25.
//

#ifndef EXT_SIM_RIDECORE_SRC_TEST_RIDECOREVER_SIMCTRLRIDE_H
#define EXT_SIM_RIDECORE_SRC_TEST_RIDECOREVER_SIMCTRLRIDE_H

#include "simStateRide.h"
#include "example/o3/simCompare/simCtrlBase.h"
#include "Vpipeline.h"
#include "Vpipeline_arf.h"
#include "Vpipeline_pipeline.h"
#include "Vpipeline_ram_sync_nolatch_4r2w__B5.h"

namespace kathryn::o3{


    class SimCtrlRide : public O3SimCtrlBase{

    public:
        Vpipeline& _core;

        SimCtrlRide(CYCLE                    limitCycle,
                    const std::string&       prefix,
                    std::vector<std::string> testTypes,
                    SimProxyBuildMode        buildMode,
                    SlotWriterBase&          slotWriter,
                    SimState&                state,
                    Vpipeline& core);

        /**
         *    |---------|
         *    |         |
         *    |         |
         *  --|         |---------
         ***/

        void  iterateCycle();
        void  iterateAtEndCycle();

        void  simStart();

        void  readMem2Fetch         () override;
        void  readWriteDataMemGetCmd() override;
        void  readWriteDataMemDoCmd () override;
        void  resetRegister         () override;
        void  testRegister          () override;
        void  postCycleAction       () override;

    };

    class RIDE_MNG{
    public:
        void start(PARAM& params){

            std::vector<std::string> testTypes = {
                "Imm"       , "Reg"        , "Branch", "BranchSuc",
                "BranchLong", "BranchMidRd", "OverRrf",
                "LoadImm"   , "BranchSc"   , "memOp"
            };
            SlotWriter slotWriter({"MPFT"    , "ARF","RRF"  , "FETCH"  ,"DECODE",
                "DISPATCH", "RSV","ISSUE", "EXECUTE","COMMIT",
                "STBUF"
                   },
                {20       , 40   , 25    , 25       , 30,
                 30       , 35   , 25    , 35       , 25,
                 25},
                std::move(params["prefix"] + testTypes[0] + "/oslot.sl"));

            ///mMod(o3Top, TopSim, false);
            Vpipeline* _core = new Vpipeline();

            SimStateRide simState(*_core);

            startModelKathryn();
            SimCtrlRide simulator(2500,
                                  params["prefix"],
                                  testTypes,
                                  getSPBM(params),
                                  slotWriter,
                                  simState,
                                  *_core
            );
            simulator.simStart();
            resetKathryn();
            std::cout << TC_GREEN << "--------------------------------" << std::endl;
            delete _core;
        }
    };

}

#endif //EXT_SIM_RIDECORE_SRC_TEST_RIDECOREVER_SIMCTRLRIDE_H
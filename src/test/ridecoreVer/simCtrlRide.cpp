//
// Created by tanawin on 31/12/25.
//

#include "simCtrlRide.h"

#include <chrono>


namespace kathryn::o3{

    SimCtrlRide::SimCtrlRide(CYCLE                    limitCycle,
                             const std::string&       prefix,
                             std::vector<std::string> testTypes,
                             SimProxyBuildMode        buildMode,
                             SlotWriterBase&          slotWriter,
                             SimState&                state,
                             Vpipeline&               core,
                             ResultWriter*            resultWriter):
    O3SimCtrlBase(limitCycle,
                  prefix,
                  std::move(testTypes),
                  buildMode,
                  slotWriter,
                  state,
                  resultWriter
    ),
    _core(core){}

    void SimCtrlRide::iterateCycle(){
        auto st = std::chrono::steady_clock::now();
        _core.clk = 1;
        _core.eval();
        _core.clk = 0;
        _core.eval();
        _rtlSimSec +=
            std::chrono::duration<double>(std::chrono::steady_clock::now() - st).count();
    }

    void SimCtrlRide::iterateAtEndCycle(){
        auto st = std::chrono::steady_clock::now();
        _core.clk = 0;
        _core.eval();
        _rtlSimSec +=
            std::chrono::duration<double>(std::chrono::steady_clock::now() - st).count();
    }


    void SimCtrlRide::doWorkloadInit(int curTestCaseIdx, bool reqRegTest){
        //////////////  read assembly and assertVal
        _slotWriter. renew(_prefixFolder + _testTypes[curTestCaseIdx]+ "/oslot_ride.sl");
        doWorkloadExit();
        if (_resultWriter != nullptr){

            _resultWriter->renew(_prefixFolder + _testTypes[curTestCaseIdx]+ "/verilator_ride_result");
        }
        iterateCycle();
        //////// set reset wire to 1
        _core.reset = 1;
        //////// cycle before cycle cycle is running
        iterateCycle();
        _core.reset = 0;
        resetRegister();
        readAssembly (_prefixFolder + _testTypes[curTestCaseIdx] + "/asm.out");
        if (reqRegTest){
            readAssertVal(_prefixFolder + _testTypes[curTestCaseIdx] + "/ast.out");
        }

        /////resetDmem();
    }

    void SimCtrlRide::doWorkloadCycle(bool recordThisCycle){
        ///////// give the data to
        readMem2Fetch();
        readWriteDataMemDoCmd(); ///// do the dmem command command

        iterateAtEndCycle();
        readWriteDataMemGetCmd();
        ///////// record the system
        _state.recruitValue();
        if (recordThisCycle){
            _state.printSlotWindow(_slotWriter);
            writeMemOp();
        }
        _state.recruitNextCycle();
        postCycleAction();
        _slotWriter.concludeEachCycle();
        //////////////////////////////////
        iterateCycle();
    }


    void SimCtrlRide::simStart(){

        for (; _curTestCaseIdx < _testTypes.size(); _curTestCaseIdx++){
            std::cout << TC_BLUE << "[O3 RISC-V] test type is " << _testTypes[_curTestCaseIdx] << TC_DEF << std::endl;
            doWorkloadInit(_curTestCaseIdx, true);

            //////// iterate for 100 cycle
            for (int i = 0; i <= 150; i++){
                doWorkloadCycle(true);
            }
            /////////////////////////////////
            testRegister();
        }

    }

    void SimCtrlRide::readMem2Fetch(){
        IData curPc   = _core.pc;
        curPc         = curPc >> 2; //// alignpc
        ull aligner   = (ull(1) << 2) - 1; ///// to align 4 instructions per read 111111...11100
        aligner       = (~aligner);
        ull alignedPc = curPc & aligner;

        ///// get new instruction data
        _core.idata[0] = _imem[alignedPc + 0];
        _core.idata[1] = _imem[alignedPc + 1];
        _core.idata[2] = _imem[alignedPc + 2];
        _core.idata[3] = _imem[alignedPc + 3];
    }

    void SimCtrlRide::readWriteDataMemGetCmd(){

        ///// make command enable
        lastDmemEnable = true;
        ///// read data from CPU
        CData dmem_we   = ull(_core.dmem_we);
        IData dmem_rwaddr = ull(_core.dmem_addr);
        IData dmem_wdata  = ull(_core.dmem_wdata);
        assert((dmem_rwaddr & 0b11) == 0b00);

        lastDmemRead = (dmem_we == 0);
        lastDmemAddr = static_cast<uint32_t>(dmem_rwaddr);
        lastDmemWData = static_cast<uint32_t>(dmem_wdata);

    }

    void SimCtrlRide::readWriteDataMemDoCmd(){

        if (!lastDmemEnable){return;}

        ///// At now, lastDmemAddr is quiet sure that there is not polute bit
        uint32_t aligned_addr = lastDmemAddr >> 2;

        if (lastDmemRead){
            if (aligned_addr >= DMEM_ROW){
                std::cout << "skip read due to exceed memory address" << std::endl;
            }else{
                _core.dmem_data = _dmem[aligned_addr];
            }
        }else{
            if (aligned_addr >= DMEM_ROW){
                std::cout << "skip write due to exceed memory address" << std::endl;
            }else{

                _dmem[aligned_addr] = lastDmemWData;
                if ((_resultWriter != nullptr) && (aligned_addr == 0x0)){
                    _resultWriter->fillResult(lastDmemWData);
                }
                ////std::cout << "write Detect at @ " << cvtNum2HexStr(lastDmemAddr) << " with data " << lastDmemWData << std::endl;
                if (lastDmemAddr == 0x0 || lastDmemAddr == 0x4 || lastDmemAddr == 0x8){
                    std::cout << "write Detect at  Ride @ " << cvtNum2HexStr(lastDmemAddr) << " with data " << lastDmemWData << std::endl;
                }
            }

        }

    }

    void SimCtrlRide::resetRegister(){
        for (int i = 0; i < REG_NUM; i++){
            _core.pipeline->aregfile->regfile->mem[i] = 0;
        }
    }

    void SimCtrlRide::testRegister(){
        bool pass = true;
        for (int i = 0;  i < REG_NUM; i++){
            if (_regTestVal[i] != _core.pipeline->aregfile->regfile->mem[i]){
                pass = false;
                std::cout << TC_RED << "fail reg: " << std::to_string(i)
                                    << _core.pipeline->aregfile->regfile->mem[i]
                          << TC_DEF << std::endl;
            }
        }
        if (pass){
            std::cout << TC_GREEN << "register val test pass" << TC_DEF << std::endl;
        }else{
            std::cout << TC_RED << "register val test fail" << TC_DEF << std::endl;
        }
    }

    void SimCtrlRide::postCycleAction(){}


}

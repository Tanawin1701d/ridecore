//
// Created by tanawin on 31/12/25.
//

#include "simCtrlRide.h"



namespace kathryn::o3{

    SimCtrlRide::SimCtrlRide(CYCLE                    limitCycle,
                             const std::string&       prefix,
                             std::vector<std::string> testTypes,
                             SimProxyBuildMode        buildMode,
                             SlotWriterBase&          slotWriter,
                             SimState&                state,
                             Vpipeline&               core):
    O3SimCtrlBase(limitCycle,
                  prefix,
                  std::move(testTypes),
                  buildMode,
                  slotWriter,
                  state
    ),
    _core(core){}

    void SimCtrlRide::iterateCycle(){
        _core.clk = 1;
        _core.eval();
        _core.clk = 0;
        _core.eval();
    }

    void SimCtrlRide::iterateAtEndCycle(){
        _core.clk = 0;
        _core.eval();
    }


    void SimCtrlRide::simStart(){

        for (; _curTestCaseIdx < _testTypes.size(); _curTestCaseIdx++){
            std::cout << TC_BLUE << "[O3 RISC-V] test type is " << _testTypes[_curTestCaseIdx] << TC_DEF << std::endl;
            //////////////  read assembly and assertVal
            _slotWriter. renew(_prefixFolder + _testTypes[_curTestCaseIdx]+ "/oslot.sl");
            //////// set reset wire to 1
            *rstWire = 1;
            //////// cycle before cycle cycle is running
            iterateCycle();
            *rstWire = 0;
            resetRegister();
            readAssembly (_prefixFolder + _testTypes[_curTestCaseIdx] + "/asm.out");
            readAssertVal(_prefixFolder + _testTypes[_curTestCaseIdx] + "/ast.out");
            resetDmem();
            //////// iterate for 100 cycle
            for (int i = 0; i <= 150; i++){
                ///////// give the data to
                readMem2Fetch();
                readWriteDataMemDoCmd(); ///// do the dmem command command

                iterateAtEndCycle();
                readWriteDataMemGetCmd();
                ///////// record the system
                _state.recruitValue();
                _state.printSlotWindow(_slotWriter);
                postCycleAction();
                _slotWriter.concludeEachCycle();
                //////////////////////////////////
                iterateCycle();
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
        IData dmem_wdata  = ull(_core.dmem_data);
        assert((dmem_rwaddr & 0b11) == 0b00);

        lastDmemRead = (dmem_we == 0);
        lastDmemAddr = static_cast<uint32_t>(dmem_rwaddr);
        lastDmemData = static_cast<uint32_t>(dmem_wdata);

    }

    void SimCtrlRide::readWriteDataMemDoCmd(){

        if (!lastDmemEnable){return;}

        ///// At now, lastDmemAddr is quiet sure that there is not polute bit
        uint32_t aligned_addr = lastDmemAddr >> 2;

        if (lastDmemRead){
            _core.dmem_data = _dmem[aligned_addr];
        }else{
            _dmem[aligned_addr] = lastDmemData;
            std::cout << "write Detect at @ " << cvtNum2HexStr(lastDmemAddr) << " with data " << lastDmemData << std::endl;
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

    void postCycleAction(){}


}


# 1. collect Verilator-generted sources
file (GLOB VERILATOR_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/obj_dir/*.cpp)



# 2. create static library
add_library(verilator_ridecore STATIC ${VERILATOR_SOURCES}
        /usr/share/verilator/include/verilated.cpp
        ##/usr/share/verilator/include/verilated_threads.cpp
)

# 3. export include directory so others can #include "Vpipeline.h" etc.
target_include_directories(verilator_ridecore PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/obj_dir
        /usr/share/verilator/include
        /usr/share/verilator/include/vltstd/

)
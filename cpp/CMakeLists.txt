cmake_minimum_required(VERSION 3.10)
project(SortVisualizer)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find SDL2 packages
find_package(SDL2 REQUIRED)
find_package(SDL2_mixer REQUIRED)

# Include directories
include_directories(${SDL2_INCLUDE_DIRS})

# Add executable
add_executable(sort_visualizer
    src/main.cpp
)

# Link libraries
target_link_libraries(sort_visualizer
    ${SDL2_LIBRARIES}
    SDL2_mixer
    pthread
)

# For Raspberry Pi, we might need to explicitly link these
if(CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    target_link_libraries(sort_visualizer
        bcm_host
    )
endif()

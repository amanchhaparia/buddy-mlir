_add_test_executable(buddy-container-test
  ContainerTest.cpp
  LINK_LIBS
    Container
)

if(BUDDY_ENABLE_OPENCV)
find_package(OpenCV REQUIRED CONFIG)
include_directories(${OpenCV_INCLUDE_DIRS})
_add_test_executable(buddy-image-container-test
  ImageContainerTest.cpp
  LINK_LIBS
    ${OpenCV_LIBS}
)
endif()

add_subdirectory(${KFR_DIR} ./kfr)
include_directories(${KFR_DIR}/include)
_add_test_executable(buddy-audio-container-test
  AudioContainerTest.cpp
  LINK_LIBS
  Container AudioContainer kfr_io kfr_dft
)
target_link_directories(buddy-audio-container-test PRIVATE ${KFR_DIR}/build/)

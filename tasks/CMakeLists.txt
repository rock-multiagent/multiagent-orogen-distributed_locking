# Generated from orogen/lib/orogen/templates/tasks/CMakeLists.txt

include(distributed_lockingTaskLib)
ADD_LIBRARY(${DISTRIBUTED_LOCKING_TASKLIB_NAME} SHARED 
    ${DISTRIBUTED_LOCKING_TASKLIB_SOURCES})
add_dependencies(${DISTRIBUTED_LOCKING_TASKLIB_NAME}
    regen-typekit)

TARGET_LINK_LIBRARIES(${DISTRIBUTED_LOCKING_TASKLIB_NAME}
    ${OrocosRTT_LIBRARIES}
    ${DISTRIBUTED_LOCKING_TASKLIB_DEPENDENT_LIBRARIES})
SET_TARGET_PROPERTIES(${DISTRIBUTED_LOCKING_TASKLIB_NAME}
    PROPERTIES LINK_INTERFACE_LIBRARIES "${DISTRIBUTED_LOCKING_TASKLIB_INTERFACE_LIBRARIES}")

INSTALL(TARGETS ${DISTRIBUTED_LOCKING_TASKLIB_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib/orocos)

INSTALL(FILES ${DISTRIBUTED_LOCKING_TASKLIB_HEADERS}
    DESTINATION include/orocos/distributed_locking)


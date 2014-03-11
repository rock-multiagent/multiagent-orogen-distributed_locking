/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "DistributedLockingTask.hpp"

using namespace distributed_locking;

DistributedLockingTask::DistributedLockingTask(std::string const& name, TaskCore::TaskState initial_state)
    : DistributedLockingTaskBase(name, initial_state)
{
}

DistributedLockingTask::DistributedLockingTask(std::string const& name, RTT::ExecutionEngine* engine, TaskCore::TaskState initial_state)
    : DistributedLockingTaskBase(name, engine, initial_state)
{
}

DistributedLockingTask::~DistributedLockingTask()
{
}



/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See DistributedLockingTask.hpp for more detailed
// documentation about them.

bool DistributedLockingTask::configureHook()
{
    if (! DistributedLockingTaskBase::configureHook())
        return false;
    return true;
}
bool DistributedLockingTask::startHook()
{
    if (! DistributedLockingTaskBase::startHook())
        return false;
    return true;
}
void DistributedLockingTask::updateHook()
{
    DistributedLockingTaskBase::updateHook();
}
void DistributedLockingTask::errorHook()
{
    DistributedLockingTaskBase::errorHook();
}
void DistributedLockingTask::stopHook()
{
    DistributedLockingTaskBase::stopHook();
}
void DistributedLockingTask::cleanupHook()
{
    DistributedLockingTaskBase::cleanupHook();
}

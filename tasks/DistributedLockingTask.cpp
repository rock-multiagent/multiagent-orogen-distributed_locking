/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "DistributedLockingTask.hpp"

#include <distributed_locking/DLM.hpp>
#include <distributed_locking/RicartAgrawala.hpp>

using namespace distributed_locking;

DistributedLockingTask::DistributedLockingTask(std::string const& name, TaskCore::TaskState initial_state)
    : DistributedLockingTaskBase(name, initial_state)
    , mpDlm(0)
{
    // TODO load self (Agent) from configuration file
    mpDlm = new fipa::distributed_locking::RicartAgrawala();
}

DistributedLockingTask::DistributedLockingTask(std::string const& name, RTT::ExecutionEngine* engine, TaskCore::TaskState initial_state)
    : DistributedLockingTaskBase(name, engine, initial_state)
   , mpDlm(0)
{
    mpDlm = new fipa::distributed_locking::RicartAgrawala();
}

DistributedLockingTask::~DistributedLockingTask()
{
    delete mpDlm;
}

::fipa::distributed_locking::lock_state::LockState DistributedLockingTask::getLockState(::std::string const & resource)
{
    return mpDlm->getLockState(resource);
}

void DistributedLockingTask::lock(::std::string const & resource, ::std::vector< ::fipa::Agent > const & agents)
{
    mpDlm->lock(resource, std::list<fipa::Agent> (agents.begin(), agents.end()));
    trigger();
}

void DistributedLockingTask::unlock(::std::string const & resource)
{
    mpDlm->unlock(resource);
    trigger();
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
    
    // Get message from DLM if there is one
    while(mpDlm->hasOutgoingMessages())
    {
        fipa::acl::ACLMessage msgOut =  mpDlm->popNextOutgoingMessage();
        
        // Convert to letter.
        fipa::acl::ACLEnvelope envelopeOut (msgOut, fipa::acl::representation::BITEFFICIENT);
        // fipa::acl::ACLEnvelope is the same as fipa::acl::Letter
        fipa::SerializedLetter letterOut (envelopeOut, fipa::acl::representation::BITEFFICIENT);
        
        // Push to output port
        _lettersOut.write(letterOut);
    }
    
    // Check if there is something on the input port
    fipa::SerializedLetter letterIn;
    while(_lettersIn.read(letterIn) == RTT::NewData)
    {
        // Convert back
        fipa::acl::ACLEnvelope envelopeIn = letterIn.deserialize();
        fipa::acl::ACLMessage msgIn = envelopeIn.getACLMessage();
        
        // Forward message to DLM
        mpDlm->onIncomingMessage(msgIn);
    }    
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

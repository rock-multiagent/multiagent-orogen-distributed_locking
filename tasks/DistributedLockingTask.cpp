/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "DistributedLockingTask.hpp"

#include <distributed_locking/DLM.hpp>
#include <distributed_locking/RicartAgrawala.hpp>

using namespace distributed_locking;

DistributedLockingTask::DistributedLockingTask(std::string const& name)
    : DistributedLockingTaskBase(name)
    , mpDlm(0)
{
}

DistributedLockingTask::DistributedLockingTask(std::string const& name, RTT::ExecutionEngine* engine)
    : DistributedLockingTaskBase(name, engine)
   , mpDlm(0)
{
}

DistributedLockingTask::~DistributedLockingTask()
{
}

::fipa::Agent DistributedLockingTask::getAgent()
{
    // RTT::log(RTT::Warning) << "asdfjkasldj" << RTT::endlog()
    // in shell:
    // export ORO_LOGLEVEL=5 
    // um Info log zu sehen, maximal 6  für Debug
    return mpDlm->getSelf();
}

::fipa::distributed_locking::lock_state::LockState DistributedLockingTask::getLockState(::std::string const & resource)
{
    return mpDlm->getLockState(resource);
}

void DistributedLockingTask::lock(::std::string const & resource, ::std::vector< ::fipa::Agent > const & agents)
{
    RTT::log(RTT::Warning) << getAgent().identifier << " lock " << resource << RTT::endlog();
    mpDlm->lock(resource, std::list<fipa::Agent> (agents.begin(), agents.end()));
    trigger();
}

void DistributedLockingTask::unlock(::std::string const & resource)
{
    RTT::log(RTT::Warning) << getAgent().identifier << " unlock " << resource << RTT::endlog();
    mpDlm->unlock(resource);
    trigger();
}

void DistributedLockingTask::setOwnedResources(::std::vector< ::std::string > const & resources)
{
    mpDlm->setOwnedResources(resources);
}

/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See DistributedLockingTask.hpp for more detailed
// documentation about them.

bool DistributedLockingTask::configureHook()
{
    if (! DistributedLockingTaskBase::configureHook())
        return false;
    
    fipa::Agent self = _self.get();
    fipa::distributed_locking::protocol::Protocol protocol = _protocol.get();
    mpDlm = fipa::distributed_locking::DLM::dlmFactory(protocol, self);
    
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
    RTT::log(RTT::Info) << getAgent().identifier << " updateHook" << RTT::endlog();
    
    // Check if there is something on the input port
    fipa::SerializedLetter letterIn;
    while(_lettersIn.read(letterIn) == RTT::NewData)
    {
        // Convert back
        fipa::acl::ACLEnvelope envelopeIn = letterIn.deserialize();
        fipa::acl::ACLMessage msgIn = envelopeIn.getACLMessage();
        
        // Forward message to DLM
        mpDlm->onIncomingMessage(msgIn);
        RTT::log(RTT::Warning) << getAgent().identifier << " uH: new incoming message" << RTT::endlog();
    }
    
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
        RTT::log(RTT::Warning) << getAgent().identifier << " uH: new outgoing message" << RTT::endlog();
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
    
    delete mpDlm;
}

/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "DistributedLockingTask.hpp"
#include <distributed_locking/DLM.hpp>

using namespace distributed_locking;

DistributedLockingTask::DistributedLockingTask(std::string const& name)
    : DistributedLockingTaskBase(name)
    , mpDlm()
{
}

DistributedLockingTask::DistributedLockingTask(std::string const& name, RTT::ExecutionEngine* engine)
    : DistributedLockingTaskBase(name, engine)
    , mpDlm()
{
}

DistributedLockingTask::~DistributedLockingTask()
{
}

std::string DistributedLockingTask::getAgent()
{
    return mpDlm->getSelf().getName();
}

::fipa::distributed_locking::lock_state::LockState DistributedLockingTask::getLockState(::std::string const & resource)
{
    return mpDlm->getLockState(resource);
}

void DistributedLockingTask::lock(::std::string const & resource, ::std::vector<std::string> const & agents)
{
    RTT::log(RTT::Warning) << getAgent() << " lock " << resource << RTT::endlog();

    std::vector<fipa::acl::AgentID> agentList;
    std::vector<std::string>::const_iterator cit = agents.begin();
    for(; cit != agents.end(); ++cit)
    {
        fipa::acl::AgentID agent(*cit);
        agentList.push_back(agent);
    }
    mpDlm->lock(resource, agentList);
}

void DistributedLockingTask::unlock(::std::string const & resource)
{
    RTT::log(RTT::Warning) << getAgent() << " unlock " << resource << RTT::endlog();
    mpDlm->unlock(resource);
}

/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See DistributedLockingTask.hpp for more detailed
// documentation about them.

bool DistributedLockingTask::configureHook()
{
    if (! DistributedLockingTaskBase::configureHook())
        return false;

    std::string agentName = _self.get();
    if(agentName.empty())
    {
        RTT::log(RTT::Warning) << "Agent name cannot be empty" << RTT::endlog();
        return false;
    }

    fipa::acl::AgentID self(agentName);
    fipa::distributed_locking::protocol::Protocol protocol = _protocol.get();
    std::vector<std::string> ownedResources = _owned_resources.get();
    mpDlm = fipa::distributed_locking::DLM::create(protocol, self, ownedResources);

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
    RTT::log(RTT::Info) << getAgent() << " updateHook" << RTT::endlog();

    // Don't forget to call to the library's trigger method, that requires to be called periodically
    mpDlm->trigger();

    // Check if there is something on the input port
    fipa::SerializedLetter letterIn;
    while(_letters_in.read(letterIn) == RTT::NewData)
    {
        // Convert back
        fipa::acl::ACLEnvelope envelopeIn = letterIn.deserialize();
        fipa::acl::ACLMessage msgIn = envelopeIn.getACLMessage();

        // Forward message to DLM
        mpDlm->onIncomingMessage(msgIn);
        RTT::log(RTT::Warning) << getAgent() << " updateHook: new incoming message" << RTT::endlog();
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
        _letters_out.write(letterOut);
        RTT::log(RTT::Warning) << getAgent() << " updateHook: new outgoing message" << RTT::endlog();
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

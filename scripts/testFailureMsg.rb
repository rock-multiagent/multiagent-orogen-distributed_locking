require 'orocos'

include Orocos
Orocos.initialize

# Test producing a message delivery failure message
Orocos.run "dlm_test", "fipa_services_test"  do  
    
    # Start a mts for the communication
    begin
        mts_module = TaskContext.get "mts_0"
    rescue Orocos::NotFound
        print 'Deployment not found.'
        raise
    end
    mts_module.configure
    mts_module.start
    
    agent1 = TaskContext.get "dlm_0"
    agent2 = TaskContext.get "dlm_1"

    # load property from configuration file
    agent1.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala", "agent1", "rsc1"])
    agent2.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala", "agent2"])
    
    # register agents in the mts instead of connecting directly
    mts_module.addReceiver("agent1", true)
    # sleep so they can get published in avahi-discover
    sleep 2
    # and connect them to the mts ports
    agent1.lettersOut.connect_to mts_module.letters, :type => :buffer, :size => 100
    mts_module.agent1.connect_to agent1.lettersIn, :type => :buffer, :size => 100

    # Call to configure is required for this component
    # since it has been generated with 'needs_configuration'
    agent1.configure
    agent2.configure
    
    # start them
    agent1.start
    agent2.start
    
    resource = 'rsc1' # This is important due to the configuration with rsc1

    # Now we lock, with a non-existing agent name
    agent1.lock(resource, [agent2.getAgent])
    # and wait until user presses Enter
    readline
    
    # now the agent gets added as a receiver
    mts_module.addReceiver("agent2", true)
    # sleep so they can get published in avahi-discover
    sleep 2
    # and connect them to the mts ports
    agent2.lettersOut.connect_to mts_module.letters, :type => :buffer, :size => 100
    mts_module.agent2.connect_to agent2.lettersIn, :type => :buffer, :size => 100
    
    # lock
    agent1.lock(resource, [agent2.getAgent])
    sleep 0.5
    agent2.lock(resource, [agent1.getAgent])
    sleep 0.5
    # remove from receivers
    mts_module.removeReceiver("agent2")
    # sleep so they can get published in avahi-discover
    sleep 2
    # unlock (fails)
    agent1.unlock(resource)
    # and wait until user presses Enter
    readline
end
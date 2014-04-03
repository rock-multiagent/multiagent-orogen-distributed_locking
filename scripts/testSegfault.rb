require 'orocos'

include Orocos
Orocos.initialize

# Test for Ricart-Agrawala Extended
Orocos.run "dlm_test", "fipa_services_test", :valgrind => false  do  
    puts "Testing Ricart-Agrawala Extended"
    
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
    agent1.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala-extended", "agent1", "rsc1"])
    agent2.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala-extended", "agent2"])
    
    # register agents in the mts instead of connecting directly
    mts_module.addReceiver("agent1", true)
    mts_module.addReceiver("agent2", true)
    mts_module.addReceiver("agent3", true)
    # sleep so they can get published in avahi-discover
    sleep 2
    # and connect them to the mts ports
    agent1.lettersOut.connect_to mts_module.letters, :type => :buffer, :size => 100
    agent2.lettersOut.connect_to mts_module.letters, :type => :buffer, :size => 100
    mts_module.agent1.connect_to agent1.lettersIn, :type => :buffer, :size => 100
    mts_module.agent2.connect_to agent2.lettersIn, :type => :buffer, :size => 100

    # Call to configure is required for this component
    # since it has been generated with 'needs_configuration'
    agent1.configure
    agent2.configure
    
    # start them
    agent1.start
    agent2.start
    
    resource = 'rsc1' # This is important due to the configuration with rsc1

    # Now we lock
    agent1.lock(resource, [agent2.getAgent])
    agent2.lock(resource, [agent1.getAgent])
    
    # Now, agent 2 dies
    agent1.stop
    
    # After the timeout, crash?
    while true
        puts "waiting"
        sleep 1
    end
end
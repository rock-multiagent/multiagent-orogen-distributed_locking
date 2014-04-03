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
    agent3 = TaskContext.get "dlm_2"

    # load property from configuration file
    agent1.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala-extended", "agent1", "rsc1"])
    agent2.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala-extended", "agent2"])
    agent3.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala-extended", "agent3"])
    
    # register agents in the mts instead of connecting directly
    mts_module.addReceiver("agent1", true)
    mts_module.addReceiver("agent2", true)
    mts_module.addReceiver("agent3", true)
    # sleep so they can get published in avahi-discover
    sleep 2
    # and connect them to the mts ports
    agent1.lettersOut.connect_to mts_module.letters, :type => :buffer, :size => 100
    agent2.lettersOut.connect_to mts_module.letters, :type => :buffer, :size => 100
    agent3.lettersOut.connect_to mts_module.letters, :type => :buffer, :size => 100
    mts_module.agent1.connect_to agent1.lettersIn, :type => :buffer, :size => 100
    mts_module.agent2.connect_to agent2.lettersIn, :type => :buffer, :size => 100
    mts_module.agent3.connect_to agent3.lettersIn, :type => :buffer, :size => 100
    
    # this would be to connect the agents without MessageTransportTask
    #agent1.lettersOut.connect_to agent2.lettersIn, :type => :buffer, :size => 100
    #agent1.lettersOut.connect_to agent3.lettersIn, :type => :buffer, :size => 100
    #agent2.lettersOut.connect_to agent1.lettersIn, :type => :buffer, :size => 100
    #agent2.lettersOut.connect_to agent3.lettersIn, :type => :buffer, :size => 100
    #agent3.lettersOut.connect_to agent1.lettersIn, :type => :buffer, :size => 100
    #agent3.lettersOut.connect_to agent2.lettersIn, :type => :buffer, :size => 100

    # Call to configure is required for this component
    # since it has been generated with 'needs_configuration'
    agent1.configure
    agent2.configure
    agent3.configure
    
    # start them
    agent1.start
    agent2.start
    agent3.start
    
    resource = 'rsc1' # This is important due to the configuration with rsc1

    # Now we lock
    agent3.lock(resource, [agent1.getAgent, agent2.getAgent])
    # And check it is being locked
    while (status = agent3.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent3: #{status}"
        sleep 0.5 
    end
    puts "Agent3: #{status}"
    
    # Agent two tries to lock
    agent2.lock(resource, [agent1.getAgent, agent3.getAgent])
    sleep 1
    
    # Now, agent 3 dies
    agent3.stop
    # Disconnecting instead of stopping results in failure messages from mts => not desired.
    #agent3.lettersOut.disconnect_from mts_module.letters
    #mts_module.agent3.disconnect_from agent3.lettersIn
    
    # After the timeout, agent 2 should hold the lock
    while (status = agent2.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent2: #{status}"
        sleep 0.5 
    end
    puts "Agent2: #{status}"
    
    # FIXME Aaand here it fails
    
    # agent 2 release
    agent2.unlock(resource)
    
    # agent 1 (owner of the resource) obtains the lock
    agent1.lock(resource, [agent2.getAgent])
    while (status = agent1.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent1: #{status}"
        sleep 0.5 
    end
    puts "Agent1: #{status}"
    
    # Agent two tries to lock
    agent2.lock(resource, [agent1.getAgent, agent3.getAgent])
    sleep 1
    
    # Agent 1 dies
    #agent1.stop
    agent1.lettersOut.disconnect_from mts_module.letters
    mts_module.agent1.disconnect_from agent1.lettersIn
    
    
    # Now, after the timeout, agent2 should have switched into the UNREACHABLE state for that resource
    while (status = agent2.getLockState(resource)).to_s == "UNREACHABLE"
        puts "Agent2: #{status}"
        sleep 0.5 
    end
    puts "Agent2: #{status}"
end
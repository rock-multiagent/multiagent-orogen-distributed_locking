require 'orocos'

include Orocos
Orocos.initialize

# Test for Ricart-Agrawala
Orocos.run "dlm_test", "fipa_services_test"  do  
    puts "Testing Ricart-Agrawala"
    
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
    agent1.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala", "agent1"])
    agent2.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala", "agent2"])
    agent3.apply_conf_file("distributed_locking_config.yml", ["ricart-agrawala", "agent3"])
    
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
    
    resource = 'resource'
    # Agent1 owns the resource
    agent1.setOwnedResources([resource])

    # Now we lock
    agent1.lock(resource, [agent2.getAgent, agent3.getAgent])
    # And check it is being locked
    while (status = agent1.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent1: #{status}"
        sleep 0.5 
    end
    puts "Agent1: #{status}"
    
    # Agent two tries to lock
    agent2.lock(resource, [agent1.getAgent, agent3.getAgent])
    # agent 1 release
    agent1.unlock(resource)
    
    # Check it is being locked by a2 now
    while (status = agent2.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent2: #{status}"
        sleep 0.5 
    end
    puts "Agent2: #{status}"
    
    # A3 locks, sleep, A1 locks
    agent3.lock(resource, [agent1.getAgent, agent2.getAgent])
    sleep 0.5
    agent1.lock(resource, [agent2.getAgent, agent3.getAgent])
    
    # Unlock and see that he is NOT_INTERESTED
    agent2.unlock(resource)
    puts "Agent2: #{agent2.getLockState(resource)}"
    
    # Check it is being locked by a3 now
    while (status = agent3.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent3: #{status}"
        sleep 0.5 
    end
    puts "Agent3: #{status}"
    
    # agent 3 release
    agent3.unlock(resource)
    
    # Check it is being locked by a1 now
    while (status = agent1.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent1: #{status}"
        sleep 0.5 
    end
    puts "Agent1: #{status}"
    
    # agent 1 release
    agent1.unlock(resource)
    # Check no one is interested any more
    puts "Agent1: #{agent1.getLockState(resource)}"
    puts "Agent2: #{agent2.getLockState(resource)}"
    puts "Agent3: #{agent3.getLockState(resource)}"
end

# Test for Suzuki-Kasami
Orocos.run "dlm_test", "fipa_services_test" do  
    puts "Testing Suzuki-Kasami"
    
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
    agent1.apply_conf_file("distributed_locking_config.yml", ["suzuki-kasami", "agent1"])
    agent2.apply_conf_file("distributed_locking_config.yml", ["suzuki-kasami", "agent2"])
    agent3.apply_conf_file("distributed_locking_config.yml", ["suzuki-kasami", "agent3"])
    
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
    
    resource = 'resource'
    # Agent1 owns the resource
    agent1.setOwnedResources([resource])

    # Now we lock
    agent1.lock(resource, [agent2.getAgent, agent3.getAgent])
    # And check it is being locked
    while (status = agent1.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent1: #{status}"
        sleep 0.5 
    end
    puts "Agent1: #{status}"
    
    # Agent two tries to lock
    agent2.lock(resource, [agent1.getAgent, agent3.getAgent])
    # agent 1 release
    agent1.unlock(resource)
    
    # Check it is being locked by a2 now
    while (status = agent2.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent2: #{status}"
        sleep 0.5 
    end
    puts "Agent2: #{status}"
    
    # A3 locks, sleep, A1 locks
    agent3.lock(resource, [agent1.getAgent, agent2.getAgent])
    sleep 0.5
    agent1.lock(resource, [agent2.getAgent, agent3.getAgent])
    
    # Unlock and see that he is NOT_INTERESTED
    agent2.unlock(resource)
    puts "Agent2: #{agent2.getLockState(resource)}"
    
    # now, depending on when which messages were sent, either a1 or a3 gets the token first
    
    # Since the algorithms is not fair and a1 comes first in a2's list
    # he gets the token first.
    
    # Check it is being locked by a1/a3 now
    while (status = agent1.getLockState(resource)).to_s == "INTERESTED" and (status2 = agent3.getLockState(resource)).to_s == "INTERESTED"
        puts "Agent1: #{status}"
        puts "Agent3: #{status2}"
        sleep 0.5 
    end
    puts "Agent1: #{status}"
    puts "Agent3: #{status2}"
    
    if((status = agent1.getLockState(resource)).to_s == "LOCKED")
        # a1 got it
        # agent 1 release
        agent1.unlock(resource)
        
        # Check it is being locked by a3 now
        while (status = agent3.getLockState(resource)).to_s == "INTERESTED"
            puts "Agent3: #{status}"
            sleep 0.5 
        end
        puts "Agent3: #{status}"
        
        # agent 3 release
        agent3.unlock(resource)
    else
        # a3 got it
        # agent 3 release
        agent3.unlock(resource)
        
        # Check it is being locked by a3 now
        while (status = agent1.getLockState(resource)).to_s == "INTERESTED"
            puts "Agent1: #{status}"
            sleep 0.5 
        end
        puts "Agent1: #{status}"
        
        # agent 3 release
        agent1.unlock(resource)
    end
    
    # Check no one is interested any more
    puts "Agent1: #{agent1.getLockState(resource)}"
    puts "Agent2: #{agent2.getLockState(resource)}"
    puts "Agent3: #{agent3.getLockState(resource)}"
end
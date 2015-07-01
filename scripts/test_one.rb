require 'orocos'
require 'readline'

include Orocos
Orocos.initialize

# Test for Ricart-Agrawala
#Orocos.run "distributed_locking::DistributedLockingTask" => ["dlm_0","dlm_1","dlm_2"], "fipa_services::MessageTransportTask" => 'mts_0'  do
Orocos.run "distributed_locking::DistributedLockingTask" => "dlm_0" do
    puts "Testing Ricart-Agrawala"

    Readline::readline("Press Enter to proceed")

end

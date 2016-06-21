require 'orocos'

include Orocos
Orocos.initialize

## Execute the main task ##
Orocos.run 'sonar_tritech::Micron' => 'micron' do

  ## Get the task context##
  micron = Orocos.name_service.get 'micron'
  Orocos.apply_conf_file(micron, 'sonar_tritech::Micron.yml', ['default'] )

  ## Configure the task
  micron.configure

  ## Start the task ##
  micron.start
  Orocos.watch micron
end

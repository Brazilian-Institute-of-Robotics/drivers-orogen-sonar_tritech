require 'orocos'
require 'vizkit'

include Orocos
Orocos.initialize

sonar_gui = Vizkit.default_loader.SonarWidget

## Execute the main task ##
Orocos.run 'sonar_tritech::Micron' => 'micron' do
  
  ## Get the task context##
  micron = Orocos.name_service.get 'micron'
  Orocos.apply_conf_file(micron, 'sonar_tritech::Micron.yml', ['default'] )
  
  ## Configure the task
  micron.configure
  
  ## Configure SonarWidget ##
  sonar_gui.setRange(micron.config.max_distance)
  sonar_gui.setGain(micron.config.gain * 100)
  sonar_gui.setMaxRange(75)
  
  ## Set the signals ##
  sonar_gui.connect(SIGNAL('rangeChanged(int)')) do |value|
    config = micron.config
    config.max_distance = value
    micron.config = config
  end
  
  sonar_gui.connect(SIGNAL('gainChanged(int)')) do |value|
    config = micron.config
    config.gain = value / 100.0
    micron.config = config
  end
  
  ## Connect SonarWidget with Micron ##
  micron.sonar_samples.connect_to sonar_gui
  
  ## Start the task ##
  micron.start
  
  ## Start Vizkit ##
  sonar_gui.show
  Vizkit.exec
end
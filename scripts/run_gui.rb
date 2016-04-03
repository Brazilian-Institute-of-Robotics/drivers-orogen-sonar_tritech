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
  
  ## Check if the continuous property was changed ##
  Orocos::Async.proxy(micron).property("config").on_change do |config|
    sonar_gui.setSectorScan(micron.config.continous, micron.config.left_limit, micron.config.right_limit)
  end

  ## Connect SonarWidget with Micron ##
  Orocos::Async.proxy(micron).port("sonar_samples").on_data(type: :buffer, size: 10) do |sample|
	sonar_gui.setData(sample)
  end

  ## Start the task ##
  micron.start
  
  ## Start Vizkit ##
  sonar_gui.show
  Vizkit.exec
end
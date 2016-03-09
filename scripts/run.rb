require 'orocos'
include Orocos
Orocos.initialize

Orocos.run "sonar_tritech::Micron" => "micron" do

    #Orocos.log_all

    micron = Orocos.name_service.get 'micron'
    #bvt = TaskContext.get 'bvt'
    Orocos.apply_conf_file(micron, 'sonar_tritech::Micron.yml', ['default'])

    micron.configure
    micron.start

    Orocos.watch(micron)
end

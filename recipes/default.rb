augeas_configset "example_eth1" do
  commands [ "set /files/etc/network/interfaces/iface[2] eth1", "set /files/etc/network/interfaces/iface[2]/method static" ]
end

augeas_config "example_eth1_dhcp" do
  command "set /files/etc/network/interfaces/iface[2]/method dhcp"
end



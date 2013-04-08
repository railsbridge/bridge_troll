class OperatingSystem < ActiveHash::Base
  include ActiveHash::Enum
  self.data = [
    {id: 1, name: 'OSX_MOUNTAIN_LION', title: 'Mac OS X - Mountain Lion (10.8)'},
    {id: 2, name: 'OSX_LION', title: 'Mac OS X - Lion (10.7)'},
    {id: 3, name: 'OSX_SNOW_LEOPARD', title: 'Mac OS X - Snow Leopard (10.6)'},
    {id: 4, name: 'OSX_LEOPARD', title: 'Mac OS X - Leopard (10.5)'},
    {id: 5, name: 'WINDOWS_8', title: 'Windows 8'},
    {id: 6, name: 'WINDOWS_7', title: 'Windows 7'},
    {id: 7, name: 'WINDOWS_OTHER', title: 'Windows - Other'},
    {id: 8, name: 'LINUX_UBUNTU', title: 'Linux - Ubuntu'},
    {id: 9, name: 'LINUX_OTHER', title: 'Linux - Other'},
  ]

  enum_accessor :name
end

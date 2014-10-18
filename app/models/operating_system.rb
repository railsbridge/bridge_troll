class OperatingSystem < ActiveHash::Base
  include ActiveHash::Enum
  self.data = [
    {
      id: 11,
      name: 'OSX_YOSEMITE',
      type: :osx,
      title: 'Mac OS X - Yosemite (10.10)'
    },
    {
      id: 10,
      name: 'OSX_MAVERICKS',
      type: :osx,
      title: 'Mac OS X - Mavericks (10.9)'
    },
    {
      id: 1,
      name: 'OSX_MOUNTAIN_LION',
      type: :osx,
      title: 'Mac OS X - Mountain Lion (10.8)'
    },
    {
      id: 2,
      name: 'OSX_LION',
      type: :osx,
      title: 'Mac OS X - Lion (10.7)'
    },
    {
      id: 3,
      name: 'OSX_SNOW_LEOPARD',
      type: :osx,
      title: 'Mac OS X - Snow Leopard (10.6)'
    },
    {
      id: 4,
      name: 'OSX_LEOPARD',
      type: :osx,
      title: 'Mac OS X - Leopard (10.5)'
    },
    {
      id: 5,
      name: 'WINDOWS_8',
      type: :windows,
      title: 'Windows 8'
    },
    {
      id: 6,
      name: 'WINDOWS_7',
      type: :windows,
      title: 'Windows 7'
    },
    {
      id: 7,
      name: 'WINDOWS_OTHER',
      type: :windows,
      title: 'Windows - Other'
    },
    {
      id: 8,
      name: 'LINUX_UBUNTU',
      type: :linux,
      title: 'Linux - Ubuntu'
    },
    {
      id: 9,
      name: 'LINUX_OTHER',
      type: :linux,
      title: 'Linux - Other'
    }
  ]

  enum_accessor :name
end

Facter.add(:hardware_type) do
  confine :virtual => 'physical'
  setcode do
    hardware_type = 'onbekend'
    if Facter.value(:productname).match(/DL/)
      hardware_type = 'Rack Mount'
    elsif Facter.value(:productname).match(/BL/)
      hardware_type = 'Blade'
    end
  hardware_type
  end
end
Facter.add(:hardware_serie) do
  confine :hardware_type => 'Blade'
  setcode do
    hardware_serie = 'onbekend'
    if Facter.value(:productname).match(/BL\d+p/)
      hardware_serie = 'p-Class Blade'
    elsif Facter.value(:productname).match(/BL\d+c/)
      hardware_serie = 'c-Class Blade'
    end
  hardware_serie
  end
end

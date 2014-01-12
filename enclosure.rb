# Nodig om YAML te lezen
require 'yaml'
require 'open-uri'

Facter.add(:enclosure, :timeout => 10) do
  confine :hardware_serie => 'c-Class Blade'

  setcode do

  # Standaard status is undefined
  enclosure = 'onbekend'
  
    begin
      data = YAML::load(open('http://xxx/pub/puppet/enclosures.yaml'));
      # Hostname fact gebruiken voor nodenaam
      serial = Facter.value('serialnumber')
      # Alle enclosures verzamelen
      enclosures = data.keys
      # Controleren of node in 1 van de arrays zit
      for enc in enclosures
        if data[enc].include? serial
          enclosure = enc
        end # if data[enclosure].include? serial
      end # for enclosure in enclosures
  
    rescue
        enclosure = 'timeout'
    end
  enclosure
  end # setcode
end # Facter.add

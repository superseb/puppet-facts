Facter.add(:lvs_installed) do
  confine :kernel => 'Linux'
  setcode do
    lvs_installed = 'false'
    if File.exists?('/etc/sysconfig/ha/lvs.cf')
      lvs_installed = 'true'
    end
  lvs_installed
  end
end

Facter.add(:lvs_active) do
  confine :lvs_installed => 'true'
  setcode do
    lvs_active = 'unknown'
    lvs_service = Facter.value('lvs_service')
    output = %x{/bin/ps -ef | /bin/grep nanny | /bin/grep -v grep}
    if lvs_service == 'lvs'
      if output =~ /nanny/
        lvs_active = 'true'
      else
        lvs_active = 'false'
      end
    elsif lvs_service == 'fos'
      if output !~ /nanny/
        lvs_active = 'true'
      else
        lvs_active = 'false'
      end
    end
  lvs_active
  end
end

Facter.add(:lvs_virtualcount) do
  confine :lvs_installed => 'true'
  setcode do
    output = %x{/bin/cat /etc/sysconfig/ha/lvs.cf}
    lvs_virtualcount = output.scan(/virtual/).size
    lvs_virtualcount
  end
end

Facter.add(:lvs_virtuals) do
  confine :lvs_installed => 'true'
  setcode do
    output = %x{/bin/cat /etc/sysconfig/ha/lvs.cf}
    virtuals = output.scan(/virtual\s(.*?)\s/)
    lvs_virtuals = virtuals.join(',')
    lvs_virtuals
  end
end

if Facter.value('lvs_installed') == 'true'
  output = %x{/bin/cat /etc/sysconfig/ha/lvs.cf}

  virtuals = output.scan(/(virtual.*?server.*?\}\n\})\n/m)

  virtuals.each do |virtual|
     virtualname = $1 if virtual.to_s =~ /virtual\s(.*?)\s/m
     realservercount = virtual.to_s.scan(/server.*?\{/).size
     realservers = virtual.to_s.scan(/(server\s\w+.*?\{.*?\})/m)
  
     virtualparams = virtual.to_s.gsub(/server.*?\{.*?\}/m, '')
  
      virtualparams.to_s.each_line do |line|
        if line =~ /(\w+)\s=\s(.*?)\n/
          factname = $1
          factvalue = $2
          Facter.add("lvs_#{virtualname}_#{factname}") do
            setcode do
              factvalue
            end
          end
        end
     end
  
     realserverlist = realservers.to_s.scan(/server\s(.*?)\s/m).join(',')
     Facter.add("lvs_#{virtualname}_realserverlist") do
       setcode do
         realserverlist
       end
     end
  
     for realserver in realservers
       realservername = $1 if realserver.to_s =~ /server\s(.*?)\s/m
       realserver.to_s.each_line do |line|
         if line =~ /(\w+)\s=\s(.*?)\n/
           factname = $1
           factvalue = $2
           Facter.add("lvs_#{virtualname}_#{realservername}_#{factname}") do
             setcode do
               factvalue
             end
           end
         end
       end
     end
  end

  output.each_line do |line|
    if line =~ /^(\w+)\s=\s(.*?)\n/
      factname = $1
      factvalue = $2
      Facter.add("lvs_#{factname}") do
        setcode do
          factvalue
        end # setcode do
      end # Facter.add
    end # if line =~
  end # output.each_line do |line|
  
end

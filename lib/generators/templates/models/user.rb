require 'ipaddr'

class User
  def initialize(data = {}, data_folder = RAILS_ROOT + '/data/optins/')
    data.each_key do |key|
      if data[key].nil?
        data[key] = ''
      end
    end

    @email = data['email']
    @name = data['name']
    @last_name = data['last_name']
    @birthday = data['birthday']
    @gender = data['gender']
    if not data['location'].nil? and not data['location']['name'].nil?
      @fb_location = data['location']['name']
    else
      @fb_location =''
    end
    @ip = data['ip'] ################
    if @ip
      @ipInt = IPAddr.new(@ip).to_i
    else
      @ipInt = 0
    end
    @time = Time.now.to_i
    @data_folder = data_folder
    @country = GeoIP.new(RAILS_ROOT + '/lib/GeoIP.dat').country(@ip)[3]
    @country = 'XX' if @country == '--'
    @country.downcase!
  end

  def save
    entry = "#{@email};#{@name};#{@last_name};#{@birthday};#{@fb_location};#{@gender};#{@ipInt};#{@time};\n"
    optin_file = @data_folder + @country

    # Guardamos el optin
    File.open(optin_file, 'a') do |file|
      file.flock(File::LOCK_EX)
      file.write(entry)
    end
  end

  def self.unsubscribe(email = '', ip = '', data_folder = RAILS_ROOT + '/data/unsubscribes/')
    if not email.empty? and not ip.empty?
      unsubscription_file = data_folder + 'unsubscribes'

      entry = "#{email};#{IPAddr.new(ip).to_i};#{Time.now.to_i}\n"

      # Guardamos la baja
      File.open(unsubscription_file, 'a') do |file|
        file.flock(File::LOCK_EX)
        file.write(entry)
      end
    end
  end
  
end
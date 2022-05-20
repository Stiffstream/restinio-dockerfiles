MxxRu::arch_externals :so5 do |e|
  USE_SO_5_5 = 'so-5.5'
  if USE_SO_5_5 == ENV.fetch('RESTINIO_USE_LATEST_SO5', USE_SO_5_5)
    e.url 'https://github.com/eao197/so-5-5/archive/v5.5.24.4.tar.gz'

    e.map_dir 'dev/so_5' => 'dev'
    e.map_dir 'dev/timertt' => 'dev'
  else
    e.url 'https://github.com/Stiffstream/sobjectizer/archive/v.5.7.4.tar.gz'

    e.map_dir 'dev/so_5' => 'dev'
  end
end

MxxRu::arch_externals :asio do |e|
  e.url 'https://github.com/chriskohlhoff/asio/archive/asio-1-21-0.tar.gz'

  e.map_dir 'asio/include' => 'dev/asio'
end

MxxRu::arch_externals :asio_mxxru do |e|
  e.url 'https://github.com/Stiffstream/asio_mxxru/archive/1.1.2.tar.gz'

  e.map_dir 'dev/asio_mxxru' => 'dev'
end

MxxRu::arch_externals :rapidjson do |e|
  e.url 'https://github.com/miloyip/rapidjson/archive/v1.1.0.zip'

  e.map_dir 'include/rapidjson' => 'dev/rapidjson/include'
end

MxxRu::arch_externals :rapidjson_mxxru do |e|
  e.url 'https://github.com/Stiffstream/rapidjson_mxxru/archive/v.1.0.1.tar.gz'

  e.map_dir 'dev/rapidjson_mxxru' => 'dev'
end

MxxRu::arch_externals :json_dto do |e|
  e.url 'https://github.com/Stiffstream/json_dto/archive/v.0.2.15.tar.gz'

  e.map_dir 'dev/json_dto' => 'dev'
end

MxxRu::arch_externals :clara do |e|
  e.url 'https://github.com/catchorg/Clara/archive/v1.1.5.tar.gz'

  e.map_file 'single_include/clara.hpp' => 'dev/clara/*'
end


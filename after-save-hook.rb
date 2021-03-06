require 'pathname'
require 'yaml'

nanoc_compile_proc = Proc.new do |buffer|
  next  if buffer.nil?
  next  if buffer.name.nil?
  next  if buffer.name =~ /\.(?:css|js)$/

  path = Pathname.new( buffer.name ).dirname
  next  if ! path.exist?

  last_path = nil
  loop do
    config_file = Dir[ "#{path}/config.yaml" ][0]
    if config_file
      config = YAML::load_file( config_file )
      if config[ 'output_dir' ]
        output = `pushd #{path}; nanoc compile; popd >/dev/null`.split( /\n/ )[-1]
        $diakonos.set_iline output
        break
      end
    end

    path = path.parent
    break  if path == last_path
    last_path = path
  end
end

$diakonos.register_proc( nanoc_compile_proc, :after_save )

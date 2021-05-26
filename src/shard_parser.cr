require "../lib/shards/src/spec"

# Stand-alone script to parse a shard.yml file and display the information it contains

if ARGV.size != 1
    puts "Need path to shard.yml"
    exit 1
end

path_to_shard_yml = ARGV[0]
puts path_to_shard_yml

path_to_dir = Path[path_to_shard_yml].dirname
res = Shards::Spec.from_file(path_to_dir) # validate = true

#p! res
puts res.name
puts res.version
puts res.original_version
puts res.description
puts res.license
puts res.crystal
puts res.targets
puts res.executables
puts res.libraries
puts res.scripts


puts "Dependencies:"
res.dependencies.each {|dep|
    #p! dep
    puts "  #{dep.name}"
    puts "  #{dep.resolver.source}"
    # puts "  #{dep.resolver.origin_url}"
    # puts "  #{dep.resolver.local_path}"
    # puts "  #{dep.resolver.updated_cache}"
    puts "  #{dep.requirement}"
    puts ""
}

puts "Development Dependencies:"
res.development_dependencies.each {|dep|
    #p! dep
    puts "  #{dep.name}"
    puts "  #{dep.resolver.source}"
    # puts "  #{dep.resolver.origin_url}"
    # puts "  #{dep.resolver.local_path}"
    # puts "  #{dep.resolver.updated_cache}"
    puts "  #{dep.requirement}"
    puts ""
}

puts "Authors:"
res.authors.each {|aut|
    #p! aut
    puts "  #{aut.name}"
    puts "  #{aut.email}"
    puts ""
}


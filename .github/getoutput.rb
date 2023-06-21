require 'yaml'
ref = "HEAD~2"
repos = Dir["kubernetes/flux/repositories/helm/*.yaml"]
repo_hash = {}

repos.each do |repo|
  repo_data = YAML.load(File.read(repo))
  next unless repo_data["metadata"]
  repo_hash[repo_data["metadata"]["name"]] = repo_data["spec"]["url"]
end

#puts repo_hash.inspect

changed_files = `git diff #{ref} --name-only`.lines.map(&:strip)

changed_files.each do |file|
  next unless file.end_with?(".yaml")

  cur_file = YAML.load(File.read(file))
  next unless cur_file['kind'] == "HelmRelease"
  prev_file = YAML.load(`git show #{ref}:#{file}`)

  cur = {}
  cur[:name] = cur_file["metadata"]["name"]
  cur[:repo] = cur_file["spec"]["chart"]["spec"]["sourceRef"]["name"]
  cur[:chart] = cur_file["spec"]["chart"]["spec"]["chart"]
  cur[:ver] = cur_file["spec"]["chart"]["spec"]["version"]
  cur[:values] = cur_file["spec"]["values"]
  cur[:url] = repo_hash[cur[:repo]]

  prev = {}
  prev[:name] = prev_file["metadata"]["name"]
  prev[:repo] = prev_file["spec"]["chart"]["spec"]["sourceRef"]["name"]
  prev[:chart] = prev_file["spec"]["chart"]["spec"]["chart"]
  prev[:ver] = prev_file["spec"]["chart"]["spec"]["version"]
  prev[:values] = prev_file["spec"]["values"]
  prev[:url] = repo_hash[prev[:repo]]

  `mkdir -p .tmp`
  File.open(".tmp/values_cur.yaml", "w") do |f|
    f << YAML.dump(cur[:values])
  end
  File.open(".tmp/values_prev.yaml", "w") do |f|
    f << YAML.dump(prev[:values])
  end

  `helm repo add #{prev[:repo]} #{prev[:url]} 2> /dev/null`
  `helm repo add #{cur[:repo]} #{cur[:url]} 2> /dev/null`

  `rm -rf .tmp/cur`
  `mkdir .tmp/cur`
  cur_files = `helm template -f .tmp/values_cur.yaml --version #{cur[:ver]} #{cur[:repo]}/#{cur[:chart]} 2> /dev/null`.split("---")
  cur_files.each do |cur_f|
    file_data = YAML.load(cur_f)
    next if file_data.nil? || file_data == false
    filename = "#{file_data["kind"]}-#{file_data["metadata"]["name"]}.yaml"
    File.open(".tmp/cur/#{filename}", "w") do |f|
      f << YAML.dump(file_data)
    end
  end

  `rm -rf .tmp/prev`
  `mkdir .tmp/prev`
  prev_files = `helm template -f .tmp/values_prev.yaml --version #{prev[:ver]} #{prev[:repo]}/#{prev[:chart]} 2> /dev/null`.split("---")
  prev_files.each do |prev_f|
    file_data = YAML.load(prev_f)
    next if file_data.nil?
    filename = "#{file_data["kind"]}-#{file_data["metadata"]["name"]}.yaml"
    File.open(".tmp/prev/#{filename}", "w") do |f|
      f << YAML.dump(file_data)
    end
  end
  puts "Changes for: #{cur[:repo]}/#{cur[:chart]} #{cur[:name]}"
  puts "```diff"
  puts `diff .tmp/prev .tmp/cur`
  puts "```"
end

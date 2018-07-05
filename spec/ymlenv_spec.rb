require "open3"

File.write("spec/files/example2.yaml", File.read("spec/files/example1.yaml"))

test_cases = [
  {
    command: %q(bundle exec ymlenv spec/files/example1.yaml),
    result: File.read("spec/files/result1.yaml")
  },
  {
    command: %q(YMLENV_ENVIROMENT_TEST_VALUE=test3 bundle exec ymlenv spec/files/example1.yaml),
    result: File.read("spec/files/result2.yaml")
  },
  {
    command: %q(bundle exec ymlenv < spec/files/example1.yaml),
    result: File.read("spec/files/result1.yaml")
  },
  {
    command: %q(YMLENV_ENVIROMENT_TEST_VALUE=test3 bundle exec ymlenv < spec/files/example1.yaml),
    result: File.read("spec/files/result2.yaml")
  },
  {
    command: %q(cat spec/files/example1.yaml | bundle exec ymlenv),
    result: File.read("spec/files/result1.yaml")
  },
  {
    command: %q(cat spec/files/example1.yaml | YMLENV_ENVIROMENT_TEST_VALUE=test3 bundle exec ymlenv),
    result: File.read("spec/files/result2.yaml")
  },
  {
    command: %q(bundle exec ymlenv --json spec/files/example1.yaml),
    result: File.read("spec/files/result1.json")
  },
  {
    command: %q(YMLENV_ENVIROMENT_TEST_VALUE=test3 bundle exec ymlenv --json spec/files/example1.yaml),
    result: File.read("spec/files/result2.json")
  },
  {
    command: %q(bundle exec ymlenv -i spec/files/example2.yaml),
    result_files: ["spec/files/example2.yaml", "spec/files/result1.yaml"]
  },
]


errs = []
test_cases.each do |test|
  stdout, stderr, stcode = Open3.capture3 test[:command]
  if !test[:result_files].nil? && File.read(test[:result_files][0]) == File.read(test[:result_files][1])
    print "."
  elsif stdout == test[:result]
    print "."
  else
    print "x"
    errs.push({
      command: test[:command],
      expect: test[:result],
      stdout: stdout,
      stderr: stderr,
      status: stcode
    })
  end
end

puts
puts

if errs.empty?
  puts "Success!"
else
  errs.each do |err|
    puts <<-EOS
Case: #{err[:command]}
  expect: #{err[:expect]}
  result: #{err[:stdout]}#{"\n#{err[:stderr]}" unless err[:stderr].empty?}

    EOS
  end
  puts
  puts "Faild #{errs.count} case."
  exit 1
end



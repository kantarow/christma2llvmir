require_relative './compiler'

compiler = Compiler.new

program = ARGV[0] || $stdin.read

puts compiler.make_ir(program)

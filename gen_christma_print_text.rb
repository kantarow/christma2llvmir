require_relative './compiler'
require_relative './instruction'

bytes = (ARGV[0] + "\n").bytes

inst_to_char = Compiler::MAPPING_TABLE.invert

bytes.each_with_index do |b, i|
  puts inst_to_char[Instruction::INC_VAL] * b
  puts inst_to_char[Instruction::INC_PTR] unless i == bytes.length - 1
end

puts inst_to_char[Instruction::DEC_PTR] * (bytes.length - 1)
puts (inst_to_char[Instruction::WRITE] + inst_to_char[Instruction::INC_PTR]) * bytes.length

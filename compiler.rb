# frozen_string_literal: true

require_relative './ir_generator'
require_relative './instruction'

class Compiler
  MAPPING_TABLE = {
    'C' => Instruction::INC_PTR,
    'H' => Instruction::DEC_PTR,
    'R' => Instruction::INC_VAL,
    'I' => Instruction::DEC_VAL,
    'S' => Instruction::WRITE,
    'T' => Instruction::READ,
    'M' => Instruction::START_LOOP,
    'A' => Instruction::END_LOOP
  }.freeze

  def initialize
    @assign_index = 4
    @result = ''
    @generator = IRGenerator.new
  end

  def make_ir(program)
    formatted_program = program.gsub(/\s/, '').gsub(/\n/, '')

    @result += IRGenerator::PROLOGUE

    formatted_program.each_char do |token|
      @result += @generator.generate(MAPPING_TABLE[token])
    end

    @result += IRGenerator::EPILOGUE
  end
end

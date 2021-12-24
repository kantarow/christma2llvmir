require_relative './instruction'

class IRGenerator
  PROLOGUE = <<-"PROLOGUE".freeze
; ModuleID = 'christma.c'
source_filename = "christma.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
%1 = alloca i8*, align 8
%2 = alloca i8*, align 8
%3 = call noalias i8* @calloc(i64 1, i64 30000) #3
store i8* %3, i8** %1, align 8
store i8* %3, i8** %2, align 8
PROLOGUE

  EPILOGUE = <<-"EPILOGUE".freeze
%PTR = load i8*, i8** %2, align 8
call void @free(i8* %PTR)
ret i32 0
}

; Function Attrs: nounwind
declare dso_local noalias i8* @calloc(i64, i64) #1

declare dso_local i32 @getchar() #2

declare dso_local i32 @putchar(i32) #2

; Function Attrs: nounwind
declare dso_local void @free(i8*) #1

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}
EPILOGUE

  def initialize
    @assign_count = 3
  end

  def generate(instruction)
    case instruction
    when Instruction::INC_PTR
      result = "%#{@assign_count+1} = load i8*, i8** %1, align 8\n%#{@assign_count+2} = getelementptr inbounds i8, i8* %#{@assign_count+1}, i32 1\nstore i8* %#{@assign_count+2}, i8** %1, align 8\n"
      @assign_count += 2
      result
    when Instruction::DEC_PTR
      result = "%#{@assign_count+1} = load i8*, i8** %1, align 8\n%#{@assign_count+2} = getelementptr inbounds i8, i8* %#{@assign_count+1}, i32 -1\nstore i8* %#{@assign_count+2}, i8** %1, align 8\n"
      @assign_count += 2
      result
    when Instruction::INC_VAL
      result = "%#{@assign_count+1} = load i8*, i8** %1, align 8\n%#{@assign_count+2} = load i8, i8* %#{@assign_count+1}, align 1\n%#{@assign_count+3} = add i8 %#{@assign_count+2}, 1\nstore i8 %#{@assign_count+3}, i8* %#{@assign_count+1}, align 1\n"
      @assign_count += 3
      result
    when Instruction::DEC_VAL
      result = "%#{@assign_count+1} = load i8*, i8** %1, align 8\n%#{@assign_count+2} = load i8, i8* %#{@assign_count+1}, align 1\n%#{@assign_count+3} = add i8 %#{@assign_count+2}, -1\nstore i8 %#{@assign_count+3}, i8* %#{@assign_count+1}, align 1\n"
      @assign_count += 3
      result
    when Instruction::WRITE
      result = "%#{@assign_count+1} = load i8*, i8** %1, align 8\n%#{@assign_count+2} = load i8, i8* %#{@assign_count+1}, align 1\n%#{@assign_count+3} = sext i8 %#{@assign_count+2} to i32\n%#{@assign_count+4} = call i32 @putchar(i32 %#{@assign_count+3})\n"
      @assign_count += 4
      result
    when Instruction::READ
      result = "%#{@assign_count+1} = call i32 @getchar()\n%#{@assign_count+2} = trunc i32 %#{@assign_count+1} to i8\n%#{@assign_count+3} = load i8*, i8** %1, align 8\nstore i8 %#{@assign_count+2}, i8* %#{@assign_count+3}, align 1\n"
      @assign_count += 3
      result
    when Instruction::START_LOOP
      result = "#{@assign_count+1}:\n%#{@assign_count+2} = load i8*, i8** %1, align 8\n%#{@assign_count+3} = load i8, i8* %#{@assign_count+2}, align 1\n%#{@assign_count+4} = icmp ne i8 %#{@assign_count+3}, 0\nbr i1 %#{@assign_count+4}, label %#{@assign_count+5}, label %#{@assign_count+6}\n#{@assign_count+6}:"
      @start_of_loop = @assign_count + 1
      @next_to_loop = @assign_count + 6
      @assign_count += 6
      result
    when Instruction::END_LOOP
      "br label %#{@start_of_loop}\n#{@next_to_loop}:\n"
    else
      raise "unexpected instruction"
    end
  end
end

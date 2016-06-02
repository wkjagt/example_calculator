Calculator = Module.new

class Calculator::Tokenizer
  VALID_TOKENS = %w{- + / * ( )}

  def initialize(calculation)
    @calculation = "#{calculation} "
    @current_operand = ""
    @tokens = []
  end

  def tokenize
    @calculation.each_char do |char|
      if is_numeric?(char)
        @current_operand << char
        next
      end
      append_operand
      @tokens << char if is_valid_token?(char)
    end
    @tokens
  end

  private

  def append_operand
    return if @current_operand == ""

    @tokens << @current_operand
    @current_operand = ""
  end

  def is_numeric?(char)
    char =~ /\d/
  end

  def is_valid_token?(char)
    VALID_TOKENS.include?(char)
  end
end

class Calculator::Parser
  PRECEDENCE = %w{* / + -}

  def parse(tokens)
    PRECEDENCE.each do |operator|
      expressions = []
      while token = tokens.shift
        expressions << if token == operator
          [expressions.pop, token, tokens.shift]
        else
          token
        end
      end
      tokens = expressions
    end
    tokens.first
  end
end

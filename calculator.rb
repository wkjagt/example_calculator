class Calculator

  def calculate(calculation)
    tokens = Tokenizer.new(calculation).tokenize
    ast = Parser.new.parse(tokens)

    calculate_parsed(ast)
  end

  def calculate_parsed(ast)
    left, operator, right = ast
    reduce(left).public_send(operator, reduce(right))
  end

  def reduce(operand)
    operand = calculate_parsed(operand) if operand.is_a?(Array)
    operand.to_i
  end
end

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
        next expressions << parse(tokens) if token == "("
        return expressions if token == ")"

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

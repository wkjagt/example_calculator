class Calculator
  def initialize
    @tokenizer = Tokenizer.new
    @parser = Parser.new
  end

  def calculate(calculation)
    tokens = @tokenizer.tokenize(calculation)
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

  def tokenize(calculation)
    current_operand = ""
    tokens = []

    "#{calculation} ".each_char do |char|
      if is_numeric?(char)
        current_operand << char
        next
      elsif current_operand != ""
        tokens << current_operand
        current_operand = ""
      end

      tokens << char if is_valid_token?(char)
    end
    tokens
  end

  private

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
          right = tokens.shift
          if right == "("
            [expressions.pop, token, parse(tokens)]
          else
            [expressions.pop, token, right]
          end
        else
          token
        end
      end
      tokens = expressions
    end

    tokens.first
  end
end

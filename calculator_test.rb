require "minitest/autorun"
require "./calculator"

class TokenizerTest < Minitest::Test
  def setup
    @tokenizer = Calculator::Tokenizer.new
  end

  def test_tokenize_simple
    calculation = "4*5"
    expected = [
      "4",
      "*",
      "5"
    ]
    assert_equal expected, @tokenizer.tokenize(calculation)
  end

  def test_tokenizer_resets_itself
    calculation = "4*5"
    @tokenizer.tokenize(calculation)

    expected = [
      "4",
      "*",
      "5"
    ]
    assert_equal expected, @tokenizer.tokenize(calculation)
  end

  def test_tokenize_longer_operands
    calculation = "400*500"
    expected = [
      "400",
      "*",
      "500"
    ]
    assert_equal expected, @tokenizer.tokenize(calculation)
  end

  def test_tokenize_simple_with_spaces
    calculation = "4 * 5"
    expected = [
      "4",
      "*",
      "5"
    ]
    assert_equal expected, @tokenizer.tokenize(calculation)
  end

  def test_tokenize_simple_with_parens
    calculation = "(4 * 5)"
    expected = [
      "(",
      "4",
      "*",
      "5",
      ")",
    ]
    assert_equal expected, @tokenizer.tokenize(calculation)
  end

  def test_tokenize_complex
    calculation = "( 4 + 5 ) / ( ( 6 + 1 ) + 1 )"
    expected = %w{( 4 + 5 ) / ( ( 6 + 1 ) + 1 )}
    assert_equal expected, @tokenizer.tokenize(calculation)
  end

  def test_tokenize_complex2
    calculation = "( 4 + 5 ) * ( ( 6 + 1 ) + 1 )"
    expected = %w{( 4 + 5 ) * ( ( 6 + 1 ) + 1 )}
    assert_equal expected, @tokenizer.tokenize(calculation)
  end

  def test_tokenize_complex3
    calculation = "((104+4)*5)+65+6*5+(48+234)"
    expected = %w{( ( 104 + 4 ) * 5 ) + 65 + 6 * 5 + ( 48 + 234 )}
    assert_equal expected, @tokenizer.tokenize(calculation)
  end
end

class ParserTest < Minitest::Test
  def setup
    @parser = Calculator::Parser.new
  end

  def test_simple
    tokens = %w{4 * 5 - 6}
    expected = [
      [
        "4",
        "*",
        "5"
      ],
      "-",
      "6"
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_simple2
    tokens = %w{4 + 5 * 6}
    expected = [
      "4",
      "+",
      [
        "5",
        "*",
        "6"
      ]
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_simple3
    tokens = %w{4 + 5 / 6}
    expected = [
      "4",
      "+",
      [
        "5",
        "/",
        "6"
      ]
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_multiple
    tokens = %w{4 * 5 / 6}
    expected = [
      [
        "4",
        "*",
        "5"
      ],
      "/",
      "6"
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_complex
    tokens = %w{5 * 4 - 4 / 9 + 1 + 2 / 2 * 6}
    expected = [
      [
        "5",
        "*",
        "4"
      ],
      "-",
      [
        [
          [
            "4",
            "/",
            "9"
          ],
          "+",
          "1"
        ],
        "+",
        [
          "2",
          "/",
          [
            "2",
            "*",
            "6"
          ]
        ]
      ]
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_parens
    tokens = %w{( 4 + 5 ) / 6}
    expected = [
      [
        "4",
        "+",
        "5"
      ],
      "/",
      "6"
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_parens_complex
    tokens = %w{( 4 + 5 ) / ( 6 + 1 )}
    expected = [
      [
        "4",
        "+",
        "5"
      ],
      "/",
      [
        "6",
        "+",
        "1"
      ]
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_parens_complex2
    tokens = %w{( 4 + 5 ) / ( ( 6 + 1 ) + 1 )}
    expected = [
      [
        "4",
        "+",
        "5"
      ],
      "/",
      [
        [
          "6",
          "+",
          "1"
        ],
        "+",
        "1"
      ]
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_parens_complex3
    tokens = %w{( 4 + 5 ) * ( ( 6 + 1 ) + 1 )}
    expected = [
      [
        "4",
        "+",
        "5"
      ],
      "*",
      [
        [
          "6",
          "+",
          "1"
        ],
        "+",
        "1"
      ]
    ]
    assert_equal expected, @parser.parse(tokens)
  end

  def test_outermost_parens_dont_add_a_level
    tokens = %w{( ( ( ( 1 + 3 ) ) ) )}
    expected = ["1", "+", "3"]
    assert_equal expected, @parser.parse(tokens)
  end
end

class CalculatorTest < Minitest::Test
  def setup
    @calculator = Calculator.new
  end

  def test_simple
    ast = ["4", "*", "5"]
    expected = 20
    assert_equal expected, @calculator.calculate_parsed(ast)
  end

  def test_with_expressions
    ast = [["4", "*", "5" ], "-", ["6", "*", "2"]]
    expected = 8

    assert_equal expected, @calculator.calculate_parsed(ast)
  end

  def test_complex
    ast = [
      [
        "4",
        "+",
        "5"
      ],
      "*",
      [
        [
          "6",
          "+",
          "1"
        ],
        "+",
        "1"
      ]
    ]
    expected = 72
    assert_equal expected, @calculator.calculate_parsed(ast)
  end

  def test_complete
    calculation = "( 4 + 5 ) + ( ( 6 + 1 ) + 1 )"

    assert_equal 17, @calculator.calculate(calculation)
  end

  def test_complete2
    calculation = "( 4 + 5 ) * ( ( 6 + 1 ) + 1 )"

    assert_equal 72, @calculator.calculate(calculation)
  end

  def test_complete3
    calculation = "((104+4)*5)+65+6*5+(48+234)"

    assert_equal 917, @calculator.calculate(calculation)
  end
end

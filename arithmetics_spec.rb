require_relative 'arithmetics'

describe "Test helper methods" do
  it 'should reconize operators' do
    evaluator = Bobo::ArithmeticEvaluator.new 'a+b'
    expect(evaluator.is_operator?('+')).to be true
    expect(evaluator.is_operator?('-')).to be true
    expect(evaluator.is_operator?('*')).to be true
    expect(evaluator.is_operator?('/')).to be true
    expect(evaluator.is_operator?('a')).to be false
  end

  it 'should tokenize correctly' do
    expect(Bobo::ArithmeticEvaluator.tokenize('1+2')).to eql(['1', '+', '2'])
    expect(Bobo::ArithmeticEvaluator.tokenize('1+2*65/87')).to eql(['1', '+', '2', '*', '65', '/', '87'])
  end
end

describe "Test #to_postfix method" do

  it "returns 'ab+' for 'a+b'" do
    evaluator = Bobo::ArithmeticEvaluator.new 'a+b'
    expect(evaluator.to_postfix_str).to eql('a b +')
  end

  it "returns '5 3 * 6 +' for '5 * 3+6'" do
    evaluator = Bobo::ArithmeticEvaluator.new '5 * 3+6'
    expect(evaluator.to_postfix_str).to eql('5 3 * 6 +')
  end

  it "returns '5 3 * 6 7 * +' for '5 * 3+6*7'" do
    evaluator = Bobo::ArithmeticEvaluator.new '5 * 3+6*7'
    expect(evaluator.to_postfix_str).to eql('5 3 * 6 7 * +')
  end

  it "returns '5 3 * 6 7 * 987 * +' for '5 * 3+6*7*987'" do
    evaluator = Bobo::ArithmeticEvaluator.new '5 * 3+6*7'
    expect(evaluator.to_postfix_str).to eql('5 3 * 6 7 * +')
  end

  it "returns '5 3 + 6 7 * 987 * +' for '5 + 3+6*7*987'" do
    evaluator = Bobo::ArithmeticEvaluator.new '5 * 3+6*7'
    expect(evaluator.to_postfix_str).to eql('5 3 * 6 7 * +')
  end
end

describe "Test #evaluate method" do
  it "returns '41462' for '5 + 3+6*7*987'" do
    evaluator = Bobo::ArithmeticEvaluator.new '5 + 3+6*7*987'
    expect(evaluator.evaluate).to eq(41462)
  end

  it "returns '21' for '5 * 3+6'" do
    evaluator = Bobo::ArithmeticEvaluator.new '5 * 3+6'
    expect(evaluator.evaluate).to eq(21)
  end

  it "returns '3' for '5 + 1+2'" do
    evaluator = Bobo::ArithmeticEvaluator.new '1 + 2'
    expect(evaluator.evaluate).to eq(3)
  end
end

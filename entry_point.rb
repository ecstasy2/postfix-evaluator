require 'rubygems' 
require 'bundler/setup'

require_relative 'arithmetics'

begin
  print "Expression to evaluate ('quit' to exit): "
  expression =  gets

  evaluator = Bobo::ArithmeticEvaluator.new expression
  puts "The result is : #{evaluator.evaluate}"
  puts "\n\n"
  

end while expression != 'quit'
module Bobo
  class ArithmeticEvaluator

    # We keep track of the list of operator we support, their precedence 
    # and a list of evaluator Proc that are colled to perform the operation
    # OPTIMIZE We could improve this in the future to have a data structure representing all 
    # => that boilplate code. This would allows us to easily add new kind of operator (think of a%b) 
    @@operators = ['+', '-', '*', '/']
    @@operators_order = Hash['+' => 0, '-' => 0, '*' => 1, '/' => 1]
    @@operators_eval = Hash[
      '+' => Proc.new {|a, b| a + b}, 
      '-' => Proc.new {|a, b| a - b},
      '*' => Proc.new {|a, b| a * b}, 
      '/' => Proc.new {|a, b| a / b}]

    # Construct an ArithmeticEvaluator for the passed expression
    def initialize expression
      @expression = expression.strip # Strip the expression to normalize it

      # TODO We should ensure that the expression is valid ad this point or raise
      # => an error probably?
      # => not requested by the assignment so WONTFiX
    end

    # Main api for the evaluator, call this method on a ArithmeticEvaluator and it will
    # return a +Float+ representing the result
    #
    # For evaluation we proceed as follow:
    #
    #  * Tokenize the passed expression
    #  * Convert the token into a +postfix+ or +Reverse Polish+ form : See http://en.wikipedia.org/wiki/Reverse_Polish_notation
    #  * Evaluate the +postfix+ expression using a simple stack 
    def evaluate
      postfix = to_postfix
      stack = Array.new

      # All operators are binary so it is quite easy
      postfix.each do |token|
        # If the current token is not an operator just push it in the stack
        stack.push token unless is_operator? token

        # If it is an operator we just evaluate it and push the result back
        # to the stack
        if is_operator? token
          operand_a = stack.pop.to_f
          operand_b = stack.pop.to_f
          result = @@operators_eval[token].call(operand_a, operand_b)
          stack.push result
        end
      end

      # When all token have been processed we should have only one item
      # in the stack. This item is the result

      stack.pop
    end

    # Convert and return +@expression+ to postfix representation
    #
    # For a complete explanation on how to convert an infix notation to postfix
    # refere to : http://scriptasylum.com/tutorials/infix_postfix/algorithms/infix-postfix/
    #
    # ==== Examples
    #
    #   a+b*c-d => ['a', 'b', 'c', '*', '+', 'd', '-']
    #   a+b     => ['a', 'b', '+']
    def to_postfix
      stack = Array.new
      postfix_string = Array.new

      ArithmeticEvaluator.tokenize(@expression).each do |chr|
        # We append any non operator token to the final postfix string
        postfix_string << chr unless is_operator? chr

        # Only relevant if it is an operator
        if is_operator? chr
          # If the stack is empty we just push the operator and continue
          if stack.empty?
            stack.push chr
          else
            # We should never push a lower precedence operator on top of a higher precedence one.
            # So we keep this logic in that purpose
            until stack.empty?
              if compare_operator(stack.last, chr) > 0
                postfix_string << stack.pop
                if stack.empty?
                  stack.push chr
                  break
                end
              elsif compare_operator(stack.last, chr) == 0
                postfix_string << stack.pop
                stack.push chr
                break
              else
                stack.push chr
                break
              end
            end
          end
        end
      end

      # If we have scanned all the token and we still have operator in the 
      # stack we just append them to the postfix representation
      until stack.empty?
        postfix_string << stack.pop
      end
      
      postfix_string
    end

    # A helper method to return a string representation of the postfix expression
    def to_postfix_str
      to_postfix.join(' ')
    end

    # Tokenize an arithmethic expression into tokens
    #
    # ========== Examples
    #
    #  1+2 => ["1", "+", "2"]
    #
    # Return an array of all the tokens constituting this expression
    def self.tokenize expression
      result = Array.new
      regex = Regexp.new("([#{@@operators.join('\\')}])")
      expression.gsub(regex, ' \1 ').split
    end

    # Compare operator op1 to op2
    # * Return _1_ if op1 > op2
    # * Return _-1_ if op1 < op2
    # * Return _0_ if op1 == op2
    def compare_operator op1, op2
      if @@operators_order[op1] < @@operators_order[op2]
        return -1;
      elsif @@operators_order[op1] > @@operators_order[op2]
        return 1;
      else
        return 0;
      end
    end

    # Helper method to test if a string is an operator
    def is_operator? param
      @@operators.include? param
    end
  end
end

require 'ruby2d'

# Unique features:
# Dynamic list with mixes of types
# blocking: https://mixandgo.com/learn/ruby/blocks
# regular expressions: https://www.rubyguides.com/2015/06/ruby-regex/
# built in hash tables: https://www.digitalocean.com/community/tutorials/understanding-data-types-in-ruby
# duck typing https://www.codingninjas.com/studio/library/type-checking-and-duck-typing-in-ruby
# dynamic array instead of fixed: https://www.learnenough.com/blog/ruby-array#Ruby%20array%20uses%20and%20applications

set title: "Blackjack", background: 'grey', resizable: true

class Game
	def initialize


	end
end


class Card
	# attribute features in ruby that creates getter methods so we can easily change them:
	# https://medium.com/@rossabaker/what-is-the-purpose-of-attr-accessor-in-ruby-3bf3f423f573#:~:text=to%20help%20out.-,attr_reader,color%20%23%20%3C%2D%2D%20Getter%20methods
	attr_reader :rank, :suit
	def initialize (rank, suit)
		@rank = rank
		@suit = suit
	end


end

class Deck
	attr_reader :cards
	def initialize


	end

end

class User
	attr_reader :hand
	def initialize


	end

	def start_game

	end
end


game = Game.new
game.start_game
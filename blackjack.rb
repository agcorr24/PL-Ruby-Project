require 'ruby2d'

# Unique features:
# Dynamic list: cards list 
# list with mixes of types: player status
# blocking: https://mixandgo.com/learn/ruby/blocks: player and dealer turns
# regular expressions: https://www.rubyguides.com/2015/06/ruby-regex/
# built in hash tables: https://www.digitalocean.com/community/tutorials/understanding-data-types-in-ruby
# duck typing https://www.codingninjas.com/studio/library/type-checking-and-duck-typing-in-ruby
# dynamic array instead of fixed: https://www.learnenough.com/blog/ruby-array#Ruby%20array%20uses%20and%20applications

set title: "Blackjack", background: 'gray', resizable: true

class Game
	def initialize(player)
		@deck = Deck.new
		@deck.shuffle_deck
		@player = User.new(player)
		@dealer = Dealer.new
	end
	# mixes of types, method to add to it
	def add_player_status(object)
		@status << object
	end
	def deal_cards_initially
		2.times do #two cards so do it twice
			@player.add_card(@deck.draw)
			@dealer.add_card(@deck.draw)
		end
	end

	#blocking
	#https://medium.com/rubycademy/the-yield-keyword-603a850b8921
	def player_turn(&block)
		yield if block_given?
	end

	def dealer_turn(&block)
		yield if block_given?
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
		@cards = [] # dynamic list
		#https://stackoverflow.com/questions/4064062/space-in-the-ruby-array-by-w
		%w(Hearts Diamonds Clubs Spades).each do |suit|
			%w(2 3 4 5 6 7 8 9 10 J Q K A).each do |rank|
				@cards << Card.new(rank, suit)
			end
		end
	end
	#can access by deck = Deck.new and cards = deck.cards, can do cards.length
	def shuffle_deck
		# ruby has a shuffle method
		@cards.shuffle!
		#shuffled_cards = deck.cards
	end
	def draw
		@cards.pop
	end
end

class User
	attr_reader :player_hand, :name
	def initialize(name)
		@name = name
		@player_hand = []
	end

	def start_game

	end

	def add_card(card)
		@player_hand << card
	end
end

class Dealer
	attr_reader :dealer_hand
	def initialize
		@dealer_hand = []
	end
	def add_card(card)
		@dealer_hand << card
	end


end

game = Game.new("Player") # new game
game.deal_cards_initially # do initial dealing

#blocking
game.player_turn do
	#
end
game.dealer_turn do
	#
end


#show window
Image.new("blackjack-table.png", x: 80, y:80, width:450, height: 350, z:1)
Image.new("blankcard.png", x: 250, y:320, width: 100, height: 150, z:5)
show
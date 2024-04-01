	require 'ruby2d'

	# Unique features:
	# Dynamic list(doesn't have to be fixed): https://www.learnenough.com/blog/ruby-array#Ruby%20array%20uses%20and%20applications
			# CARDS, STATUS
	# list with mixes of types: PLAYER STATUS
	# blocking: https://mixandgo.com/learn/ruby/blocks: PLAYER AND DEALER TURNS
	# regular expressions: https://www.rubyguides.com/2015/06/ruby-regex/: RECOGNIZING BLACKJACK, password to start game, allows to cheat
	# built in hash tables: https://www.digitalocean.com/community/tutorials/understanding-data-types-in-ruby
			# CARDS
	# duck typing https://www.codingninjas.com/studio/library/type-checking-and-duck-typing-in-ruby


	# Setting up window & background
	set title: "Blackjack", background: 'gray', resizable: true
	Image.new("blackjack-table.png", x: 80, y:80, width:450, height: 350, z:1)

	# Blank card to display shuffled cards
	Image.new("blankcard.png", x: 255, y:320, width: 100, height: 150, z:5)
	Image.new("blankcard.png", x: 280, y:20, width: 50, height: 75, z:5)

	
	song = Music.new('musicloop.mp3') #https://www.ruby2d.com/learn/audio/
	song.loop = true
	song.volume = 50
	#song.play
	shuffle = Sound.new('cardshuffle.wav')
	deal = Sound.new('dealcard.wav')
	play = Sound.new('playcard.mp3')
	shuffle.play


	# Create text objects for displaying card information
	text_player_card = Text.new("", x: 255, y: 320, size: 20, color: 'white')
	text_dealer_card = Text.new("", x: 280, y: 20, size: 20, color: 'white')

	# Game class
	class Game
		def initialize(player, text_player_card, text_dealer_card)
			@deck = Deck.new
			@player = User.new(player)
			@dealer = Dealer.new
			@text_player_card = text_player_card
			@text_dealer_card = text_dealer_card
		end
	
		public
		def player_turn(&block)
			yield if block_given?
		end
	
		def dealer_turn(&block)
			yield if block_given?
		end
	
		def deal_cards_initially
			player_card = @deck.draw
			dealer_card = @deck.draw
		
			update_card_text(@text_player_card, player_card)
			update_card_text(@text_dealer_card, dealer_card)
		end
	
		private
		def update_card_text(text_object, card)
			suit_icons = {
				"Hearts" => "♥",
				"Diamonds" => "♦",
				"Clubs" => "♣",
				"Spades" => "♠"
			}
			text_object.text = "Card: #{card.rank} #{suit_icons[card.suit]}"
		end
	end # end game


		#blocking
		#https://medium.com/rubycademy/the-yield-keyword-603a850b8921
		def player_turn(&block)
			yield if block_given?
		end

		def dealer_turn(&block)
			yield if block_given?
		end

		# regular expression and mapping
		def check_for_blackjack(player)
			#
		end
	#end


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
			@cards = {} #hashtable
			#https://stackoverflow.com/questions/4064062/space-in-the-ruby-array-by-w
			%w(Hearts Diamonds Clubs Spades).each do |suit|
				%w(2 3 4 5 6 7 8 9 10 J Q K A).each do |rank|
					card = Card.new(rank, suit)
					@cards["#{rank} of #{suit}"] = card
				end
			end
		end

		# returning a random card from the hashtable
		def draw
			key = @cards.keys.sample
		card = @cards[key]
		@cards.delete(key) #remove from deck when drawn
		card
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


	# Initialize and deal cards for the game
	game = Game.new("Player", text_player_card, text_dealer_card)
	game.deal_cards_initially

	# Show the window
	show

#	game = Game.new("Player") # new game
	#game.deal_cards_initially # do initial dealing

	#blocking
#	game.player_turn do
		#
#	game.dealer_turn do
#		#
#	end


	#show window
	#show

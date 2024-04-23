# Andrea Correia, Fran Gallagher, Rose Stefanidakis 
# CSCI324 Term Project
# blackjack.rb

# Unique features: dynamic list, blocking, regular expressions, built in hash tables, duck typing 

require 'ruby2d'

# window & background
set title: "Blackjack", background: 'gray', resizable: true
Image.new("blackjack-table.png", x: 80, y:80, width:450, height: 350, z:1)

# for dealer
dealer_card1 = Image.new("blankcard.png", x: 250, y: 20, width: 50, height: 75, z: 5)
dealer_card2 = Image.new("blankcard.png", x: 310, y: 20, width: 50, height: 75, z: 5)

# for player
player_card1 = Image.new("blankcard.png", x: 190, y: 320, width: 100, height: 150, z: 5)
player_card2 = Image.new("blankcard.png", x: 310, y: 320, width: 100, height: 150, z: 5)

    
# sound effects
song = Music.new('musicloop.mp3') #https://www.ruby2d.com/learn/audio/
song.loop = true
song.volume = 10
shuffle = Sound.new('cardshuffle.wav')
shuffle.play
song.play

# text objects for displaying card info
# for dealer
text_dealer_card1 = Text.new("", x: 250, y: 20, z: 6, size: 20, color: 'black') 
text_dealer_card2 = Text.new("", x: 310, y: 20, z: 6, size: 20, color: 'black')

# for player
text_player_card1 = Text.new("", x: 190, y: 320, z: 6, size: 40, color: 'black') 
text_player_card2 = Text.new("", x: 310, y: 320, z: 6, size: 40, color: 'black')

# for card values
text_player_total = Text.new("", x: 30, y: 360, size: 20, color: 'white', z: 10)
text_dealer_total = Text.new("", x: 470, y: 50, size: 20, color: 'white', z: 10)

# initialize an empty array for player_card_texts
player_card_texts = []

# Game class
class Game
    # intiialize game, player, dealer, and text boxes for card values
    def initialize(player, text_player_card1, text_player_card2, text_dealer_card1, text_dealer_card2, text_player_total, text_dealer_total, player_card_texts)
        @deck = Deck.new
        @player = User.new(player)
        @dealer = Dealer.new
        @text_player_card1 = text_player_card1
        @text_player_card2 = text_player_card2
        @text_dealer_card1 = text_dealer_card1
        @text_dealer_card2 = text_dealer_card2
        @text_player_total = text_player_total
        @text_dealer_total = text_dealer_total
        @player_card_texts = player_card_texts
        @initial_deal_completed = false
        @blackjack_occurred = false

        # initialize dealer card 2 text with empty string
        text_dealer_card2.remove
        @suit_icons = {
            "Hearts" => "♥",
            "Diamonds" => "♦",
            "Clubs" => "♣",
            "Spades" => "♠"
        }
    end

    # only shuffles at beginning - initial deal
    def deal_cards_initially
        return if @initial_deal_completed
        2.times do
            player_card = @deck.draw
            dealer_card = @deck.draw

            @player.add_card(player_card)
            # initial deal for player
            update_card_text(@text_player_card1, player_card) if @player.player_hand.size == 1
            update_card_text(@text_player_card2, player_card) if @player.player_hand.size == 2

            @dealer.add_card(dealer_card)
            # initial deal for dealer
            update_card_text(@text_dealer_card1, dealer_card) if @dealer.dealer_hand.size == 1
            update_card_text(@text_dealer_card2, dealer_card) if @dealer.dealer_hand.size == 2
        end
        update_player_total
        @initial_deal_completed = true
    end

    # if player wants to add another card to their sum
    def hit
        return unless @initial_deal_completed && !@blackjack_occurred
        return if @player.total > 21  # prevent hitting if player's total exceeds 21
        new_card = @deck.draw
        @player.add_card(new_card)
				deal = Sound.new('dealcard.wav')
				deal.play
        x_offset = 200 
        y_offset = 320  # initial y-coordinate for the first additional card
        vertical_spacing = 130  # vertical spacing between cards
        horizontal_spacing = 10 


        # Calculate the y-coordinate for the new card with spacing
        next_card_y = @player_card_texts.empty? ? y_offset : @player_card_texts.last.y - vertical_spacing

        # Create and add the new card rectangle
        player_card_rect = Rectangle.new(
            x: @text_player_card2.x + x_offset,
            y: next_card_y,
            width: 70,
            height: 100,
            color: 'white',
            z: 6,
        )
        player_card_rect.add

        # Create and add the new card text object
        player_card_text = Text.new(
            "#{new_card.rank} #{@suit_icons[new_card.suit]}",
            x: player_card_rect.x + 10,
            y: player_card_rect.y + 10,
            z: 7,
            size: 20,
            color: 'black'
        )
        player_card_text.add

        @player_card_texts << player_card_text

        update_player_total

        # check for blackjack
        check_for_blackjack(@player)
    end

    def create_player_card(card, x_offset, y_offset)
        # create additional player card rectangle
        player_card_rect = Rectangle.new(
            x: @text_player_card2.x + x_offset, # position it to the right of player_card2
            y: y_offset,
            width: 70,
            height: 100, 
            color: 'white', 
            z: 6,
        )
        player_card_rect.add

        # update player's additional card text
        player_card_text = Text.new("", x: player_card_rect.x + 10, y: player_card_rect.y + 10, z: 7, size: 20, color: 'black')
        player_card_text.text = "#{card.rank} #{@suit_icons[card.suit]}"
        @player_card_texts << player_card_text

        update_player_total


        # check for blackjack
        check_for_blackjack(@player)
    end # end Hit

  
    # if player wants to keep current sum
    def stand
        return unless @initial_deal_completed

        dealer_turn
        update_dealer_total
        update_card_text(@text_dealer_card2, @dealer.dealer_hand.last) if @dealer.dealer_hand.size == 2
        @text_dealer_card2.add  # Add the text object to the window

        # Check for blackjack 
        check_for_blackjack(@player)

        # Check if dealer's total is greater than player's and closer to 21
        if @dealer.total > @player.total && @dealer.total <= 21
            Rectangle.new(x: 170, y: 170, width: 300, height: 100, color: 'white', z: 99)
						if @dealer.total == 21
							Text.new("Dealer got Blackjack. You lose!", x: 180, y: 200, size: 20, color: 'red', z: 100).add
						else
            	Text.new("Dealer is closer to 21! You lose!", x: 180, y: 200, size: 20, color: 'red', z: 100).add
						end
				# Check if player is closer to 21 
        elsif @player.total > @dealer.total && @player.total <= 21
					Rectangle.new(x: 170, y: 170, width: 300, height: 100, color: 'white', z: 99)
          Text.new("You are closer to 21! You win!", x: 180, y: 200, size: 20, color: 'red', z: 100).add
				# Check if dealer went over
				elsif @dealer.total > 21
						Rectangle.new(x: 170, y: 170, width: 300, height: 100, color: 'white', z: 99)
            Text.new("Dealer went over 21. You win!", x: 180, y: 200, size: 20, color: 'red', z: 100).add
				# Check if tie
				elsif @dealer.total == @player.total
						Rectangle.new(x: 170, y: 170, width: 300, height: 100, color: 'white', z: 99)
            Text.new("It's a tie! No one wins.", x: 180, y: 200, size: 20, color: 'red', z: 100).add
				end
    end # end stand

    private 
    
    # to display on text for player and dealer - card values and suites
    def update_card_text(text_object, card)
        card_text = "#{card.rank} #{@suit_icons[card.suit]}"
        text_object.text = card_text
    end

    #https://medium.com/rubycademy/the-yield-keyword-603a850b8921
    def player_turn(&block)
        yield if block_given?
    end

    def dealer_turn(&block)
       # while @dealer.total < 17
       #     dealer_hit
            yield if block_given? # yield to a block if provided
       #     update_dealer_total
       #   end
    end

    def dealer_hit
        new_card = @deck.draw
        @dealer.add_card(new_card)
				update_dealer_total
    end

    # update player's total based on the cards they have
    def update_player_total
        player_total_value = @player.total
        @text_player_total.text = "Total: #{player_total_value} "
    end

    # update dealer's total based on the cards they have
    def update_dealer_total
        dealer_total_value = @dealer.total
        @text_dealer_total.text = "Total: #{dealer_total_value} "
    end

    def check_for_blackjack(player)
        # mapping
        blackjack_map = {
        21 => "Blackjack! You win!",
        :bust => "Bust! You've exceeded 21.",
    }

        player_total = player.total

        message = player_total > 21 ? blackjack_map[:bust] : blackjack_map[player_total]
        
        if message
            Rectangle.new(x: 170, y: 170, width: 300, height: 100, color: 'white', z: 99)
            Text.new(message, x: 200, y: 200, size: 20, color: 'red', z: 100).add
        end
    end # end check_for_blackjack
    
end # end game


class Card
    # attribute features to create getter method
    # https://medium.com/@rossabaker/what-is-the-purpose-of-attr-accessor-in-ruby-3bf3f423f573#:~:text=to%20help%20out.-,attr_reader,color%20%23%20%3C%2D%2D%20Getter%20methods
    attr_reader :rank, :suit, :value
    
    def initialize(rank, suit)
        @rank = rank
        @suit = suit
        @value = calculate_value
    end

    # cards Jack, Queen, or King w/ value 10, Ace with either 1 or 11
    def calculate_value
        if ['J', 'Q', 'K'].include?(@rank)
            10
        elsif @rank == 'A'
            11
        else
            @rank.to_i
        end
    end
end # end Card

# Deck class
class Deck
    attr_reader :cards
    
    def initialize
        @cards = []
        # non-special cards/numerical cards keep their numerical value
        %w(Hearts Diamonds Clubs Spades).each do |suit|
            %w(2 3 4 5 6 7 8 9 10 J Q K A).each do |rank|
                card = Card.new(rank, suit)
                @cards << card
            end
        end
        shuffle_cards
    end
    
    def shuffle_cards
        @cards.shuffle!
    end
    
    def draw
        @cards.pop || Card.new("", "")
    end
end # end Deck
    
# User class
class User
    attr_reader :player_hand, :name
  
    def initialize(name)
        @name = name
        @player_hand = []
    end
  
    def total 
        player_total_value = 0
        aces_count = 0
    
        @player_hand.each do |card|
            player_total_value += card.value
            aces_count += 1 if card.rank == 'A'
        end
    
        while player_total_value > 21 && aces_count > 0
            player_total_value -= 10
            aces_count -= 1
        end
    
        player_total_value
    end
  
    def add_card(card)
        @player_hand << card
    end
end # end User  

# Dealer class
class Dealer
    attr_reader :dealer_hand
    
    def initialize
        @dealer_hand = []
    end

    def add_card(card)
        @dealer_hand << card
    end

    def total 
        dealer_total_value = 0
        aces_count = 0

        @dealer_hand.each do |card|
            dealer_total_value += card.value
            aces_count += 1 if card.rank == 'A'
        end

        # Adjust the total value for aces
        while dealer_total_value > 21 && aces_count > 0
            dealer_total_value -= 10
            aces_count -= 1
        end
        
        dealer_total_value
    end
end # end Dealer


# initialize/deal cards for the game
game = Game.new("Player", text_player_card1, text_player_card2, text_dealer_card1, text_dealer_card2, text_player_total, text_dealer_total, player_card_texts)

username = ""
valid = /\A[a-zA-Z0-9_]+\z/ # regular expression for username
cheat_pattern = /iwanttowin21/
game_started = false
prompt = Text.new("Enter a username!", x: 50, y:50, color:'white')

cheat_activated = false

on :key_down do |event|
	if event.key == "return"  # Check if the Enter key is pressed
		# Check if the username is valid
		if username.match?(valid)
			# Valid username
			prompt.remove  
			# Start the game with the entered username
			game_started = true
			Text.new(username, x: 50, y: 50, color: 'white')
		# Check if cheat pattern entered
		if username.match?(cheat_pattern)
				Window.clear
				Text.new("You win!")
		end
		end
	elsif event.key == "backspace"
		username = username[0..-2]
	elsif event.key.length == 1 && event.key.match?(valid) 
		username += event.key  
	end
end

# event listeners for keyboard input
on :key_down do |event|
	if game_started
    if event.key == "d" || event.key == "D"  # deal when 'd' or 'D' key is pressed
      game.deal_cards_initially
    elsif event.key == "h" || event.key == "H"  # hit when 'h' or 'H' key is pressed
      game.hit
    elsif event.key == "s" || event.key == "S"  # stand when 's' or 'S' key is pressed
      game.stand
    end
  end
end
  
# show window 
show

# TODO:
# 1. change rectangle to card display - andrea
# 2. regular expression for check for blackjack - rose 
# 3. CHECK UNIQUE FEATURES - all 
# 4. DOUBLE CHECK BLOCKING LOGIC - all 
# 5. comments and some syntax stuff - anyone 
# 6. CHECK CRITERIA IN PACKET TO DOUBLE CHECK WHATEVER I MISSED HERE ********* -- anyone
# 7. sounds ????? -- andrea ?
# 8. anything else ...... rose ?

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

# for dealer
dealer_card1 = Image.new("blankcard.png", x: 250, y: 20, width: 50, height: 75, z: 5)
dealer_card2 = Image.new("blankcard.png", x: 310, y: 20, width: 50, height: 75, z: 5)

# for player
player_card1 = Image.new("blankcard.png", x: 190, y: 320, width: 100, height: 150, z: 5)
player_card2 = Image.new("blankcard.png", x: 310, y: 320, width: 100, height: 150, z: 5)

    
# creating sound effects
song = Music.new('musicloop.mp3') #https://www.ruby2d.com/learn/audio/
song.loop = true
song.volume = 50
shuffle = Sound.new('cardshuffle.wav')
deal = Sound.new('dealcard.wav')
play = Sound.new('playcard.mp3')
shuffle.play

# Create text objects for displaying card information
# for dealer
text_dealer_card1 = Text.new("", x: 250, y: 20, z: 6, size: 20, color: 'black') 
text_dealer_card2 = Text.new("", x: 310, y: 20, z: 6, size: 20, color: 'black')

# for player
text_player_card1 = Text.new("", x: 190, y: 320, z: 6, size: 40, color: 'black') 
text_player_card2 = Text.new("", x: 310, y: 320, z: 6, size: 40, color: 'black')

# for card values
text_player_total = Text.new("", x: 30, y: 360, size: 20, color: 'white', z: 10)
text_dealer_total = Text.new("", x: 470, y: 50, size: 20, color: 'white', z: 10)

# initialize dealer card 2 text with empty string
#text_dealer_card2.remove

# Game class
class Game
    # intiialize game, player, dealer, and text boxes for card values
    def initialize(player, text_player_card1, text_player_card2, text_dealer_card1, text_dealer_card2, text_player_total, text_dealer_total)
        @deck = Deck.new
        @player = User.new(player)
        @dealer = Dealer.new
        @text_player_card1 = text_player_card1
        @text_player_card2 = text_player_card2
        @text_dealer_card1 = text_dealer_card1
        @text_dealer_card2 = text_dealer_card2
        @text_player_total = text_player_total
        @text_dealer_total = text_dealer_total
        @initial_deal_completed = false
        @blackjack_occurred = false

      # initialize dealer card 2 text with empty string
      text_dealer_card2.remove
    end
  
    # only shuffles at beginning - initial deal
    def deal_cards_initially
        return if @initial_deal_completed
        2.times do
            player_card = @deck.draw
            dealer_card = @deck.draw
      
            @player.add_card(player_card)
            # Initial deal for player
            update_card_text(@text_player_card1, player_card) if @player.player_hand.size == 1
            update_card_text(@text_player_card2, player_card) if @player.player_hand.size == 2
      
            @dealer.add_card(dealer_card)
            # Initial deal for dealer
            update_card_text(@text_dealer_card1, dealer_card) if @dealer.dealer_hand.size == 1
            update_card_text(@text_dealer_card2, dealer_card) if @dealer.dealer_hand.size == 1
          end
          update_player_total
          @initial_deal_completed = true
    end
  
    # if player wants to add another card to their sum
    def hit
        return unless @initial_deal_completed && !@blackjack_occurred
        return if @player.total > 21  # Prevent hitting if player's total exceeds 21
        new_card = @deck.draw
        @player.add_card(new_card) # Fixed reference to @player
        update_card_text(@text_player_card2, new_card) # Update the text for the new card

        update_player_total

        # Check for blackjack 
        check_for_blackjack(@player)
    end
  
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
          # Display a message
          Rectangle.new(x: 170, y: 170, width: 300, height: 100, color: 'white', z: 99)
          Text.new("Dealer is closer to 21! You lose!", x: 180, y: 200, size: 20, color: 'red', z: 100).add
        end
    end # end stand

    private 
    
    # to display on text for player and dealer - card values and suites
    def update_card_text(text_object, card)
        suit_icons = {
            "Hearts" => "♥",
            "Diamonds" => "♦",
            "Clubs" => "♣",
            "Spades" => "♠"
          }
        card_text = "#{card.rank} #{suit_icons[card.suit]}"
        text_object.text = card_text
    end

    # Blocking
    def player_turn(&block)
        yield if block_given?
    end

    def dealer_turn(&block)
        while @dealer.total < 17
            dealer_hit
            yield if block_given? # Yield to a block if provide
        end
    end

    #blocking
    #https://medium.com/rubycademy/the-yield-keyword-603a850b8921
    def player_turn(&block)
        yield if block_given?
    end

    def dealer_turn(&block)
        #yield if block_given?
        while @dealer.total < 17
            dealer_hit
            yield if block_given? # Yield to a block if provided
          end
    end

    def dealer_hit
        new_card = @deck.draw
        @dealer.add_card(new_card)
    end

    # Method to update the player's total based on the cards they have
    def update_player_total
        player_total_value = @player.total
        @text_player_total.text = "Total: #{player_total_value} "
    end

    # Method to update the dealer's total based on the cards they have
    def update_dealer_total
        dealer_total_value = @dealer.total
        @text_dealer_total.text = "Total: #{dealer_total_value} "
    end

    def check_for_blackjack(player)
        #
        blackjack_map = {
        21 => "Blackjack! You win!",
        :bust => "Bust! You've exceeded 21.",
    }

        player_total = player.total

        # Determine the appropriate message based on the player's total
        message = player_total > 21 ? blackjack_map[:bust] : blackjack_map[player_total]
        
        # If a message exists for the player's total, display it
        if message
            # Create a Text object and add it to the window to display the message
            Rectangle.new(x: 170, y: 170, width: 300, height: 100, color: 'white', z: 99)
            Text.new(message, x: 200, y: 200, size: 20, color: 'red', z: 100).add
        end
        #
    end # end check_for_blackjack
end # end game


class Card
    # attribute features in ruby that creates getter methods so we can easily change them:
    # https://medium.com/@rossabaker/what-is-the-purpose-of-attr-accessor-in-ruby-3bf3f423f573#:~:text=to%20help%20out.-,attr_reader,color%20%23%20%3C%2D%2D%20Getter%20methods
    attr_reader :rank, :suit, :value
    
    def initialize(rank, suit)
        @rank = rank
        @suit = suit
        @value = calculate_value
    end

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
  
    def start_game
      # Implement if needed
    end
  
    def total 
        total_value = 0
        aces_count = 0
    
        @player_hand.each do |card|
            total_value += card.value
            aces_count += 1 if card.rank == 'A'
        end
    
        while total_value > 21 && aces_count > 0
            total_value -= 10
            aces_count -= 1
        end
    
        total_value
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
        total_value = 0
        aces_count = 0

        @dealer_hand.each do |card|
            total_value += card.value
            aces_count += 1 if card.rank == 'A'
        end

        while total_value > 21 && aces_count > 0
            total_value -= 10
            aces_count -= 1
        end
        
        total_value
    end
end # end Dealer


# Initialize and deal cards for the game
game = Game.new("Player", text_player_card1, text_player_card2, text_dealer_card1, text_dealer_card2, text_player_total, text_dealer_total)

cheatExp = /212121/
cheatActivated = false

# Event listeners for keyboard input
on :key_down do |event|
    if event.key == "d" || event.key == "D"  # Deal cards when 'd' or 'D' is pressed
      game.deal_cards_initially
    elsif event.key == "h" || event.key == "H"  # Hit when 'h' or 'H' is pressed
      game.hit
    elsif event.key == "s" || event.key == "S"  # Stand when 's' or 'S' is pressed
      game.stand
        elsif cheatExp.match?($stdin.gets.chomp)
            cheatActivated = true
            Text.new("Cheat activated!", x: 200, y: 200, size: 20, color: 'red')
    end
  end
  
# Show the window
show


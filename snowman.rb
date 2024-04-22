# Snowman Word Game Common Program
# Ruby Group: Andrea Correia, Frances Gallagher, and Rose Stefanidakis

require 'ruby2d'
require 'set'

#https://www.ruby2d.com/learn/window/
set title: "Snowman Word Game", background: 'blue', resizable: true

# https://www.rubyguides.com/ruby-tutorial/object-oriented-programming/
class Game
    def initialize
        #initialize variables
        @word = read_file('dictionary.txt')
        @out_of_guesses = false
        @guesses = Set.new
        @incorrect_guesses = Set.new  # Initialize incorrect_guesses 
        @guess_limit = 6
        @game_over = false
        @snowman = []
        @incorrect_letters_text = Text.new("", x: 50, y: 10, size: 20, color: 'red') # Incorrect letters
        start_game
    end # End initialize

    # Initial game display
    def start_game
        Text.new("Welcome to the Snowman Word Game!", x: 50, y: 60, size: 20, color: 'white')
        Text.new("Enter a letter please.", x: 50, y: 80, size: 20, color: 'white')
        @word_text = Text.new("", x: 50, y: 100, size: 20, color: 'white')
        update_displayed_word # Update method 
        @game_started = true
    end # End start_game
    
    # Read in word file
    def read_file(filename)
        # https://stackoverflow.com/questions/36140990/break-text-file-into-separate-words-and-store-in-array-in-ruby
        # https://www.ruby-forum.com/t/file-contents-into-hash-table/193963/6
        # https://www.educative.io/answers/what-is-the-chomp-method-in-ruby
        # Read the text file and store each word in a hash table
        words_hash = {}

        File.open(filename, 'r') do |file|
            file.each_line do |line|
                words = line.chomp.split(' ') # separated by spaces
                words.each do |word| # add to hashtable
                    #words_hash[word] = true
                    words_hash[word.downcase] = true  # Convert word to lowercase before adding to hash
                end
            end
        end

        # Convert  keys of the hash table to array
        words_array = words_hash.keys
        random_index = rand(words_array.length) # Pick random word
        random_word = words_array[random_index]
        puts "Random word: #{random_word}"
        random_word
    end # End read_file

    # Update display when typing
    def update_displayed_word
        guessed_word = @word.chars.map { |c| @guesses.include?(c) ? c : '_' }.join(' ')
        @word_text.text = guessed_word

        # Update display - incorrect letters
        @incorrect_letters_text.text = "Incorrect letters: #{@incorrect_guesses.to_a.sort.join(', ')}"
        if @guesses_left_text.nil?
            @guesses_left_text = Text.new("", x: 50, y: 130, size: 20, color: 'white')
        end
        @guesses_left_text.text = "Guesses left: #{guesses_left}"
    end # End update_displayed_word

    # For correct random word
    def correct_word
        @word
    end # End correct_word

    # To count guesses
    def guesses_left
        @guess_limit - (@guesses - @word.chars.to_set).length
    end # End guesses_left

    # To determine event behavior 
    #https://www.ruby2d.com/learn/window/
		def handle_input(letter)
		return if @game_over # Return early if game is already over

		if letter.match?(/[a-zA-Z'-]/) && letter.length == 1
				unless @guesses.include?(letter) || @incorrect_guesses.include?(letter) # Check if letter has not already been guessed 
					if @word.include?(letter)
							@guesses.add(letter)
						else
							@incorrect_guesses.add(letter)  # Add incorrect letter
							@guess_limit -= 1
							update_snowman
						end
						update_displayed_word
						check_game_over
				else
					if @guesses.include?(letter)
							display_message("You already guessed '#{letter}'.", 50, 30)
					else
							display_message("You already guessed '#{letter}' incorrectly.", 50, 30)
					end
				end
		else
				display_message("Invalid input: '#{letter}'. Please enter a letter.", 50, 30)
		end
	end

	def display_message(message, x, y)
		# Remove existing message
		@message_text&.remove

		# Display new message
		@message_text = Text.new(message, x: x, y: y, size: 20, color: 'white') 
	end # End display_message

    # Change guess display for letter inputs
    def editing_guess
        # https://stackoverflow.com/questions/42705679/display-each-character-of-a-string-as-an-underscore-with-a-space-between-each-un
        guesses = [] # Array of letters guessed - starts as underscores
        guesses = @word.chars.map { |c| guesses.include?(c) ? c : '_' }.join(' ')
        puts guesses 
        Text.new(guesses, x: 50, y: 100, size: 20, color: 'white')
    end # End editing_guess

    # Snowman visual - updates based on guesses
    def update_snowman
        case @guess_limit
        when 5
            @snowman << Circle.new(x: 300, y: 450, radius: 80, sectors: 32, color: 'white')
        when 4
            @snowman << Circle.new(x: 300, y: 320, radius: 60, sectors: 32, color: 'white')
        when 3
            @snowman << Circle.new(x: 300, y: 220, radius: 40, sectors: 32, color: 'white')
        when 2
            @snowman << Line.new(x1: 300, y1: 300, x2: 200, y2: 280, width: 5, color: 'white')
        when 1
            @snowman << Line.new(x1: 300, y1: 300, x2: 400, y2: 280, width: 5, color: 'white')
            @snowman << Rectangle.new(x: 250, y: 220 - 40 - 10, width: 100, height: 10, color: 'black') # Create the brim of the hat
            @snowman << Rectangle.new(x: 270, y: 220 - 40 - 10 - 50, width: 60, height: 50, color: 'black')
        when 0
            @game_over = true  # Set @game_over to true when snowman is fully drawn
        end
        @snowman.each(&:add) # Add elements to window
        update_displayed_word
    end # End update_snowman

    # Display correct word at end of game (win or lose)
    def check_game_over
        if @word.chars.all? { |c| @guesses.include?(c) }
            Window.clear
            Text.new('You win!', x: 50, y: 200, z:1, size: 50)
            Text.new("The correct word was: #{correct_word}")  # Display correct word
            @game_over = true
        elsif @guess_limit.zero?
            Window.clear
            Text.new('You lose!', x: 50, y: 200, z:1, size: 50)
            Text.new("The correct word was: #{correct_word}")  # Display correct word
            @game_over = true
        end
	end # End check_game_over

end # End class game

# Create game instance
game = Game.new

# Define event handler
on :key_down do |event|
    key = event.key
    
    if key.match?(/[0-9!@#$%^&*()]/) # Check if the input is a number
        game.display_message("Numbers and Symbols are not allowed. Please enter a letter.", 50, 30)
    elsif key.match?(/[a-zA-Z'-]/) && key.length == 1
        shift_pressed = event.key == 'left shift' || event.key == 'right shift'
        letter = shift_pressed ? key.upcase : key.downcase
        game.handle_input(letter)
    end
end # End event handler definition

# Add snowman elements
game.update_snowman
    
# Show window
show

require 'ruby2d'
require 'set'

#https://www.ruby2d.com/learn/window/
set title: "Snowman Word Game", background: 'blue', resizable: true

# https://www.rubyguides.com/ruby-tutorial/object-oriented-programming/
class Game
	def initialize
		#initialize all variables
		@word = read_file('dictionary.txt')
		@out_of_guesses = false
		@guesses = Set.new
		@incorrect_guesses = Set.new  # Initialize incorrect_guesses here
		@guess_limit = 6
		@game_over = false
		@snowman = []
		@incorrect_letters_text = Text.new("", x: 50, y: 120, size: 20, color: 'red') # Display incorrect letters
		start_game
  end

	def start_game
		Text.new("Welcome to the Snowman Word Game!", x: 50, y: 60, size: 20, color: 'white')
		Text.new("Enter a letter please.", x: 50, y: 80, size: 20, color: 'white')
		@word_text = Text.new("", x: 50, y: 100, size: 20, color: 'white')
		update_displayed_word # Corrected method name
		@game_started = true
	end
	
	def read_file(filename)
		# https://stackoverflow.com/questions/36140990/break-text-file-into-separate-words-and-store-in-array-in-ruby
		# https://www.ruby-forum.com/t/file-contents-into-hash-table/193963/6
		# https://www.educative.io/answers/what-is-the-chomp-method-in-ruby
		# Read the text file and store each word in a hash table
		words_hash = {}

		File.open('dictionary.txt', 'r') do |file|
			file.each_line do |line|
				words = line.chomp.split(' ') # separated by spaces
				words.each do |word| # add to hashtable
					words_hash[word] = true
				end
			end
		end

		# Convert the keys of the hash table to an array
		words_array = words_hash.keys
		random_index = rand(words_array.length) # pick random word
		random_word = words_array[random_index]
		puts "Random word: #{random_word}"
		#return random_word
		random_word
	end

	#to update display when typing
	def update_displayed_word
		guessed_word = @word.chars.map { |c| @guesses.include?(c) ? c : '_' }.join(' ')
		@word_text.text = guessed_word

		# Update the displayed incorrect letters
		@incorrect_letters_text.text = "Incorrect letters: #{@incorrect_guesses.to_a.join(', ')}"
		if @guesses_left_text.nil?
			@guesses_left_text = Text.new("", x: 50, y: 140, size: 20, color: 'white')
		end
		@guesses_left_text.text = "Guesses left: #{guesses_left}"
	end

	# for the correct random word
	def correct_word
		@word
	end

	# to count guesses
	def guesses_left
		@guess_limit - (@guesses - @word.chars.to_set).length
	end

	#https://www.ruby2d.com/learn/window/
	def handle_input(letter)
		if letter.match?(/[a-zA-Z'-]/) && letter.length == 1
			unless @guesses.include?(letter) || @incorrect_guesses.include?(letter) # Check if the letter has not been guessed before
				if @word.include?(letter)
					@guesses.add(letter)
				else
					@incorrect_guesses.add(letter)  # Add incorrect letter
					@guess_limit -= 1
					update_snowman
				end
				update_displayed_word
				check_game_over
			end
		end
	end

	def editing_guess
		# https://stackoverflow.com/questions/42705679/display-each-character-of-a-string-as-an-underscore-with-a-space-between-each-un
		guesses = [] #letters guessed go into this array(starts as underscores)
		guesses = @word.chars.map { |c| guesses.include?(c) ? c : '_' }.join(' ')
		puts guesses 
		Text.new(guesses, x: 50, y: 100, size: 20, color: 'white')
	end

	def update_snowman
		#@snowman.each(&:remove)  # Remove existing snowman elements
		case @guess_limit
		when 5
			@snowman << Circle.new(x: 300, y: 450, radius: 80, sectors: 32, color: 'white')
		when 4
			@snowman << Circle.new(x: 300, y: 320, radius: 60, sectors: 32, color: 'white')
		when 3
			@snowman << Circle.new(x: 300, y: 220, radius: 40, sectors: 32, color: 'white')
		when 2
			@snowman << Line.new(x1: 300, y1: 300, x2: 240, y2: 260, width: 5, color: 'white')
		when 1
			@snowman << Line.new(x1: 300, y1: 300, x2: 360, y2: 260, width: 5, color: 'white')
		when 0
			@game_over = true  # Set @game_over to true when the snowman is fully drawn
		end
		@snowman.each(&:add) # add elements to window
		update_displayed_word
	end

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
	end
end

	# Create game instance
	game = Game.new

	# Define the event handler
	on :key_down do |event|
		key = event.key
	  
		if key.match?(/[a-zA-Z'-]/) && key.length == 1
		  shift_pressed = event.key == 'left shift' || event.key == 'right shift'
		  letter = shift_pressed ? key.upcase : key.downcase
		  game.handle_input(letter)
		end
	  end

	# Add snowman elements
	game.update_snowman
	
	# Show window
	show
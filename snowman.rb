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
		@guess_limit = 6
		@game_over = false
		@snowman = []
		start_game
  end

	def start_game
		#initial message
		Text.new("Welcome to the Snowman Word Game!", x: 50, y: 60, size: 20, color: 'white')
		Text.new("Enter a letter please.", x: 50, y: 80, size: 20, color: 'white')
		puts "Starting game"
		@game_started = true
		#handle_input
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
		return random_word
	end
	
	#https://www.ruby2d.com/learn/window/
	def handle_input
		editing_guess #showing current state of the word

		puts "Enter a letter"
		letter = gets.chomp.downcase
		if letter == /[a-z]/
			if @word.include?(letter)
				@guesses.add(letter)
			else
				@guess_limit -= 1
				update_snowman
			end
			check_game_over
		end
	end

	def editing_guess
		# https://stackoverflow.com/questions/42705679/display-each-character-of-a-string-as-an-underscore-with-a-space-between-each-un
		guesses = [] #letters guessed go into this array(starts as underscores)
		guesses = @word.chars.map { |c| guesses.include?(c) ? c : '_' }.join(' ')
		puts guesses 
		Text.new(guesses)
  end

	def update_snowman
    case @guess_limit
    when 5
      @snowman << Circle.new(x: 300, y: 450, radius: 80, sectors: 32, color: 'white')
    when 4
      @snowman << Circle.new(x: 300, y: 320, radius: 60, sectors: 32, color: 'white')
    when 3
      @snowman << Circle.new(x: 300, y: 220, radius: 40, sectors: 32, color: 'white')
    when 2
      @snowman << Line.new(x1: 300, y1: 280, x2: 260, y2: 240, width: 5, color: 'white')
    when 1
      @snowman << Line.new(x1: 300, y1: 280, x2: 340, y2: 240, width: 5, color: 'white')
    when 0
      @snowman << Line.new(x1: 290, y1: 200, x2: 310, y2: 200, width: 5, color: 'white')
      @game_over = true
    end
  end

	def check_game_over
    if @word.chars.all? { |c| @guesses.include?(c) }
      puts 'You win!'
      @game_over = true
    elsif @guess_limit.zero?
      puts 'You lose!'
      @game_over = true
    end
  end
end

#testing


game = Game.new


show


require 'ruby2d'
# https://www.rubyguides.com/ruby-tutorial/object-oriented-programming/
set title: "Snowman Word Game", background: 'blue', resizable: true

class Game
  MAX_WRONG_GUESSES = 6

	def initialize
    #@word = Word.new
    #@guesses = []
    #@wrong_guesses = 0
  end

	def play
		Text.new("Welcome to the Snowman Word Game!", x: 50, y: 60, size: 20, color: 'white')
		Text.new("Enter a letter please.", x: 50, y: 80, size: 20, color: 'white')

  end
end

class Word
end

#testing
# Snowman body
Circle.new(
  x: 300, y: 450,
  radius: 80,
  sectors: 32,
  color: 'white'
)

Circle.new(
  x: 300, y: 320,
  radius: 60,
  sectors: 32,
  color: 'white'
)

Circle.new(
  x: 300, y: 220,
  radius: 40,
  sectors: 32,
  color: 'white'
)

game = Game.new
game.play
show


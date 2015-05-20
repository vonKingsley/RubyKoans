require 'pry'
# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.
#

##moved the diceSet and DiceScore to this file for simplicity
class DiceSet
  attr_accessor :dice, :num_dice

  def initialize(num_dice)
    @num_dice = num_dice
    @dice = Array.new(num_dice, 0)
    roll
  end

  def num_dice
    @dice.size
  end

  def roll
    @dice.map!{rand(1..6)}
  end

  def values
    @dice
  end
end

class DiceScore

  def initialize(dice_set)
    @dice = dice_set.dice
    @total = 0
  end

  def check_and_score_triple
    trip = nil
    if @dice.find{ |side| trip = side; @dice.count(side) >= 3; }
      if trip == 1
        @total += 1000
      else
        @total += trip * 100
      end
      3.times { @dice.delete_at @dice.index(trip) }
    end
  end

  def score_others
    @dice.find_all do |num|
      num == 1 || num == 5
    end.each do |ones_fives|
      @total += 100 if ones_fives == 1
      @total += 50 if ones_fives == 5
    end
  end

  def score
    return @total if @dice.empty?
    check_and_score_triple
    score_others
    [1,5].each {|n| @dice.delete(n)}
    @total
  end
end

class Player
  attr_accessor :score, :name
  attr_accessor :dice_set, :remaining_dice
  attr_reader :rolling_score

  def initialize name
    @name = name
    @rolling_score = [0]
    @dice_set = nil
    @score = 0
  end

  def roll(num)
    @dice_set = DiceSet.new(num)
    @rolling_score << DiceScore.new(@dice_set).score
    @remaining_dice = @dice_set.dice
  end

  def had_a_bad_round
    @rolling_score = [0]
  end

  def good_round
    @score += current_score
  end

  def current_score
    @rolling_score.inject(:+)
  end
end

class Game

  def initialize
    @round = 1
  end

  def take_turn dice
    @current_player.roll dice
  end

  def first_roll
    take_turn 5
  end

  def roll_unscored
    puts "Your current roll scores: #{@current_player.current_score}"
    puts "#{@current_player.remaining_dice} dice left over. Continue[y,n]?"
    continue_rolling = gets.strip
    if continue_rolling == 'y'
      take_turn @current_player.remaining_dice.size
      if @current_player.rolling_score.last == 0
        puts "No Points recieved durring roll. You lost the roll and the points :(" 
        @current_player.had_a_bad_round
        puts "Current Score: #{@current_player.score}"
        return false
      end
      return true
    end
    false
  end

  def run(players)
    loop do
      puts "Round #{@round}"
      players.each do |player|
        @current_player = player
        puts "This is the last round." if @last_run
        puts @current_player.name
        puts "Starting the round with #{@current_player.score} points."
        first_roll
        if (@current_player.current_score <= 300 and (@current_player.score <= 300 and @current_player.score >=0))
          puts "Your score is below the 300 threshold\n\n"
          @current_player.had_a_bad_round
          next
        end
        if @current_player.remaining_dice.size == 0
          puts "Congrats all dice scored, You get a free roll"
          puts "You ended the round with #{@current_player.score}"
          redo
        end
        while roll_unscored
        end
      @current_player.good_round
      puts "You ended the round with #{@current_player.score}"
      @last_run = true if @current_player.score > 3000
      end
      break if @last_run
      @round += 1
    end
    determine_winner players
  end

  def determine_winner players
    old_score = 0
    high_score = nil
    players.each_with_index do |player, idx|
      high_score = idx if player.score > old_score
      old_score = player.score
    end
    winner = players[high_score]
    puts "The winner is #{winner.name} with a score of #{winner.score}"
  end
end

p1 = Player.new "Kingsley"
p2 = Player.new "Kristen"
Game.new.run([p1,p2])

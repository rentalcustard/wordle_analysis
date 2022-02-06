wordle_words = File.readlines('words.txt').map(&:upcase).map(&:strip)
@frequency_of_character_at_index = {
    0 => Hash.new { 0 },
    1 => Hash.new { 0 },
    2 => Hash.new { 0 },
    3 => Hash.new { 0 },
    4 => Hash.new { 0 }
}

def build_character_frequency_lookups(wordle_words)
    wordle_words.each do |w|
        w.chars.each_with_index do |c,i|
            @frequency_of_character_at_index[i][c] += 1
        end
    end
end

def guess(previous_result, remaining_words, answer, rejected_letters)
    guess = ""
    result = if previous_result == ""
        guess = 'ROATE'
        wordle(answer, 'ROATE')
    else
        #for each remaining word, find the word which has the highest-frequency letter in each position
        guess = remaining_words.sort_by {|w| score(w) }.last
        wordle(answer, guess)
    end

    rejected_letters = reject_letters(result, guess, rejected_letters)
    # puts "Guess: #{guess}"
    # puts "Score for this guess: #{score(guess)}"
    # puts "Rejected letters #{rejected_letters}"
    [result, guess, rejected_letters]
end

def score(word)
    index = 0
    word.chars.sum do |c|
       f = @frequency_of_character_at_index[index][c]
       index++
       f
    end
end

def reject_letters(result, guess, rejected_letters)
    result.chars.each_with_index do |c, i|
        if c == '-'
            rejected_letters << guess.chars[i] unless rejected_letters.any? {|r| r == guess.chars[i]}
        end
    end
    rejected_letters
end

def wordle(answer, guess)
    result = []
    guess.chars.each_with_index do |c, i|
        if answer.chars[i] == c
            result << "G"
        elsif answer.chars.any? {|d| d == c}
            result << "Y"
        else
            result <<"-"
        end
    end

    result.join
end

def words_matching(guess, result, remaining_words, rejected_letters)
    possibilities = remaining_words.dup
    possibilities.reject! {|p| p.chars.any? {|c| rejected_letters.any? {|r| r == c}}}
    result.chars.each_with_index do |c, i|
        next if c == '-'
        if c == 'G'
            possibilities.select! {|p| p.chars[i] == guess[i]}
        else
            possibilities.reject! {|p| p.chars[i] == guess[i]}
            possibilities.select! {|p| p.chars.any? {|d| guess[i] == d}}
        end
    end

    possibilities
end

build_character_frequency_lookups(wordle_words)
wordle_words.each do |word|
    # puts "trying with #{word}"
    guesses_remaining = 6
    result = ""
    rejected_letters = []
    remaining_words = wordle_words.dup
    until (result == "GGGGG") || (guesses_remaining == 0) do
        # puts result
        # puts guesses_remaining
        returns = guess(result, remaining_words, word, rejected_letters)
        result = returns[0]
        guess = returns[1]
        rejected_letters = returns[2]
        remaining_words.delete(guess)
        remaining_words = words_matching(guess, result, remaining_words, rejected_letters)
        guesses_remaining -= 1
    end
    if guesses_remaining == 0 && result != "GGGGG"
        puts "Wordle is not solvable for word #{word}. Possibilities left: #{remaining_words.inspect}"
    else
        puts "Wordle solved with #{guesses_remaining} guesses remaining for #{word}."
    end
end
require "./trainer.rb"

$balance_key = "balance"
$rock_key = "rock"
$paper_key = "paper"
$scissors_key = "scissors"
$opp_strat_key = "opp_strategy"
$bot__strat_key = "bot_strategy"
$time_key = "time"

# ex. {"abcde12345" : {"balance": 5, "rock": 0.3, "paper": 0.3, "scissors": 0.4}}
$sessions_info_dict = {}

def create_game_file(session_id, game_file_str, start_new, action)
  if start_new
    $sessions_info_dict[session_id] = {$balance_key => 0, $time_key => Time.new}
    train_bot(session_id)
  end

  if action != ""
    player_action = get_action_num(action)
    trainer = Trainer.new
    bot_action = trainer.get_action($sessions_info_dict[session_id][$bot_strat_key])

    outcome = 0
    if (player_action == 0 and bot_action == 2) or ((player_action - bot_action) == 1)
      outcome = 1
    elsif (player_action == 2 and bot_action == 0) or ((bot_action - player_action) == 1))
      outcome = -1
    end
    $sessions_info_dict[session_id][$balance_key] += outcome
  end

  game_file = File.new(game_file_str , "w")
  add_values_to_file(game_file, session_id, start_new, player_action, bot_action, outcome)
  game_file.close
end

def train_bot(session_id)
  trainer = Trainer.new
  $sessions_info_dict[session_id][$opp_strat_key] = trainer.opp_strategy
  
  trainer.train(10000)

  bot_strategy = trainer.get_average_strategy
  $sessions_info_dict[session_id][$bot_strat_key] = bot_strategy
end

def add_values_to_file(game_file, session_id, start_new, player_action, bot_action, outcome)
  opp_strategy = $sessions_info_dict[session_id][$bot_strat_key]
  File.readlines('game.html').each do |line|
    if line.include? ("$" + $balance_key.upcase)
      if not start_new
        game_file.puts(get_action_and_outcome_str(player_action, bot_action, outcome))
      end
      line = line.sub("$" + $balance_key.upcase, $sessions_info_dict[session_id][$balance_key].to_s)
    elsif line.include? ("$" + $rock_key.upcase)
      line = line.sub("$" + $rock_key.upcase, opp_strategy[0].to_s)
    elsif line.include? ("$" + $paper_key.upcase)
      line = line.sub("$" + $paper_key.upcase, opp_strategy[1].to_s)
    elsif line.include? ("$" + $scissors_key.upcase)
      line = line.sub("$" + $scissors_key.upcase, opp_strategy[2].to_s)
    end
    game_file.puts(line)
  end
end

def get_action_and_outcome_str(player_action, bot_action, outcome)
  str = "<h3>You chose " + get_action_str(player_action) 
  str += ". The bot chose " + get_action_str(bot_action)
  str += ". Gain/loss is $" + outcome.to_s + "</h3>"
end

def get_bot_strat(session_id)
  bot_strategy = $sessions_info_dict[session_id][$bot_strat_key]
  string_to_append = ""
  string_to_append += "<h3>Strategy Bot Learned</h3>"
  string_to_append += "<h4>Rock: " + bot_strategy[0].to_s  + "</h4>"
  string_to_append += "<h4>Paper: " + bot_strategy[1].to_s  + "</h4>"
  string_to_append += "<h4>Scissors: " + bot_strategy[2].to_s  + "</h4>"

  string_to_append
end

def get_action_num(action)
  if action == $rock_key
    return 0
  elsif action == $paper_key
    return 1
  else
    return 2
  end
end

def get_action_str(action)
  if action == 0
    return $rock_key
  elsif action == 1
    return $paper_key
  else
    return $scissors_key
  end
end

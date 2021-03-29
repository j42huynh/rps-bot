require 'sinatra'
require './helpers.rb'

set :sessions, true

get '/' do
  #TODO before deploying, add timestamp to sessions dict and clear day old ones here
  send_file 'index.html'
end

# used to start a game
get '/game' do
  session_id = session["session_id"]
  game_file_str = session_id + '_game.html'
  if File.file?(game_file_str)
    File.delete(game_file_str)
  end
  create_game_file(session_id, game_file_str, true, "")
  send_file game_file_str
end

# used to submit moves to a game
post '/game' do
  session_id = session["session_id"]
  game_file_str = session_id + '_game.html'
  File.delete(game_file_str)
  create_game_file(session_id, game_file_str, false, params["action"])
  send_file game_file_str
end

get '/game_with_bot_strat' do
  session_id = session["session_id"]
  game_file_str = session_id + '_game.html'
  if not File.readlines(game_file_str).grep(/<h3>Strategy Bot Learned<\/h3>/).any?
    File.write(game_file_str, get_bot_strat(session_id), File.size(game_file_str), mode: 'a')
  end
  send_file game_file_str
end

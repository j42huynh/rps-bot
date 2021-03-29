class Trainer
  # Assign rock, paper, scissors action values of 0, 1, 2 repsectively
  @@num_actions = 3

  def initialize
    @regret_sum = Array.new(@@num_actions, 0)
    @strategy = Array.new(@@num_actions, 0)
    @strategy_sum = Array.new(@@num_actions, 0) 
    set_opp_strategy
  end

  def set_opp_strategy
    first_strat = rand(10..50)
    second_strat = rand(10..(100 - first_strat))
    temp_opp_strat = Array[first_strat, second_strat, 100 - (first_strat + second_strat)]
    
    temp_index = rand(@@num_actions)
    opp_rock_strat = temp_opp_strat[temp_index]
    opp_paper_strat = temp_opp_strat[(temp_index + 1) % @@num_actions]
    opp_scissors_strat = temp_opp_strat[(temp_index + 2) % @@num_actions]
    @opp_strategy = Array[opp_rock_strat * 1.0 / 100,  opp_paper_strat * 1.0 / 100,  opp_scissors_strat * 1.0 / 100]
  end

  def opp_strategy
    @opp_strategy
  end

  def strategy
    @strategy
  end

  def train(number_of_iterations)
    action_utility = Array.new(@@num_actions)
    (0..(number_of_iterations - 1)).each do |i|
      # Get regret-matched mixed-strategy actions
      @strategy = get_strategy
      bot_action = get_action(@strategy)
      opp_action = get_action(@opp_strategy)

      # Compute action utilities
      action_utility[opp_action] = 0 # utility of picking the same action
      action_utility[if opp_action == (@@num_actions - 1) then 0 else (opp_action + 1) end] = 1 # utility of picking a winning action
      action_utility[if opp_action == 0 then (@@num_actions - 1) else (opp_action - 1) end] = -1 # utility of picking a losing action

      # Accumulate action regrets
      (0..(@@num_actions - 1)).each do |i|
        @regret_sum[i] += action_utility[i] - action_utility[bot_action]
      end
    end
  end

  # Get mixed strategy through regret matching
  def get_strategy
    strategy = Array.new(@@num_actions)
    normalizing_sum = 0
    ctr_limit = @@num_actions - 1
    (0..ctr_limit).each do |i|
      strategy[i] = if @regret_sum[i] > 0 then @regret_sum[i] else 0 end
      normalizing_sum += strategy[i]
    end

    (0..ctr_limit).each do |i|
      if normalizing_sum > 0
        strategy[i] /= normalizing_sum
      else
        strategy[i] = 1.0 / @@num_actions
      end
      @strategy_sum[i] += strategy[i]
    end

    strategy
  end

  # Get random strategy according to mixed-strategy distribution
  def get_action(strategy)
    r = rand()
    ctr = 0
    cumulative_probability = 0
    while ctr < (@@num_actions - 1) do
      cumulative_probability += strategy[ctr]
      if r < cumulative_probability 
        break 
      end
      ctr += 1
    end

    ctr
  end

  # Get average mixed strategy across all training iterations
  def get_average_strategy
    average_strategy = Array.new(@@num_actions)
    normalizing_sum = 0
    ctr_limit = @@num_actions - 1
    (0..ctr_limit).each do |i|
      normalizing_sum += @strategy_sum[i]
    end

    (0..ctr_limit).each do |i|
      if normalizing_sum > 0
        average_strategy[i] = @strategy_sum[i] / normalizing_sum
      else
        average_strategy[i] = 1.0 / normalizing_sum
      end
    end

    average_strategy
  end
end

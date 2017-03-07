class UserProgress
  include Virtus.model
  attribute :data
  attribute :world_config

  def data
    @data.with_indifferent_access
  end

  def world_config
    @world_config.with_indifferent_access
  end

  def puzzles
    @puzzles ||= UserProgressPuzzles.new(data:data, world_config: world_config)
  end

  def locations
    @locations ||= UserProgressLocations.new(data:data, world_config: world_config, puzzles: puzzles)
  end

  def learning_topics
    @learning_topics ||= UserProgressLearningTopics.new(data:data, world_config: world_config, puzzles: puzzles)
  end

  class UserProgressPuzzles
    include DateFormats
    include Virtus.model
    attribute :data
    attribute :world_config

    def by_location(location)
      puzzle_data.select{|p| location[:puzzles].include?(p.id)}
    end

    def by_learning_topic(learning_topic)
      puzzle_data.select{|p| p[:learning_topic_ids].include? learning_topic[:id]}
    end

    private

    def puzzle_states
      @puzzle_states ||= begin
        return {} unless data[:locations].present?
        data[:locations].flat_map{|lc| lc[:puzzles]}
          .reduce({}) do |h,puzzle|
            info = {}
            info[:completed?] = puzzle[:puzzleState] == "UNLOCKED"
            info[:completed_at] = DateTime.parse( puzzle[:completedAt] ) rescue nil
            h[ puzzle[:id] ] = info
            h
          end
      end
    end

    def puzzle_data
      @puzzle_data ||= begin
        puzzles_json = world_config[:puzzles] || []
        learning_topics_json = world_config[:learningTopics] || []
        puzzles_json.map do |puzzle_json|
          puzzle_learning_topics = learning_topics_json.select do |lt|
            lt[:puzzleTypes].include?(puzzle_json[:type])
          end
          learning_topic_names = puzzle_learning_topics.map{|lt| lt[:name]}
          learning_topic_ids   = puzzle_learning_topics.map{|lt| lt[:id]}
          completed_at_date_time = puzzle_states[ puzzle_json[:id] ].try(:[], :completed_at)
          OpenStruct.new(
            id: puzzle_json[:id],
            name: puzzle_json[:id].humanize,
            learning_topic_names: learning_topic_names,
            learning_topic_ids: learning_topic_ids,
            completed?: puzzle_states[ puzzle_json[:id] ].try(:[], :completed?),
            completed_at: date_format(completed_at_date_time),
            completed_at_date_time: completed_at_date_time
          )
        end
      end
    end
  end

  class UserProgressLocations
    include Virtus.model
    attribute :data
    attribute :world_config
    attribute :puzzles, UserProgressPuzzles

    def each #location, #puzzles
      return enum_for(:each) unless block_given?
      locations.each do |location|
        yield location, location.puzzles
      end
    end

    private

    def locations
      @locations ||= begin
        ordered_locations = world_config[:locations].sort_by do |loc|
          world_config[:locationOrder].index(loc[:id])
        end.map do |loc|
          UserProgressBlock.new(
            id: loc[:id],
            name: loc[:id].humanize,
            puzzles: puzzles.by_location(loc)
          )
        end
      end
    end
  end

  class UserProgressLearningTopics
    include Virtus.model
    attribute :data
    attribute :world_config
    attribute :puzzles, UserProgressPuzzles

    def each #learni_topic, #puzzles
      return enum_for(:each) unless block_given?
      learning_topics.each do |learning_topic|
        yield learning_topic, learning_topic.puzzles
      end
    end

    private

    def learning_topics
      @learning_topics ||= begin
        world_config[:learningTopics].map do |lt|
          UserProgressBlock.new(
            id: lt[:id],
            name: lt[:name].humanize,
            puzzles: puzzles.by_learning_topic(lt)
          )
        end
      end
    end
  end

  class UserProgressBlock
    include DateFormats
    include Virtus.model
    attribute :id
    attribute :name
    attribute :puzzles, Array, default: []

    def completed?
       puzzles.all?{|p| p.completed?}
    end

    def completed_at
       date_format(puzzles.map(&:completed_at_date_time).compact.sort.last) if puzzles.present?
    end

    def progress_percentage
      fraction = if puzzles.present?
        (puzzles.select(&:completed?).count * 100/puzzles.size.to_f).ceil
      else
        0
      end
      "#{fraction}%"
    end

    def progress_bar_class
      completed? ? "progress-bar-success" : "progress-bar-incomplete"
    end
  end

end

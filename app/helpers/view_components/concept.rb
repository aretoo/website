module ViewComponents
  class Concept < ViewComponent
    extend Mandate::Memoize
    SIZES = %i[small medium].freeze

    def initialize(concept, user_track, size)
      raise "Invalid concept icon size #{size}" unless SIZES.include?(size.to_sym)

      @concept = concept
      @user_track = user_track
      @size = size
    end

    def to_s
      classes = "c-concept c--#{size}"
      link_to(Exercism::Routes.track_concept_path(user_track.track, concept), class: classes) do
        tag.div(class: 'info') do
          safe_join([
                      ViewComponents::ConceptIcon.new(concept, :small, view_context: view_context).to_s,
                      concept.name
                    ])
        end +
          ViewComponents::ConceptProgressBar.new(concept, user_track, view_context: view_context).to_s
      end
    end

    private
    attr_reader :concept, :user_track, :size

    memoize
    def concept_summary
      user_track.summary.concept(concept.slug)
    end
  end
end
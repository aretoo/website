class UserTrack < ApplicationRecord
  extend Mandate::Memoize

  belongs_to :user
  belongs_to :track
  has_many :user_track_learnt_concepts, class_name: "UserTrack::LearntConcept", dependent: :destroy
  has_many :learnt_concepts, through: :user_track_learnt_concepts, source: :concept

  def self.for!(user_param, track_param)
    UserTrack.find_by!(
      user: User.for!(user_param),
      track: Track.for!(track_param)
    )
  end

  def self.for(user_param, track_param, external_if_missing: false)
    for!(user_param, track_param)
  rescue ActiveRecord::RecordNotFound
    return nil unless external_if_missing

    begin
      External.new(Track.for!(track_param))
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def external?
    false
  end

  def solutions
    user.solutions.joins(:exercise).where("exercises.track_id": track)
  end

  delegate :exercise_available?, :exercise_completed?,
    :num_completed_exercises,
    :num_concepts, :num_concepts_mastered,
    :num_exercises,
    :num_exercises_for_concept, :num_completed_exercises_for_concept,
    :concept_available?, :concept_learnt?, :concept_mastered?,
    :concept_progressions, :available_exercise_ids, :available_concept_ids,
    to: :summary

  memoize
  def available_concept_exercises
    available_exercises.select { |e| e.is_a?(ConceptExercise) }
  end

  memoize
  def available_practice_exercises
    available_exercises.select { |e| e.is_a?(PracticeExercise) }
  end

  memoize
  def available_concepts
    Track::Concept.where(id: summary.available_concept_ids)
  end

  memoize
  def available_exercises
    Exercise.where(id: summary.available_exercise_ids)
  end

  memoize
  def uncompleted_exercises
    Exercise.where(id: summary.uncompleted_exercises_ids)
  end

  private
  # A track's summary is a effeciently created summary of all
  # of a user_track's data. It's cached across requests, allowing
  # us to quickly retrieve data without requiring lots of complex
  # SQL queries.
  def summary
    @summary ||= UserTrack::GenerateSummary.(track, self)
  end
end

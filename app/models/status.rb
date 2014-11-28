class Status < ActiveRecord::Base
  STATES = %w(pending success failure error).freeze
  enum state: STATES.zip(STATES).to_h

  belongs_to :commit, touch: true

  validates :state, inclusion: {in: STATES, allow_blank: true}, presence: true

  after_commit :schedule_continuous_delivery, :broadcast_update, on: :create

  delegate :broadcast_update, to: :commit

  def self.replicate_from_github!(github_status)
    find_or_create_by!(
      state: github_status.state,
      description: github_status.description,
      target_url: github_status.rels.try(:[], :target).try(:href),
      context: github_status.context,
      created_at: github_status.created_at.to_s(:db),
    )
  end

  private

  def schedule_continuous_delivery
    commit.schedule_continuous_delivery
  end
end

class Favorite < ActiveRecord::Base
  attr_accessor :key, :title
  attr_accessible :key, :title, :created_at, :person_id

  validates_presence_of   :video_id, :person_id
  validates_uniqueness_of :video_id, scope: :person_id

  belongs_to :person
  belongs_to :video

  before_validation :find_or_create_video, on: :create

  after_create :update_video_first_person

  def find_or_create_video
    if video = Video.find_by_key(key)
      self.video = video
    else
      self.video = Video.create(key: key, title: title, created_at: created_at)
    end
  end

  def update_video_first_person
    video.first_person = video.favorites.order('created_at asc').first.person
    video.save!
  end
end

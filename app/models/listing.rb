class Listing < ActiveRecord::Base
  belongs_to :neighborhood
  belongs_to :host, :class_name => "User"
  has_many :reservations
  has_many :reviews, :through => :reservations
  has_many :guests, :class_name => "User", :through => :reservations

  validates :address, :presence => true
  validates :listing_type, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true
  validates :price, :presence => true
  validates :neighborhood, :presence => true

  after_save :change_user_host_status
  after_destroy :remove_host_status_if_all_listings_destroyed

  def average_review_rating
    binding.pry
    if self.reviews.count > 0
      self.reviews.inject(0){|sum, review| sum + review.rating.to_f}/(self.reviews.count)
    else
      0
    end
  end

 private

  def change_user_host_status
    self.host.update(host: true)
  end

  def remove_host_status_if_all_listings_destroyed
    if Listing.where(host: host).where.not(id: id).empty?
      host.update(is_host: false)
    end
  end


end

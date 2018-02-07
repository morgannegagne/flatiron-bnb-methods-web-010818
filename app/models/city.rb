class City < ActiveRecord::Base
  has_many :neighborhoods
  has_many :listings, :through => :neighborhoods

  def city_openings(start_date, end_date)
    startI = start_date.to_date
    endI = end_date.to_date

    available_listings = []
    self.listings.each do |listing|
      available = true
      listing.reservations.each do |reservation|
        if reservation.checkin <= endI && reservation.checkout >= startI
          available = false
          break
        end
      end
      available_listings << listing if available
    end
    available_listings
  end

  def self.highest_ratio_res_to_listings
    # map to return a ratio
    ratios = self.all.each_with_object({}) do |city, hash|
      number_listings = city.listings.count
      number_reservations = city.listings.inject(0){|count, listing| count + listing.reservations.count}.to_f
      ratio = number_reservations/number_listings
      hash[city.id] = ratio
    end
    id_with_best_ratio = ratios.key(ratios.values.max)
    self.find(id_with_best_ratio)
  end

  def self.most_res
    reservations_hash = self.all.each_with_object({}) do |city, hash|
      number_reservations = city.listings.inject(0){|count, listing| count + listing.reservations.count}
      hash[city.id] = number_reservations
    end
    id_with_most_reservations = reservations_hash.key(reservations_hash.values.max)
    self.find(id_with_most_reservations)
  end


end

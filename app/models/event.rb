require "date"

class Event < ApplicationRecord
  STATUS = [ "Open", "Closed" ].freeze
  belongs_to :host, class_name: "User"
  has_many :guests
  has_one_attached :photo

  validates :date, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :title, presence: true
  validates :description, presence: true

  geocoded_by :address
  # Geocode only when the address changed and the form didn't already supply
  # coordinates (the autocomplete fills them in; typing by hand clears them).
  after_validation :geocode, if: -> { will_save_change_to_address? && (latitude.blank? || longitude.blank?) }

  def distance_to(geolocation)
    Geocoder::Calculations.distance_between(geolocation, [ latitude, longitude ])
  end
end

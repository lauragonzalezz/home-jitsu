class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  BELTS = ["White", "Blue", "Purple", "Brown", "Black", "None"].freeze
  GENDERS = ["Male", "Female", "Other"].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :weight, presence: true
  validates :weight, length: { in: 2..4 }
  validates :weight, comparison: { greater_than: 0 }
  validates :height, presence: true
  validates :height, length: { in: 2..4 }
  validates :height, comparison: { greater_than: 0 }
  validates :belt, inclusion: { in: BELTS }
  validates :years_of_experience, comparison: { greater_than_or_equal_to: 0 }
  validates :address, presence: true
  validates :gender, presence: true
  validates :gender, inclusion: { in: GENDERS }

  has_many :reviews
  has_many :partners
  has_many :hosted_events, class_name: 'Event', foreign_key: 'host_id'
  has_many :events, class_name: 'Guest', foreign_key: 'guest_id'
  has_many :messages
end

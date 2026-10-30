class Partner < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :requestee, class_name: "User"

  STATUS = [ "pending", "accepted", "rejected" ]

  validates :requester_id, presence: true
  validates :requestee_id, presence: true
  validates :status, inclusion: { in: STATUS }

  # The partnership between two users, whichever of them sent the request.
  # Accepts User records or ids.
  scope :between, ->(a, b) {
    where(requester_id: a, requestee_id: b).or(where(requester_id: b, requestee_id: a))
  }

  def users
    [ requester, requestee ]
  end
end

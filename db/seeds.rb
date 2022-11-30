require "faker"
require "open-uri"

ADDRESS = ["2054 Claremont", "4300 de Maisonneuve", "5120 Earnscliffe", "2121 St-Mathieu",
           "2255 St-Mathieu", "2125 St-Marc", "7205 d'Iberville", "2100 St-Marc", "5051 Clanranald",
           "5015 Clanranald", "4454 Coolbrook", "5881 Monkland", "2250 Guy", "1680 Lincoln",
           "6565 Kildare", "5755 Sir Walter Scott", "7460 Kingsley", "7461 Kingsley", "6950 Fielding",
           "5501 Adalbert", "625 Milton", "3474 Hutchison", "3655 Papineau", "1111 Mistral", "1101 Rachel E"].freeze
p "Destroying chatrooms and messages"
Message.destroy_all
Chatroom.destroy_all
p "Destroying all your users..."
User.destroy_all
p "Creating new users..."

ricky = User.new(
  email: "ricky.tran@gmail.com",
  password: "123456",
  first_name: "Ricky",
  last_name: "Tran",
  weight: 55,
  height: 173,
  address: "418 Claremont",
  gender: "Male",
  description: "Martial Arts Prodigy",
  years_of_experience: 0,
  belt: "None"
)
file = URI.open("https://res.cloudinary.com/dr82gggzf/image/upload/v1669766488/ricky_fbqus7.jpg")
ricky.photo.attach(io: file, filename: "jon.png", content_type: "image/png")
ricky.save

laura = User.new(
  email: "laura.gonzalez@gmail.com",
  password: "123456",
  first_name: "Laura",
  last_name: "Gonzalez",
  weight: 55,
  height: 164,
  address: "5333 Casgrain",
  gender: "Female",
  belt: "Purple",
  years_of_experience: 6,
  description: "BJJ expert that will strangle you"
)
file = URI.open("https://res.cloudinary.com/dr82gggzf/image/upload/v1669766489/laura-gonzalez_eggbxn.jpg")
laura.photo.attach(io: file, filename: "jon.png", content_type: "image/png")
laura.save

tsunami = User.new(
  email: "tsunami.abi@gmail.com",
  password: "123456",
  first_name: "Touhami",
  last_name: "Abi",
  weight: 70,
  height: 175,
  address: "5160 Gatineau",
  gender: "Male",
  description: "Not a BJJ expert but give him a stick and he will Kendo you to the ground",
  years_of_experience: 0,
  belt: "None"
)
file = URI.open("https://res.cloudinary.com/dr82gggzf/image/upload/v1669766492/touhami_fkztx4.jpg")
tsunami.photo.attach(io: file, filename: "jon.png", content_type: "image/png")
tsunami.save

jonathan = User.new(
  email: "jonathan.troupe@gmail.com",
  password: "123456",
  first_name: "Jonathan",
  last_name: "Troupe",
  weight: 62,
  height: 180,
  address: "4875 Dufferin",
  gender: "Male",
  belt: "Black",
  years_of_experience: 10,
  description: "The only way you'll make it out is in a body bag."
)
file = URI.open("https://res.cloudinary.com/dr82gggzf/image/upload/v1669766489/jon_uvwasx.jpg")
jonathan.photo.attach(io: file, filename: "jon.png", content_type: "image/png")
jonathan.save

ADDRESS.each do |address|
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  User.create!(
    address: address,
    belt: User::BELTS.sample,
    first_name:,
    last_name:,
    weight: (40..100).to_a.sample,
    height: (100..250).to_a.sample,
    gender: User::GENDERS.sample,
    years_of_experience: (0..20).to_a.sample,
    email: "#{first_name}.#{last_name}@gmail.com",
    password: "123456"
  )
end

p "Users created successfully."

p "Clearing out events, guests, partner requests and reviews"
Event.destroy_all
Guest.destroy_all
Review.destroy_all
Partner.destroy_all
p "Creating new events, guests, partner requests and reviews"

park1 = "https://res.cloudinary.com/dr82gggzf/image/upload/v1669766488/park1_bxndwu.jpg"
park2 = "https://res.cloudinary.com/dr82gggzf/image/upload/v1669766488/park2_b7fgrz.jpg"
gym1 = "https://res.cloudinary.com/dr82gggzf/image/upload/v1669766488/gym1_prtutu.jpg"
dojo1 = "https://res.cloudinary.com/dr82gggzf/image/upload/v1669766488/dojo1_q7f5xv.jpg"

event_photos = [park1, park2, gym1, dojo1]

5.times do
  event = Event.new(
    address: ADDRESS.sample,
    date: DateTime.now,
    status: "Open",
    host: jonathan,
    description: Faker::Quote.matz,
    title: Faker::Games::DnD.city
  )
  event.photo.attach(io: URI.open(event_photos.sample), filename: "PhotoFor#{event.title}.png", content_type: "image/png")
  event.save
  Guest.create!(
    event_id: Event.last.id,
    guest_id: [laura.id, tsunami.id, ricky.id].sample,
    status: Guest::STATUS.sample
  )
  Review.create!(
    content: Faker::TvShows::AquaTeenHungerForce.quote,
    user_id: jonathan.id,
    writer_id: [laura.id, tsunami.id, ricky.id].sample,
    rating: 4
  )
  Partner.create!(
    requestee_id: jonathan.id,
    requester_id: User.all.ids.sample
  )
  Partner.create!(
    requester_id: jonathan.id,
    requestee_id: User.all.ids.sample
  )
end

5.times do
  event = Event.new(
    address: ADDRESS.sample,
    date: DateTime.now,
    status: "Open",
    host: ricky,
    description: Faker::Quote.matz,
    title: Faker::Games::DnD.city
  )
  event.photo.attach(io: URI.open(event_photos.sample), filename: "PhotoFor#{event.title}.png", content_type: "image/png")
  event.save
  Guest.create!(
    event_id: Event.last.id,
    guest_id: [laura.id, tsunami.id, jonathan.id].sample,
    status: Guest::STATUS.sample
  )
  Review.create!(
    content: Faker::TvShows::AquaTeenHungerForce.quote,
    user_id: ricky.id,
    writer_id: [laura.id, tsunami.id, jonathan.id].sample,
    rating: 5
  )
  Partner.create!(
    requestee_id: ricky.id,
    requester_id: User.all.ids.sample
  )
  Partner.create!(
    requester_id: ricky.id,
    requestee_id: User.all.ids.sample
  )
end

5.times do
  event = Event.new(
    address: ADDRESS.sample,
    date: DateTime.now,
    status: "Open",
    host: laura,
    description: Faker::Quote.matz,
    title: Faker::Games::DnD.city
  )
  event.photo.attach(io: URI.open(event_photos.sample), filename: "PhotoFor#{event.title}.png", content_type: "image/png")
  event.save
  Guest.create!(
    event_id: Event.last.id,
    guest_id: [jonathan.id, tsunami.id, ricky.id].sample,
    status: Guest::STATUS.sample
  )
  Review.create!(
    content: Faker::TvShows::AquaTeenHungerForce.quote,
    user_id: laura.id,
    writer_id: [ricky.id, tsunami.id, jonathan.id].sample,
    rating: 5
  )
  Partner.create!(
    requestee_id: laura.id,
    requester_id: User.all.ids.sample
  )
  Partner.create!(
    requester_id: laura.id,
    requestee_id: User.all.ids.sample
  )
end

5.times do
  event = Event.new(
    address: ADDRESS.sample,
    date: DateTime.now,
    status: "Open",
    host: tsunami,
    description: Faker::Quote.matz,
    title: Faker::Games::DnD.city
  )
  event.photo.attach(io: URI.open(event_photos.sample), filename: "PhotoFor#{event.title}.png", content_type: "image/png")
  event.save
  Guest.create!(
    event_id: Event.last.id,
    guest_id: [laura.id, jonathan.id, ricky.id].sample,
    status: Guest::STATUS.sample
  )
  Review.create!(
    content: Faker::TvShows::AquaTeenHungerForce.quote,
    user_id: tsunami.id,
    writer_id: [laura.id, ricky.id, jonathan.id].sample,
    rating: 5
  )
  Partner.create!(
    requestee_id: tsunami.id,
    requester_id: User.all.ids.sample
  )
  Partner.create!(
    requester_id: tsunami.id,
    requestee_id: User.all.ids.sample
  )
end

p "Created events, guests, partner requests and reviews for each user attached"

p "Creating real chatrooms and messages"

chat1 = Chatroom.create!(name: "private_#{ricky.id}_#{laura.id}_")
chat2 = Chatroom.create!(name: "private_#{ricky.id}_#{tsunami.id}_")
chat3 = Chatroom.create!(name: "private_#{ricky.id}_#{jonathan.id}_")
chat4 = Chatroom.create!(name: "private_#{laura.id}_#{tsunami.id}_")
chat5 = Chatroom.create!(name: "private_#{laura.id}_#{jonathan.id}_")
chat6 = Chatroom.create!(name: "private_#{tsunami.id}_#{jonathan.id}_")

5.times do
  Message.create!(
    content: Faker::Movies::StarWars.quote,
    chatroom_id: chat1.id,
    user_id: [ricky.id, laura.id].sample
  )
end

5.times do
  Message.create!(
    content: Faker::Movies::StarWars.quote,
    chatroom_id: chat2.id,
    user_id: [ricky.id, tsunami.id].sample
  )
end

5.times do
  Message.create!(
    content: Faker::Movies::StarWars.quote,
    chatroom_id: chat3.id,
    user_id: [ricky.id, jonathan.id].sample
  )
end

5.times do
  Message.create!(
    content: Faker::Movies::StarWars.quote,
    chatroom_id: chat4.id,
    user_id: [laura.id, tsunami.id].sample
  )
end

5.times do
  Message.create!(
    content: Faker::Movies::StarWars.quote,
    chatroom_id: chat5.id,
    user_id: [laura.id, jonathan.id].sample
  )
end

5.times do
  Message.create!(
    content: Faker::Movies::StarWars.quote,
    chatroom_id: chat6.id,
    user_id: [tsunami.id, jonathan.id].sample
  )
end

p "Created real chatrooms and messages"

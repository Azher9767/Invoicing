ApplicationRecord.reset_column_information
ActiveRecord::Base.transaction do
  u = User.new(email: 'johndoe@example.com', password: 'password')
  u.save!

  categories = Category.create!([{name: 'Consultation Work', user_id: u.id}, {name: 'Interviews', user_id: u.id}])

  Product.create!([
    { name: 'Ruby Work', category_id: 1, unit_rate: 100, unit: 'hrs'},
    { name: 'Rails work', category_id: 1, unit_rate: 100, unit: 'hrs' },
    { name: 'New application work', category_id: 1, unit_rate: 100, unit: 'hrs' },
    { name: 'System design work', category_id: 1, unit_rate: 100, unit: 'hrs' },
  ])
  Product.create!(
    [{name: 'Ruby Interview', category_id: 2, unit_rate: 100, unit: 'hrs'},
    { name: 'Rails Interview', category_id: 2, unit_rate: 100, unit: 'hrs' },
    { name: 'Lead Interview', category_id: 2, unit_rate: 100, unit: 'hrs' }
  ])
end

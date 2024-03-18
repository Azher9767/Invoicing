class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable


   # set_table_name 'user'
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end

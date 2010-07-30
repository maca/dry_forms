ActiveRecord::Migration.verbose       = false
ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

ActiveRecord::Schema.define :version => 1 do
  create_table  :posts do |t|
    t.string    :title
    t.integer   :author_id
    t.text      :body
    t.timestamps
  end
  
  create_table  :authors do |t|
    t.string    :name
    t.timestamps
  end
  
  create_table  :comments do |t|
    t.string    :title
    t.integer   :author_id
    t.text      :body
    t.timestamps
  end
end




class Post < ActiveRecord::Base
  belongs_to :author
  accepts_nested_attributes_for :author
  validates_presence_of :title
end

class Comment < ActiveRecord::Base
  belongs_to :author
end

class Author < ActiveRecord::Base
  has_many :posts
  has_many :comments
  accepts_nested_attributes_for :posts
end
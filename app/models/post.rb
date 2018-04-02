class Post < ApplicationRecord
  after_save :update_cache
  after_destroy :remove_from_cache

  belongs_to :author, optional: true

  validates :title, presence: true, allow_blank: false

  protected

    def update_cache_deps
      [
        { controller: :posts, action: :edit, id: self.id },
        { controller: :posts, action: :index },
      ]
    end

    def remove_cache_deps
      [
        { controller: :posts, action: :edit, id: self.id, expire: true },
        { controller: :posts, action: :index },
      ]
    end
end

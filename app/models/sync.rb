class Sync
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :passport_last_synched, type: Date
  field :visa_last_synched,     type: Date
  
  validates :passport_last_synched, presence: true
  validates :visa_last_synched,     presence: true  
end

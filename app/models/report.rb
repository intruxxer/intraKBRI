class Report
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  
  before_create :assign_ref_id
  belongs_to :user, :class_name => "User", :inverse_of => :report
  
  field :owner_id,                  type: String
  field :ref_id,                    type: String
  field :name,                      type: String
  field :height,                    type: String
  field :birthplace,                type: String
  field :datebirth,                 type: Date
  field :marriagestatus,            type: String
  
  field :nopaspor,                  type: String
  field :dateissued,                type: Date
  field :dateend,                   type: Date
  field :passportplace,             type: String
  field :pasporplace,               type: String
  field :immigrationOffice,         type: String
  
  field :visatype,                  type: String
  field :visadateissued,            type:Date 
  field :visadateend,               type:Date 
  
  field :koreanjob,                 type:String 
  field :koreaninstancename,        type:String 
  field :koreaninstancephone,       type:String 
  field :koreaninstanceaddress,     type:String
  field :koreaninstancecity,        type:String
  field :koreaninstanceprovince,    type:String
  field :koreaninstancepostalcode,  type:String
  
  field :koreanphone,               type:String
  field :koreanaddress,             type:String
  field :koreanaddresscity,         type:String
  field :koreanaddressprovince,     type:String
  field :koreanaddresspostalcode,   type:String
  
  field :indonesianphone,             type:String
  field :indonesianaddress,           type:String
  field :indonesianaddresskelurahan,  type:String
  field :indonesianaddresskecamatan,  type:String
  field :indonesianaddresskabupaten,  type:String
  field :indonesianaddressprovince,   type:String
  field :indonesianaddresspostalcode, type:String
  
  field :relationname,              type:String
  field :relationstatus,            type:String
  field :relationphone,             type:String
  field :relationaddress,           type:String
  field :relationaddresskelurahan,  type:String
  field :relationaddresskecamatan,  type:String
  field :relationaddresskabupaten,  type:String
  field :relationaddressprovince,   type:String
  field :relationaddresspostalcode, type:String
  
  field :arrivaldate,               type:Date
  field :indonesianinstance,        type:String
  
  field :pasporname,                type:String
  field :aliencardname,             type:String 
   
  field :stayinkorea,               type:Boolean, default: true
  
  has_mongoid_attached_file :photo, :styles => { :thumb => "90x120>" }
  validates_attachment_content_type :photo, :content_type => %w(image/jpeg image/jpg image/png)
  validates_attachment_presence :photo
  validates_attachment_size :photo, less_than: 2.megabytes
  
  private
  def assign_ref_id
    self.ref_id = generate_string(3)+"/KONS/"+generate_string(3)
  end
  def generate_string(length=5)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ123456789'
      random_characters = ''
      length.times { |i| random_characters << chars[rand(chars.length)] }
      random_characters = random_characters.upcase
  end
end

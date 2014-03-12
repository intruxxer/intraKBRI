class Report
  include Mongoid::Document
  include Mongoid::Timestamps
  
  before_create :assign_ref_id
  
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
  field :photoname,                 type:String 
  field :stayinkorea,               type:Boolean, default: true
  
  belongs_to :user, :class_name => "User", :inverse_of => :report
  
  private
  def assign_ref_id
    self.ref_id = generate_string(3)+"-"+Random.new.rand(10**4..10**10).to_s+generate_string(3)
  end
  def generate_string(length=5)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ123456789'
      random_characters = ''
      length.times { |i| random_characters << chars[rand(chars.length)] }
      random_characters = random_characters.upcase
  end
end

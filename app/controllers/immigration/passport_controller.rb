class Immigration::PassportController < ApplicationController
  include SimpleCaptcha::ControllerHelpers
  before_filter :authenticate_user!
  #GET /passport  
  
  def index
    #1 Person, 1 Application in 5 years
    #if Passport.where(user_id: current_user).count > 0
    #    redirect_to edit_passport_path(current_user)
    #end
    #We comment this as we want to enable multiple paspors and/or SPLPs
    @passport = Passport.new
  end
  
  def reapply
    redirect_to root_path, :notice => 'You have successfully notified The Embassy staff to recheck your previously incomplete application.'
  end
  
  #GET /new
  def new
  
  end
  
  def check
    @passport = Passport.find(params[:id])    
    render layout: "dashboard"    
  end
  
  #GET passport/:id
  def show
    @passport = Passport.find(params[:id])
      respond_to do |format|
      format.html #visa_processing/show.html.erb
      format.json { render json: @passport }
      format.xml { render xml: @passport }
      format.pdf do
          render :pdf            => "Receipt of Passport Application ["+"#{current_user.full_name}"+"]_" + @passport.ref_id,
                 :disposition    => "attachment", #{attachment, inline}                 
                 :template       => "immigration/passport/pasporpayment.html.erb",
                 :layout         => "pdf_layout.html"                 
        end
    end
  end
  
  #POST /passport
  def create       
    @passport = [ Passport.new(post_params) ]
    #current_user.passports = @passport    
    tempcache = @passport
    @passport = @passport[0]
    
    if @passport.valid?
      if simple_captcha_valid?
          current_user.passports.push(tempcache)   
          current_user.save
          UserMailer.passport_received_email(current_user).deliver
          flash[:notice] = 'Pengurusan aplikasi paspor anda, berhasil!'
          render 'pasporconfirm.html.erb'
      else        
        @errors = { 'Secret Code' => 'Wrong Code Entered'}
        render 'index'
      end
    else     
      @errors = @passport.errors.messages
      render 'index'
    end
    
    
    #debugging
    #logger.debug "We are inspecting PASSPORT PROCESSING PARAMS as follows:"
    #puts params.inspect
    #puts @passport.inspect
  end
  
  #GET /passport/:id/edit
  def edit
    #@passport = Passport.find_by(user_id: params[:id])
    @passport = Passport.find(params[:id])
  end
  
  #PATCH, PUT /passport/:id
  def update
    @passport = Passport.find(params[:id])
    #@passport = Passport.find_by(user_id: params[:id])
    if @passport.update(post_params)
      if current_user.has_role? :admin or current_user.has_role? :moderator
        UserMailer.admin_update_passport_email(@passport).deliver
      end
      redirect_to :back, :notice => 'Anda telah berhasil memperbaharui data pengurusan paspor anda!'
    else
      @errors = @passport.errors.messages
      render 'edit'
    end
  end
  
  #DELETE /passport
  def destroy 
   @passport = Passport.find(params[:id])
    reference = @passport.ref_id
    if @passport.delete
      redirect_to :back, :notice => "Visa Application of Ref. No #{reference} has been erased."
    else
      redirect_to :back, :notice => "Visa Application of Ref. No #{reference} is not found."
    end
  end    
  
  private  
    def post_params()
      params.require(:passport).permit(:application_type, :application_reason, :paspor_type, :full_name, :height, :kelamin, :placeBirth, :dateBirth,              
      :citizenship_status, :lastPassportNo, :dateIssued, :placeIssued, :jobStudyInKorea, :jobStudyTypeInKorea, :jobStudyOrganization, :jobStudyAddress, 
      :phoneKorea, :addressKorea, :cityKorea, :phoneIndonesia, :addressIndonesia, :kelurahanIndonesia, :kecamatanIndonesia, :kabupatenIndonesia, :dateArrival, :sendingParty, :photo, :status, :slip_photo, :payment_date, :arc, :dateIssuedEnd, :immigrationOffice, :sponsor_address_prov_kr, :sponsor_address_prov_id, :supporting_doc, :comment)
    end
    #Notes: to add attribute/variable after POST params received, do
    #def post_params
    #  params.require(:post).permit(:some_attribute).merge(user_id: current_user.id)
    #end
    def reference_no_passport
      time = Time.new
      coded_date = time.strftime("%y%m%d")
      ref_id = '1'+coded_date+generate_string(3)
    end
    def generate_string(length=5)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ123456789'
      password = ''
      length.times { |i| password << chars[rand(chars.length)] }
      password = password.upcase
    end
end

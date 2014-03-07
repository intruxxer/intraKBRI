class Immigration::VisaController < ApplicationController
  #GET /visa
  def index
    #if individual 1 person, 1 application
    #if Visa.where(user_id: current_user).count > 0
        #redirect_to root_path
     #end
     #We will have passport
  end
  
  #GET /new
  def new
  
  end

  #POST /visa
  def create
    
   uploaded_passport = params[:visa][:passport]
   if (uploaded_passport != nil)
      new_passport = uploaded_passport.read
      File.open(Rails.root.join('public', 'uploads', uploaded_passport.original_filename), 'wb') do |file|
        file.write(new_passport)
      end
   end
   
   uploaded_idcard = params[:visa][:idcard]
   if (uploaded_idcard != nil)
      new_idcard = uploaded_idcard.read
      File.open(Rails.root.join('public', 'uploads', uploaded_idcard.original_filename), 'wb') do |file|
        file.write(uploaded_idcard)
      end
   end
   
   uploaded_passport_picture = params[:visa][:photo]
   if (uploaded_passport_picture != nil)
      new_pass_picture = uploaded_passport_picture.read
      File.open(Rails.root.join('public', 'uploads', uploaded_passport_picture.original_filename), 'wb') do |file|
        file.write(uploaded_passport_picture)
      end
   end
   
   uploaded_paymentslip_picture = params[:visa][:slip_photo]
   if (uploaded_paymentslip_picture != nil)
      new_pay_picture = uploaded_paymentslip_picture.read
      File.open(Rails.root.join('public', 'uploads', uploaded_paymentslip_picture.original_filename), 'wb') do |file|
        file.write(uploaded_paymentslip_picture)
      end
   end
     
   @visa = [ Visa.new(post_params) ]    
    if current_user.visas = @visa then
      current_user.save
      UserMailer.visa_received_email(current_user).deliver
      respond_to do |format|
        format.html { redirect_to root_path, :notice => "Your visa application is successfully received!" }
        format.json { render json: {action: "JSON Creating Visa", result: "Saved"} }
        format.js #if being asked by AJAX to return "script" <-->
            #visa_processing/create.js.erb -->to execute script JS,
            #like stopping loading.gif, hiding the element, alerting user
      end
    else
    redirect_to :back, :notice => "Unfortunately, your current visa application fails to be submitted."
    #do something further 
    end
    #*Debugging*#
    #logger.debug "We are inspecting VISA PROCESSING PARAMS as follows:"
    #puts params.inspect
    #puts @visa.inspect
  end

  #GET visa/:id
  def show
    @visa = Visa.find(params[:id])
      respond_to do |format|
      format.html #visa_processing/show.html.erb
      format.json { render json: @visa }
      format.xml { render xml: @visa }
    end
  end
  
  def show_all
    @visas = Visa.all   
    
    params.permit(:sSearch,:iDisplayLength,:iDisplayStart)
    
    unless (params[:sSearch].nil? || params[:sSearch] == "")    
      searchparam = params[:sSearch]  
      @visas = @visas.any_of({:full_name => /#{searchparam}/},{:ref_id => /#{searchparam}/})
    end   
    
    unless (params[:iDisplayStart].nil? || params[:iDisplayLength] == '-1')
      @visas = @visas.skip(params[:iDisplayStart]).limit(params[:iDisplayLength])      
    end    
    
    iTotalRecords = Visa.count
    iTotalDisplayRecords = @visas.count
    aaData = Array.new    
    
    @visas.each do |visa|
      editLink = "<a href=\"/visas/" + visa.id + "/edit\" target=\"_blank\"><span class='glyphicon glyphicon-pencil'></span><span class='glyphicon-class'>Update Application</span></a>"
      printLink = "<a href=\"/visas/" + visa.id + "/edit\" target=\"_blank\"><span class='glyphicon glyphicon-export'></span><span class='glyphicon-class'>Send to SISARI</span></a>"
      aaData.push([ visa.ref_id, visa.full_name, visa.status, editLink + "&nbsp;|&nbsp;" + printLink])
                        
    end
    
    respond_to do |format|
      format.json { render json: {'sEcho' => params[:sEcho].to_i , 'aaData' => aaData , 'iTotalRecords' => iTotalRecords, 'iTotalDisplayRecords' => iTotalDisplayRecords } }
    end
  end
  
  #PATCH, PUT /visa/:id
  def update
    #@visa = Visa.find_by(user_id: params[:id])
    @visa = Visa.find(params[:id])         
    if @visa.update_attributes(post_params)   
      @visa.save      
      redirect_to root_path, :notice => 'You have updated your visa application data!'
    else
      render 'edit'
    end
  end
  
  #GET /visa/:id/edit
  def edit
    #Why NOT searching based on user_id? because there will be MULTIPLE visas/users
    #Hence, NOT @visa = Visa.find_by(user_id: params[:id]), but
    @visa = Visa.find(params[:id])
  end
  
  #DELETE /visa
  def destroy 
  
  end
  
  private
    def post_params
      params.require(:visa).permit(:application_type, :category_type, :full_name, :sex, :email,
      :placeBirth, :dateBirth, :marital_status, :nationality, :profession, :passport_no, :passport_no,
      :passport_issued, :passport_type, :passport_date_issued, :passport_date_expired, :sponsor_type_kr,
      :sponsor_name_kr, :sponsor_address_kr, :sponsor_phone_kr, :sponsor_type_id, :sponsor_name_id, 
      :sponsor_address_id, :sponsor_phone_id, :duration_stays_day, :duration_stays_month, :duration_stays_year, 
      :num_entry, :checkbox_1, :checkbox_2, :checkbox_3, :checkbox_4, :checkbox_5, :checkbox_6, :checkbox_7, 
      :tr_count_dest, :tr_flight_vessel, :tr_air_sea_port, :tr_date_entry, :lim_s_purpose, 
      :lim_s_flight_vessel, :lim_s_air_sea_port, :lim_s_date_entry, :v_purpose, :v_flight_vessel,
      :v_air_sea_port, :v_date_entry, :dip_purpose, :dip_flight_vessel, :dip_air_sea_port, :dip_date_entry, :o_purpose, 
      :o_flight_vessel, :o_air_sea_port, :o_date_entry, :passportpath, :idcardpath, :photopath, :status, :payment_slip
      ).merge(owner_id: current_user.id, ref_id: 'V-KBRI-'+generate_string+"-"+Random.new.rand(10**5..10**6).to_s)
    end
    #Notes: to add attribute/variable after POST params received, do
    #def post_params
    #  params.require(:post).permit(:some_attribute).merge(user_id: current_user.id)
    #end
    def generate_string(length=5)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ123456789'
      password = ''
      length.times { |i| password << chars[rand(chars.length)] }
      password = password.upcase
    end
    
end

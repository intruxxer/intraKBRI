class Immigration::PassportController < ApplicationController
  #GET /passport
  @@VIPACOUNTERDEF = 6600
  
  def index
    #1 Person, 1 Application in 5 years
    #if Passport.where(user_id: current_user).count > 0
    #    redirect_to edit_passport_path(current_user)
    #end
    #We comment this as we want to enable multiple paspors and/or SPLPs
  end
  
  #GET /new
  def new
  
  end
  
  #GET passport/:id
  def show
    @passport = Passport.find(params[:id])
      respond_to do |format|
      format.html #visa_processing/show.html.erb
      format.json { render json: @passport }
      format.xml { render xml: @passport }
    end
  end
  
  #POST /passport
  def create
    uploaded_passport_picture = params[:passport][:photo]
    if (uploaded_passport_picture != nil)
      new_pass_picture = uploaded_passport_picture.read
      File.open(Rails.root.join('public', 'uploads', uploaded_passport_picture.original_filename), 'wb') do |file|
        file.write(uploaded_passport_picture)
      end
    end
    
    uploaded_paymentslip_picture = params[:passport][:slip_photo]
    if (uploaded_paymentslip_picture != nil)
      new_pay_picture = uploaded_paymentslip_picture.read
      File.open(Rails.root.join('public', 'uploads', uploaded_paymentslip_picture.original_filename), 'wb') do |file|
        file.write(uploaded_paymentslip_picture)
      end
    end
   
    @passport = [ Passport.new(post_params) ]    
    if current_user.passports = @passport then
      current_user.save
      UserMailer.passport_received_email(current_user).deliver
      respond_to do |format|
        format.html { redirect_to root_path, :notice => "Pengurusan aplikasi paspor anda, berhasil!" }
        format.json { render json: {action: "JSON Creating Passport", result: "Saved"} }
        format.js #if being asked by AJAX to return "script" <-->
            #passport_processing/create.js.erb -->to execute script JS,
            #like stopping loading.gif, hiding the element, alerting user
      end
    else
    redirect_to :back, :notice => "Mohon maaf, Aplikasi pengurusan paspor anda gagal diproses."
    #do something further 
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
      redirect_to root_path, :notice => 'Anda telah berhasil memperbaharui data pengurusan paspor anda!'
    else
      render 'edit'
    end
  end
  
  #DELETE /passport
  def destroy 
  
  end  
  
  def exec_toSPRI
    @passport = Passport.find(params[:id])
    
    params.require(:passport).permit(:passport_no,:reg_no)
    
    db = Accessdb.new( Rails.root.to_s + '/public/SPRI3.mdb' )
    db.open()    
    
    db.execute("INSERT INTO tblDATA(noPass, noReg, namaLkP, tmpLahir, tglLahir, jmlHal, noLama, tglKeluarLama, tmpKeluarLama, idCode, KantorPerwakilan) 
        VALUES('" + params[:passport][:passport_no] + "','" + params[:passport][:reg_no] + "','" + @passport.full_name + "','" + @passport.placeBirth + "','" + @passport.dateBirth.to_s + "','24','" + @passport.lastPassportNo + "','" + @passport.dateIssued.to_s + "','" + @passport.placeIssued + "','37A','KBRI SEOUL')")
      
    db.close
    
    @passport.update_attributes({:status => 'Printed',:passport_no => params[:passport][:passport_no], :reg_no => params[:passport][:reg_no]})
  end
  
  def show_all
    @passport = Passport.all   
    
    params.permit(:sSearch,:iDisplayLength,:iDisplayStart)
    
    unless (params[:sSearch].nil? || params[:sSearch] == "")    
      searchparam = params[:sSearch]  
      @passport = @passport.any_of({:full_name => /#{searchparam}/},{:ref_id => /#{searchparam}/},{:status => /#{searchparam}/})
    end   
    
    unless (params[:iDisplayStart].nil? || params[:iDisplayLength] == '-1')
      @passport = @passport.skip(params[:iDisplayStart]).limit(params[:iDisplayLength])      
    end    
    
    iTotalRecords = Passport.count
    iTotalDisplayRecords = @passport.count
    aaData = Array.new    
    
    @passport.each do |passport|
      editLink = "<a href=\"/passports/" + passport.id + "/edit\" target=\"_blank\"><span class='glyphicon glyphicon-pencil'></span><span class='glyphicon-class'>Update Application</span></a>"
      printLink = "<a href=\"/admin/service/prep_spri/" + passport.id + "\" target=\"_blank\"><span class='glyphicon glyphicon-export'></span><span class='glyphicon-class'>Send to SPRI</span></a>"
      aaData.push([ passport.ref_id, passport.full_name, passport.status, editLink + "&nbsp;|&nbsp;" + printLink])                        
    end
    
    respond_to do |format|
      format.json { render json: {'sEcho' => params[:sEcho].to_i , 'aaData' => aaData , 'iTotalRecords' => iTotalRecords, 'iTotalDisplayRecords' => iTotalDisplayRecords } }
    end
    
  end
  
  private
    def check_and_get_VIPA_COUNTER
      counter = @@VIPACOUNTERDEF + 1
      if Passport.count > 0
        counter = Passport.last.vipa_no + 1
      end
      
      return counter
    end
  
    def post_params
      params.require(:passport).permit( :application_type, :application_reason, :full_name, :height, :placeBirth, :dateBirth,              
      :marriage_status, :lastPassportNo, :dateIssued, :placeIssued, :jobStudyInKorea, :jobStudyOrganization, :jobStudyAddress, 
      :phoneKorea, :addressKorea, :phoneIndonesia, :addressIndonesia, :dateArrival, :sendingParty, :photopath, :status, :payment_slip).merge(owner_id: current_user.id, 
      ref_id: 'P-KBRI-'+generate_string+"-"+Random.new.rand(10**5..10**6).to_s, vipa_no: check_and_get_VIPA_COUNTER)
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

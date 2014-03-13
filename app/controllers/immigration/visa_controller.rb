class Immigration::VisaController < ApplicationController
  before_filter :authenticate_user!
  @@SISARICOUNTER = 5850
  #GET /visa
  def index
    #if individual 1 person, 1 application
    #if Visa.where(user_id: current_user).count > 0
        #redirect_to root_path
     #end
     #We will have passport
     @visa = Visa.new
     #redirect_to :controller => 'immigration/visa', :action => 'index', :type => 2, :format => 'json'
     respond_to do |format|
        format.html { } # {redirect_to root_path, :notice => "Your visa application is successfully received!" }
        format.json { } # {render json: {action: "JSON Creating Visa", result: "Saved", type: "1"} }
        format.js #if being asked by AJAX to return "script" <-->
            #visa_processing/create.js.erb -->to execute script JS,
            #like stopping loading.gif, hiding the element, alerting user
      end
  end
  
  #GET /new
  def new
  
  end

  #POST /visa
  def create
=begin    
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
        file.write(new_idcard)
      end
   end
   
   uploaded_passport_picture = params[:visa][:photo]
   if (uploaded_passport_picture != nil)
      new_pass_picture = uploaded_passport_picture.read
      File.open(Rails.root.join('public', 'uploads', uploaded_passport_picture.original_filename), 'wb') do |file|
        file.write(new_pass_picture)
      end
   end
   
   uploaded_paymentslip = params[:visa][:slip_photo]
   if (uploaded_paymentslip != nil)
      new_pay_picture = uploaded_paymentslip.read
      File.open(Rails.root.join('public', 'uploads', uploaded_paymentslip.original_filename), 'wb') do |file|
        file.write(new_pay_picture)
      end
   end
   
   uploaded_supdoc = params[:visa][:supdoc]
   if (uploaded_supdoc != nil)
      new_supdoc_picture = uploaded_supdoc.read
      File.open(Rails.root.join('public', 'uploads', uploaded_supdoc.original_filename), 'wb') do |file|
        file.write(new_supdoc_picture)
      end
   end
   
   uploaded_ticket = params[:visa][:supdoc]
   if (uploaded_ticket != nil)
      new_ticket_picture = uploaded_ticket.read
      File.open(Rails.root.join('public', 'uploads', uploaded_ticket.original_filename), 'wb') do |file|
        file.write(new_ticket_picture)
      end
   end
=end     
   @visa = [ Visa.new(post_params) ] 
   current_user.visas = @visa   
    if current_user.save then
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
  
  #PATCH, PUT /visa/:id
  def update
    #@visa = Visa.find_by(user_id: params[:id])
    @visa = Visa.find(params[:id])
    if @visa.update(post_params)
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
  
  #DELETE /visa/:id
  def destroy 
    @visa = Visa.find(params[:id])
    reference = @visa.ref_id
    if @visa.delete
      redirect_to :back, :notice => "Visa Application of Ref. No #{reference} has been erased."
    else
      redirect_to :back, :notice => "Visa Application of Ref. No #{reference} is not found."
    end
  end
  
  def toSisari
    @visa = Visa.find(params[:id])
    
    folderloc = TARGET_SISARI_FOLDER + 'Visa.mdb'
    if @visa.passport_type == 3 || @visa.category_type == 'diplomatic'
      folderloc = TARGET_SISARI_DIPLOMATIK_FOLDER + 'Visa_diplomatik.mdb'
    end
    
    db = Accessdb.new( folderloc )
    db.open('imigrasiRI')    
    
    nextCounter = @@SISARICOUNTER + 1
    
    unless @visa.vipa_no.nil?
      nextCounter = @visa.vipa_no    
    end    
             
    begin
      db.execute("INSERT INTO TTVISA(JK, TIPE_VISA, KETPEKERJAAN, LAMA,TYPELAMA, NO_APLIKASI, JENIS, KDPERWAKILAN, NMPERWAKILAN, TGL_DOC, KODE_NEG, WARGA_NEG, NO_PASPOR, TGL_VALID_PASPOR, TGL_KLUAR_PASPOR, KTR_KLUAR_PASPOR, FLAGACCLOKET, NAMA3, GIVEN_NAME, TGL_LAHIR, TMP_LAHIR, ENTRIES, TGLENTRY, TGL_UPDATE, KD_VISA, Pejabat_ttd, jabatan_ttd) 
        VALUES('" + @visa.sex.to_s + " " + @visa.marital_status.to_s + "','" + @visa.visa_type.to_s + "','" + @visa.profession.to_s + "'," + @visa.duration_stays.to_s + ",'" + @visa.duration_stays_unit.to_s + "','" + nextCounter.to_s + "/" + Time.new.month.to_s + "/" + Time.new.year.to_s + "','I','37A', 'SEOUL', '" + @visa.created_at.strftime("%m/%d/%Y").to_s + "','KOR','KOREA, REPUBLIC OF','" + @visa.passport_no.to_s + "','" + @visa.passport_date_expired.to_s + "','" + @visa.passport_date_issued.to_s + "','" + @visa.passport_issued.to_s + "','Y','" + @visa.last_name.to_s + "','" + @visa.first_name.to_s + "','" + @visa.dateBirth.strftime("%m/%d/%Y") + "','" + @visa.placeBirth.to_s + "','" + @visa.num_entry.to_s + "','" + @visa.created_at.strftime("%m/%d/%Y").to_s + "','" + @visa.updated_at.strftime("%m/%d/%Y").to_s + "','Biasa','Didik Eko Pujianto','COUNSELLOR')")   
      
      @visa.update_attributes({:status => 'Printed', :vipa_no => nextCounter})
       
       msg = { :notice => 'Data berhasil dipindahkan' }
    rescue 
       msg = { :alert => 'Data gagal dipindahkan' }
    end   
      
    db.close   
    
    redirect_to '/dashboard/service/visa', msg
  end
  
  def show_all
    @visas = Visa.all   
    
    params.permit(:sSearch,:iDisplayLength,:iDisplayStart)
    
    unless (params[:sSearch].nil? || params[:sSearch] == "")    
      searchparam = params[:sSearch]  
      @visas = @visas.any_of({:full_name => /#{searchparam}/},{:ref_id => /#{searchparam}/},{:status => /#{searchparam}/})
    end   
    
    unless (params[:iDisplayStart].nil? || params[:iDisplayLength] == '-1')
      @visas = @visas.skip(params[:iDisplayStart]).limit(params[:iDisplayLength])      
    end    
    
    iTotalRecords = Visa.count
    iTotalDisplayRecords = @visas.count
    aaData = Array.new    
    
    @visas.each do |visa|
      editLink = "<a href=\"/visas/" + visa.id + "/edit\" target=\"_blank\"><span class='glyphicon glyphicon-pencil'></span><span class='glyphicon-class'>Update Application</span></a>"
      printLink = "<a href=\"/visa/tosisari/" + visa.id + "\" target=\"_blank\"><span class='glyphicon glyphicon-export'></span><span class='glyphicon-class'>Send to SISARI</span></a>"
      aaData.push([ visa.ref_id, visa.first_name + " " + visa.last_name , visa.status, editLink + "&nbsp;|&nbsp;" + printLink])                        
    end
    
    respond_to do |format|
      format.json { render json: {'sEcho' => params[:sEcho].to_i , 'aaData' => aaData , 'iTotalRecords' => iTotalRecords, 'iTotalDisplayRecords' => iTotalDisplayRecords } }
    end
    
  end
  
  private
    def post_params
      params.require(:visa).permit(:application_type, :category_type, :first_name, :last_name, :sex, :email,
      :placeBirth, :dateBirth, :marital_status, :nationality, :profession, :passport_no, :passport_no,
      :passport_issued, :passport_type, :passport_date_issued, :passport_date_expired, :sponsor_type_kr,
      :sponsor_name_kr, :sponsor_address_kr, :sponsor_address_city_kr, :sponsor_address_prov_kr, :sponsor_phone_kr, 
      :sponsor_type_id, :sponsor_name_id, :sponsor_address_id, :sponsor_address_kab_id, :sponsor_address_prov_id, 
      :sponsor_phone_id, :duration_stays, :duration_stays_unit,
      :num_entry, :checkbox_1, :checkbox_2, :checkbox_3, :checkbox_4, :checkbox_5, :checkbox_6, :checkbox_7, 
      :tr_count_dest, :tr_flight_vessel, :tr_air_sea_port, :tr_date_entry, :lim_s_purpose, 
      :lim_s_flight_vessel, :lim_s_air_sea_port, :lim_s_date_entry, :v_purpose, :v_flight_vessel,
      :v_air_sea_port, :v_date_entry, :dip_purpose, :dip_flight_vessel, :dip_air_sea_port, :dip_date_entry, :o_purpose, 
      :o_flight_vessel, :o_air_sea_port, :o_date_entry, :passportpath, :idcardpath, :photopath, :status, :status_code, :payment_slip, 
      :payment_date, :ticketpath, :sup_docpath).merge(owner_id: current_user.id, visa_type: 1, 
      ref_id: 'V-KBRI-'+generate_string+"-"+Random.new.rand(10**3..10**5).to_s)
    end
    #Notes: to add attribute/variable after POST params received, do
    #def post_params
    #  params.require(:post).permit(:some_attribute).merge(user_id: current_user.id)
    #end
    def generate_string(length=5)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ123456789'
      random_characters = ''
      length.times { |i| random_characters << chars[rand(chars.length)] }
      random_characters = random_characters.upcase
  end
end

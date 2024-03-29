class UserMailer < ActionMailer::Base
  #counselor@kbri.seoul.kr alias: {visa, paspor, konsuler}
  
  def visa_received_email(visa)
  	@url = "http://id-embassy.kr"
  	@email = User.find(visa.user_id).email

  	@visa = visa
  	@ref_id = @visa.ref_id  	
  	attachments["garuda.png"] = File.read("#{Rails.root}/public/assets/images/garuda.png")
  	#attachments["ot-presentation-small.png"] = File.read("#{Rails.root}/public/images/ot-presentation-small.png")

  	mail(
  		:to => @email, 
  		:subject => "Thank you for using eKBRI of Indonesian Embassy in Seoul!", 
  		:from => "Administrator of eKBRI <admin@kbri.seoul.kr>",
  		:reply_to => "Visa Counselor of Indonesian Embassy at Seoul <visa@kbri.seoul.kr>" 
  		)
  end
  
  def passport_received_email(passport)
    @url = "http://id-embassy.kr"
    @email = User.find(passport.user_id).email

    @passport = passport
    @ref_id = @passport.ref_id    
    attachments["garuda.png"] = File.read("#{Rails.root}/public/assets/images/garuda.png")
    #attachments["ot-presentation-small.png"] = File.read("#{Rails.root}/public/images/ot-presentation-small.png")

    mail(
      :to => @email, 
      :subject => "Terimakasih atas penggunaan eKBRI", 
      :from => "Administrator of eKBRI <admin@kbri.seoul.kr>",
      :reply_to => "Fungsi Konsuler KBRI Seoul <paspor@kbri.seoul.kr>" 
      )
  end

  
  def admin_update_passport_email(passport)
    @url = "http://id-embassy.kr"
    @email = User.find(passport.user_id).email
    #userpassport = Passport.where(user_id: user.id).last
    @ref_id = passport.ref_id
    #@uid = user.id
    @passport = passport
    attachments["garuda.png"] = File.read("#{Rails.root}/public/assets/images/garuda.png")
    #attachments["ot-presentation-small.png"] = File.read("#{Rails.root}/public/images/ot-presentation-small.png")
    mail(
      :to => @email, 
      :subject => "Hasil Review Permohonan Passport [Status : " + passport.status + "]", 
      :from => "Administrator of eKBRI <admin@kbri.seoul.kr>",
      :reply_to => "Fungsi Konsuler KBRI Seoul <paspor@kbri.seoul.kr>" 
      )
  end
  
  def admin_update_visa_email(visa)
    @url = "http://id-embassy.kr"
    @email = User.find(visa.user_id).email
    #userpassport = Passport.where(user_id: user.id).last
    @ref_id = visa.ref_id
    #@uid = user.id
    @visa = visa
    attachments["garuda.png"] = File.read("#{Rails.root}/public/assets/images/garuda.png")
    #attachments["ot-presentation-small.png"] = File.read("#{Rails.root}/public/images/ot-presentation-small.png")
    mail(
      :to => @email, 
      :subject => "Visa Application Result [Status : " + visa.status + "]", 
      :from => "Administrator of eKBRI <admin@kbri.seoul.kr>",
      :reply_to => "Fungsi Konsuler KBRI Seoul <paspor@kbri.seoul.kr>" 
      )
  end
  
  def admin_update_report_email(report)
    @url = "http://id-embassy.kr"
    @email = User.find(report.user_id).email
    #userpassport = Passport.where(user_id: user.id).last
    @ref_id = report.ref_id
    #@uid = user.id
    @report = report
    attachments["garuda.png"] = File.read("#{Rails.root}/public/assets/images/garuda.png")
    #attachments["ot-presentation-small.png"] = File.read("#{Rails.root}/public/images/ot-presentation-small.png")
    mail(
      :to => @email, 
      :subject => "Konfirmasi Perubahan Informasi Lapor Diri", 
      :from => "Administrator of e-KBRI <admin@kbri.seoul.kr>",
      :reply_to => "Fungsi Konsuler KBRI Seoul <paspor@kbri.seoul.kr>" 
      )
  end
  
end

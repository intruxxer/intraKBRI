class DashboardController < ApplicationController
  before_filter :authenticate_user!#if user_signed_in?, current_user.full_name, etc. 
  before_filter :check_access
  #because /layouts/dashboard.html.erb exists, default layout used is "dashboard"
  
  def index

  end
  
  def counsel
  
  end
  
  def immigration
    if params[:document] == "visa" then
      @document = "dashboard/service_visa"
      @visa = Visa
    elsif params[:document] == "passport"
      @document = "dashboard/service_passport"
      puts "rendering #{@document}"
    elsif params[:document] == "prep_spri" then
      @document = "dashboard/tospri_prep"
      @passport = Passport.find(params[:id])
    else  
    
    end
  end
  
  def tabulation
  
  end
  
  def employment_indonesia
  
  end
  
  def employment_korea
    
  end
  
  def statistics
  
  end 
  
  def syncpanel
    
    @syncdata = current_user.sync
    
    @document = "dashboard/syncpanel"
    render 'immigration'
  end
  
  protected
  def check_access
    if !current_user.has_role? :admin then
      redirect_to root_path, :flash => { :warning => "The URL you attempt to access is not exist." }
    else  
    end
  end
end

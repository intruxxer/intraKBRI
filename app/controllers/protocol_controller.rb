class ProtocolController < ApplicationController
  before_filter :authenticate_user!#if user_signed_in?, current_user.full_name, etc. 
  before_filter :check_access
  
  def syncCollectionCloudtoLocal()    
    params.permit(:collection)    
    collection = params[:collection]
    
    begin
      session = Moped::Session.new([ "127.0.0.1:27017"])
      session.use('e_kbri_production')
      
      table = session[collection]
      table.drop
      
      session.command(
        cloneCollection: 'e_kbri_production.' + collection,
        from: "162.243.144.189:27017"       
      )
      
      msg = { :notice => 'Data Synchronization Success' }
        
    rescue
      
      msg = { :alert => 'Data Synchronization Failed' }
       
    end 
    
    if collection.downcase == 'passports'
      redirect_to '/dashboard/service/passport', msg  
    else
      redirect_to '/dashboard/service/visa', msg
    end    
  end
  
  def syncDBComplete()
    
    begin
      session = Moped::Session.new(["127.0.0.1:27017"])
      session.use('e_kbri_production')
      session.drop
      
      session.use('admin')
      
      session.command(
          copydb: 1,
          fromhost: '162.243.144.189',
          fromdb: 'e_kbri_production',
          todb: 'e_kbri_production',
      )
      
      msg = { :notice => 'Data Synchronization Success' }
      
    rescue
      
      msg = { :alert => 'Data Synchronization Failed' }
      
    end
    
    redirect_to '/dashboard/service/visa', msg
    
  end
  
end

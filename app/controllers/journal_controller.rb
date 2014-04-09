class JournalController < ApplicationController
  
  def retrieve_user_journal 
    userid = params[:user_id]
    
    @journal = User.find(userid).journals       
    origin = @journal
    
    params.permit(:sSearch,:iDisplayLength,:iDisplayStart)
    
    unless (params[:sSearch].nil? || params[:sSearch] == "")    
      searchparam = params[:sSearch]  
      @journal = @journal.any_of({:model => /#{searchparam}/},{:action => /#{searchparam}/})
    end   
    
    unless (params[:iDisplayStart].nil? || params[:iDisplayLength] == '-1')
      @journal = @journal.skip(params[:iDisplayStart]).limit(params[:iDisplayLength])      
    end    
    
    iTotalRecords = origin.count
    iTotalDisplayRecords = @journal.count
    aaData = Array.new    
    
    @journal.each do |row|      
      aaData.push([ row.action, row.model, row.method, row.created_at.strftime("%Y %b %d %H:%M:%S").to_s, row.record_id ])                        
    end
    
    respond_to do |format|
      format.json { render json: {'sEcho' => params[:sEcho].to_i , 'aaData' => aaData , 'iTotalRecords' => iTotalRecords, 'iTotalDisplayRecords' => iTotalDisplayRecords } }
    end
    
  end
  
  def retrieve_document_journal 
    recordid = params[:id]
    
    @journal = Journal.where(:record_id => recordid)     
    origin = @journal
    
    params.permit(:sSearch,:iDisplayLength,:iDisplayStart)
    
    unless (params[:sSearch].nil? || params[:sSearch] == "")    
      searchparam = params[:sSearch]  
      @journal = @journal.any_of({:model => /#{searchparam}/},{:action => /#{searchparam}/})
    end   
    
    unless (params[:iDisplayStart].nil? || params[:iDisplayLength] == '-1')
      @journal = @journal.skip(params[:iDisplayStart]).limit(params[:iDisplayLength])      
    end    
    
    iTotalRecords = origin.count
    iTotalDisplayRecords = @journal.count
    aaData = Array.new    
    
    @journal.each do |row|      
      respected_user = User.where(:id => row.user_id)
      if respected_user.count > 0
        respected_user = respected_user.first.first_name + ' ' + respected_user.first.last_name
      else
        respected_user = "Deleted User"
      end
      action = row.action + ' by ' + respected_user
      aaData.push([ action, row.method, row.created_at.strftime("%Y %b %d %H:%M:%S").to_s ])                        
    end
    
    respond_to do |format|
      format.json { render json: {'sEcho' => params[:sEcho].to_i , 'aaData' => aaData , 'iTotalRecords' => iTotalRecords, 'iTotalDisplayRecords' => iTotalDisplayRecords } }
    end
    
  end
  
end

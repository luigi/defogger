class DefogController < ApplicationController

  protect_from_forgery :only => [:foo] 

  def index
    
  end
  
  def results
    @result = Result.find_by_key(params[:key])
    @results = CalaisParser.parse(@result.result_body)
  end
  
  def process_url
    
    # save as result object
    result = Result.create(:source_url => params[:url])
    
    # redirect to results/XXX path
    redirect_to "/results/#{result.key}"    
    
  end
  
  def process_text
    
    unless params[:url].blank?
      process_url
      return
    end
    
    unless params[:text].blank?
      
      # save as result object
      result = Result.create(:source_body => params[:text], :source_url => params[:url])
      
      # redirect to results/XXX path
      redirect_to "/results/#{result.key}"
      
    end
    
  end
  
end
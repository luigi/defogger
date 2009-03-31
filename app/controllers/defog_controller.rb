class DefogController < ApplicationController

  def index
    
  end
  
  def results
    
  end
  
  def process_url
    
  end
  
  def process_text
    
  end
  
  def generate_key(length=6)
    ('a'..'z').sort_by {rand}[0,length].join
  end
  
end

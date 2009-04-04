class Result < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper
#  t.string :key
#  t.text :source_url, :source_body, :result_body, :api_body
  
  before_create :generate_key, :get_result
  
  protected
  
  def generate_key
    self.key ||= ('a'..'z').sort_by {rand}[0,6].join
  end

  def get_result
    
    if !self.source_url || self.source_url.blank?
      content_type = :text
    else
      content_type = :html
      self.source_body = pluck_article(self.source_url)
    end
    
    response = Calais.enlighten(:content => self.source_body,
                                :content_type => content_type,
                                :license_id => CALAIS_KEY,
                                :output_format => :simple)
    self.result_body = response
  end

  def pluck_article(url)

    # get the raw HTML
    doc = Nokogiri::HTML(open(url))

    # get the paragraphs
    paragraphs = doc.search('p')

    # assign points to the parent nodes for each paragraph
    parents = {}
    paragraphs.each do |paragraph|
      points = calculate_points(paragraph)
      if parents.has_key?(paragraph.parent)
        parents[paragraph.parent] += points
      else
        parents[paragraph.parent] = points
      end
    end

    # get the parent node with the highest point total
    winner = parents.sort{ |a,b| a[1] <=> b[1] }.last[0]

    # return the plucked HTML content
    "<h1>" + doc.search('title').inner_html + "</h1>" + winner.inner_html
  end


  def calculate_points(paragraph, starting_points = 0)

    # reward for being a new paragraph
    points = starting_points + 20

    # look at the id and class of paragraph and parent
    classes_and_ids = (paragraph.get_attribute('class') || '') + ' ' +
                      (paragraph.get_attribute('id') || '') + ' ' +
                      (paragraph.parent.get_attribute('class') || '') + ' ' +
                      (paragraph.parent.get_attribute('id') || '')

    # deduct severely and return if clearly not content
    if classes_and_ids =~ /comment|meta|footer|footnote/
      points -= 3000
      return points
    end

    # reward if probably content
    if classes_and_ids =~ /post|hentry|entry|article/
      points += 50
    end

    # look at the actual text of the paragraph
    content = paragraph.content

    # deduct if very short
    if content.length < 20
      points -= 50
    end

    # reward if long
    if content.length > 100
      points += 50
    end

    # deduct if no periods, question marks, or exclamation points
    unless (content.include?('.') or content.include?('?') or content.include?('!'))
      points -= 100
    end

    # reward for periods and commas
    points += content.count('.') * 10
    points += content.count(',') * 20

    points

  end

end

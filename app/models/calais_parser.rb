class CalaisParser
  
  # Returns a Hash of Arrays of Defogged Entities
  def self.parse(xml_string)
    doc = XML::Document.string(xml_string)

    people = get_content_from_nodes(doc.find('CalaisSimpleOutputFormat/Person'))
    companies = get_content_from_nodes(doc.find('CalaisSimpleOutputFormat/Company'))
    organizations = get_content_from_nodes(doc.find('CalaisSimpleOutputFormat/Organization'))
    published_media = get_content_from_nodes(doc.find('CalaisSimpleOutputFormat/PublishedMedium'))
    
    {
      :elected_officials => build_elected_officials(people),
      :lobbyists => build_lobbyists(people),
      :companies => build_companies(companies - published_media),
      :organizations => build_organizations(organizations - published_media)
    }
    
  end
  
  def self.get_content_from_nodes(nodes)
    strings = []
    nodes.each do |n|
      strings << n.content
    end
    strings
  end
  
  def self.build_elected_officials(names)
    elected_officials = []
    names.each do |name|
      legislators = Sunlight::Legislator.search_by_name(name,0.95)
      if legislators and legislators.size > 0
        elected_officials << legislators.first
      end
    end
    elected_officials
  end

  def self.build_lobbyists(names)
    lobbyists = []
    names.each do |name|
      results = Sunlight::Lobbyist.search_by_name(name,0.96,2008)
      if results and results.size > 0
        lobbyists << results.first
      end
    end
    lobbyists    
  end
  
  def self.build_companies(companies)
    companies
  end
  
  def self.build_organizations(organizations)
    organizations
  end
  
end

module Sunlight

  class Legislator < Base
   
    def printname
      name = firstname
      name = nickname unless nickname.blank?
      name += " " + lastname
    end
    
  end
  
end
class Newsletter
  LIST_ID = "8f4beddf3a"
  BRIDGE_CATEGORY_ID = "a6c58c551c"

  class Interest < ActiveHash::Base
    fields :id, :name
  end

  def self.gibbon
    @@gibbon ||= Gibbon::Request.new #(debug:true)
  end

  def self.interests_map(list_id, category_id)
    bridge_category = gibbon.lists(LIST_ID).interest_categories(BRIDGE_CATEGORY_ID).interests.retrieve
    map = {}
    bridge_category["interests"].each do |interest| 
      map[interest["id"]] = interest["name"]
    end
    map
  end

  def self.interest_list(list_id = LIST_ID, category_id = BRIDGE_CATEGORY_ID)
    bridge_category = gibbon.lists(LIST_ID).interest_categories(BRIDGE_CATEGORY_ID).interests.retrieve
    puts "bridge_category", bridge_category
    list = []
    bridge_category["interests"].each do |interest| 
      list.push(Interest.new(id:interest["id"], name:interest["name"]))
    end
    puts "list"
    puts list
    list
  end


  def self.subscriber_interests(email)
    id_value_map = gibbon.lists(LIST_ID).members(Digest::MD5.hexdigest(email)).retrieve["interests"]
    interests = {}
    id_value_map.each { |key, value| interests[@@interests_map[key]] = value}
    interests
  end

  def self.subscriber_interest_ids(email)
    id_value_map = gibbon.lists(LIST_ID).members(Digest::MD5.hexdigest(email)).retrieve["interests"]
    id_value_map.select { |key, value| value == true }.map { |key, value| key }
  end


  # map of interest id => name 
  # {"53e27ba66a"=>"ClojureBridge", "690e4bccfe"=>"ElxirBridge", "b776fbae78"=>"ElmBridge", 
  #  "388b0d83b8"=>"GoBridge", "6cb94ee6a7"=>"MobileBridge", "4136883234"=>"RailsBridge", 
  #  "8a30fb705e"=>"RustBridge", "5d5f55f4bb"=>"ScalaBridge"}
  @@interests_map = self.interests_map LIST_ID, BRIDGE_CATEGORY_ID

  # list of {id: => name 
  def self.interests 
    puts "Newsletter.interests"
    @@interests ||= self.interest_list LIST_ID, BRIDGE_CATEGORY_ID
    puts @@interests
    @@interests
  end
end

class User
  def subscription_ids
    Newsletter.subscriber_interest_ids(email)
  end
end
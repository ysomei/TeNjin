# -*- coding: utf-8 -*-

class Hash
  def method_missing(name, val = nil)
    if name[-1] == '='
      self[name.to_s[0..-2].to_sym] = val
    else
      self[name]
    end
  end
end

module TeNjin
class KnowledgeBase
  attr_reader :search_result_knowledges, :searchings

  def initialize
    @knowledges = []
    @attributes = []

    @search_result_knowledges = []
    @searchings = []
  end

  def set_knowledges
    @knowledges = [
               {:id => 1, :name => "mikan", :attributes => [1, 3, 6, 9, 11]},
               {:id => 2, :name => "ringo", :attributes => [1, 4, 7, 10, 12]},
               {:id => 3, :name => "orange", :attributes => [1, 3, 7, 9, 11]},
               {:id => 4, :name => "banana", :attributes => [2, 5, 8, 9, 13]}
                  ]
    @attributes = [
                   {:id => 1, :name => "marui"},
                   {:id => 2, :name => "nagai"},
                   {:id => 3, :name => "orenji iro"},
                   {:id => 4, :name => "aka iro"},
                   {:id => 5, :name => "ki iro"},
                   {:id => 6, :name => "chiisai"},
                   {:id => 7, :name => "ookii"},
                   {:id => 8, :name => "hosoi"},
                   {:id => 9, :name => "amai"},
                   {:id => 10, :name => "suppai"},
                   {:id => 11, :name => "ondan chihou de toreru mono"},
                   {:id => 12, :name => "kanrei chihou de toreru mono"},
                   {:id => 13, :name => "nettai chihou de toreru mono"}
                  ]

    @search_result_knowledges = @knowledges.dup
    @searchings = []
  end

  def get_attribute_name(id)
    @attributes.each do |attr|
      return attr.name if attr.id == id
    end
    return nil
  end

  def collecting_attribute(attribute_id = nil, 
                           include = true,
                           search_knowledges = @search_result_knowledges)
    hit_knowledges = []
    attr_counter = {}
    search_knowledges.each do |knowledge|
      in_flg = false
      if attribute_id.nil?
        in_flg = true
      else
        in_flg = true if knowledge.attributes.include?(attribute_id)
      end
      if include == false
        in_flg = !in_flg
      end
      if in_flg
        hit_knowledges.push(knowledge)
        knowledge.attributes.each do |attr|
          attr_counter[attr] = 0 if attr_counter[attr].nil?
          attr_counter[attr] += 1
        end
      end
    end
    attr_count = []
    attr_counter.sort{|a, b| b[1] <=> a[1]}.each do |k, v|
      push_flg = true
      push_flg = false if k == attribute_id
      @searchings.each do |searching|
        if searching.include && searching.attribute_id == k
          push_flg = false
          break
        end
      end
      attr_count.push({:id => k, :count => v}) if push_flg
    end 
    @search_result_knowledges = hit_knowledges
    @searchings.push({:attribute_id => attribute_id, :include => include})
    return {:knowledges => hit_knowledges, :attribute_count => attr_count,
      :matched_attribute_id => {:attribute_id => attribute_id, :include => include}}
  end

end

class InferenceEngine

  def initialize
    @knowledges = KnowledgeBase.new
    @knowledges.set_knowledges
  end

  def run
    collects = @knowledges.collecting_attribute    
    attr_id = collects.attribute_count[0].id
    knowledges = nil
    while attr_id > -1
      attr_id, knowledges = next_attribute_id(attr_id, collects)
p ["next attr_id: ", attr_id]
p ["knowledges: ", knowledges]
      if knowledges.length == 1 && attr_id > -1
        attr_count = 0
        @knowledges.searchings.each do |search|
          if search.include
            if knowledges[0].attributes.include?(search.attribute_id)
              attr_count += 1
            end
          end
        end
        if (attr_count / (knowledges[0].attributes.count * 1.0)) > 0.5
          break
        end
      end
    end
    if knowledges.length > 0
      puts "sore ha " + knowledges[0].name + " dato omoi masu."
    else
      puts "sore ha watashi ha shira nai mono desu..."
    end
  end

  def next_attribute_id(attr_id, collects)
    next_knowledges = []
    puts "sore ha " + @knowledges.get_attribute_name(attr_id) + " desu ka?"
    istr = gets.chomp
    case istr.to_s.downcase
    when "yes", "ya", "y"
      collects = @knowledges.collecting_attribute(attr_id)
      if collects.empty?
        next_attr_id = -1
      else
        unless collects.attribute_count.empty?
          nattr_id = collects.attribute_count.shift.id
          if nattr_id.nil?
            next_attr_id = -1
          else
            next_attr_id = nattr_id
            next_knowledges = collects.knowledges
          end
        else
          next_attr_id = -2
        end
      end
    when "no", "n"
      collects = @knowledges.collecting_attribute(attr_id, false)
      if collects.attribute_count.empty?
        next_attr_id = -1
      else
        nattr_id = collects.attribute_count.shift.id
        if nattr_id.nil?
          next_attr_id = -1
        else
          next_attr_id = nattr_id
          next_knowledges = collects.knowledges
        end
      end
    else
      puts "Please input 'yes' or 'no'."
      return attr_id, next_knowledges
    end
    return next_attr_id, next_knowledges
  end

end
end

# ----------------
# run
#knowledges = KnowledgeBase.new
#count_attr = knowledges.collecting_attribute
#p count_attr

ie = TeNjin::InferenceEngine.new
ie.run

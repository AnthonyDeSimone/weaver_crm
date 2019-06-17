class String
  def to_tag
    parts = to_s.split('_')
    parts.each {|part| part.capitalize!}
    parts.each {|part| part.upcase! if part.downcase == "id"}
    parts.join('')
  end
  
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end

class Hash
  def symbolize_keys
    self.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end
end

class Symbol
  def to_tag
    parts = to_s.split('_')
    parts.each {|part| part.capitalize!}
    parts.each {|part| part.upcase! if part.downcase == "id"}
    parts.join('')
  end
end
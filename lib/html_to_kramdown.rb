require 'nokogiri'

class HTMLtoKramdown
  attr_reader :original


  def initialize(html_source)
    @original = html_source
    @xml = Nokogiri::HTML::DocumentFragment.parse(@original)
  end


  def to_kramdown(node=@xml,result = "")
    if node.text?
      result += node.to_s
    else 
      case node.name 
      when "p"
        result += paragraph(node)
      when /h(\d)/
        result += header(node,$1.to_i)
      when "br"
        result += newline()
      when "i","em"
        result += wrap_span(node,"_")
      when "b","strong"
        result += wrap_span(node,"**")
      when "img"
        result += image(node)
      when "blockquote"
        result += blockquote(node)
      else
        if node.children.empty?
          result += node.to_s
        else
          node.children.each do |n|
            result += to_kramdown(n)
          end
        end
      end
    end
    return node==@xml ? compress_newlines(result) : result
  end


  def compress_newlines(str)
    return str.gsub(/\n\n+/,"\n\n").strip
  end


  def render_all_children(node)
    result = ""
    node.children.each do |n|
      result += to_kramdown(n)
    end
    return result
  end


  def paragraph(node)
    result = "\n\n"
    result += render_all_children(node)
    result += "\n#{kramdownified_attributes(node)}\n\n"
  end
  

  def newline
    "<br />\n"
  end


  def header(node,lvl)
    result = "\n\n"
    result += "#" * lvl + " "
    result += render_all_children(node)
    result += "\n#{kramdownified_attributes(node)}\n\n"
  end


  def wrap_span(node,wrapper)
    result = wrapper
    result += render_all_children(node)
    result += "#{wrapper}#{kramdownified_attributes(node)}"
  end


  def image(node)
    url = node.attributes["src"]
    alt = node.attributes["alt"]
    title = node.attributes["title"]

    result = "!["
    result += "#{alt.value}" unless alt.nil?
    result += "](#{url.value}"
    node.remove_attribute("url")
    result += " '#{title.value}'" unless title.nil?
    result += ")#{kramdownified_attributes(node,"src","alt","title")}"
    return result
  end


  def kramdownified_attributes(node,*hidden_attributes)
    reduced_attributes = node.attributes.reject {|a| hidden_attributes.include? a}
    if reduced_attributes.empty?
      return
    else
      str = "{:"
      reduced_attributes.each do |k,v|
        str += " #{k}='#{v.value}'"
      end
      return str + "}"
    end
  end
end
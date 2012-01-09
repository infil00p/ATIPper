class Request < ActiveRecord::Base

  has_many :events
  has_many :documents, :through => :events
  belongs_to :agency
  belongs_to :order
  belongs_to :user


  def show_svg_description
    lines = word_wrap(self.description, :line_width => 72).split("\n")
    y_var = -345.64261
    output = ""
    lines.each do |line|
      if(line != lines[0])
        y_var += 15;
      end
      output += '<tspan x="36.751877" y="' + y_var.to_s + '" id="tspan3219" style="font-size:14.39999962px">'
      output += line
      output += '</tspan>'
    end
    output
  end

  def setOrder=(bool)
    if(bool)
      self.order = current_user.current_order
    end
  end

  # File actionpack/lib/action_view/helpers/text_helper.rb, line 217
  def word_wrap(text, *args)
    options = args.extract_options!
    unless args.blank?
      options[:line_width] = args[0] || 80
    end
    options.reverse_merge!(:line_width => 80)

    text.split("\n").collect do |line|
      line.length > options[:line_width] ? line.gsub(/(.{1,#{options[:line_width]}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end

end

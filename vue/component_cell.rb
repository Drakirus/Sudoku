#!/usr/bin/env ruby

# encoding: UTF-8

##
# Author:: Waibin Wang et Riviere Marius
# License:: MIT Licence
#
# https://github.com/Drakirus/Sudoku
#

require 'gtk3'
require_relative '../class/cell_class.rb'
##class CellView héritant (pour l'instant) de la classe Button
class CellComponent < Gtk::Button
  ##choix à faire : button, frame or widget ?

  ##variables
  attr_accessor :button #c'est le bouton que renvoie la class CellView en guise de case
  attr_accessor :cell #c'est la case de cell_class.rb
  #attr_accessor :state #peut-être vide, donnée, rempli
  ##constructeur
  #param cell : case de la grille de sudoku


  # https://developer.gnome.org/pango/stable/PangoMarkupFormat.html
  def initialize(cell)

    super()
    self.set_name "cell"
    @cell=cell
    @label = Gtk::Label.new
    @label.wrap = false
    @possibles = []
    # Grand format actuel
    @fontSize = 18
    # @label.width_chars = 2
    if(@cell.value==0)
      str = "<span  font='10'>"
      1.upto(9) do |v|
        str += "\n" if v == 4 or v == 7
        str += "<span font_family=\"Monaco\">_ </span>"
      end
      str += "</span>"
      @label.set_markup(str)
      self.add(@label)
    else
      self.add(@label)
      @label.set_markup("<span font='#{@fontSize}' ><b>#{@cell.value}</b></span>")
    end
  end

  def set_hints(possibles)
    # Monospace Fonts !!!!
    @possibles = possibles

    # Grand format actuel
    str = "<span  font='10'>"
    1.upto(9) do |v|
      str += "\n" if v == 4 or v == 7
      if possibles.include?(v)
        # str += "<span  font_family=\"Monaco\" color=\"red\" background=\"#757779\">#{v}</span>"
        # c'est moche mais c'est pour la demo

        str += "<span font_family=\"Monaco\" >#{v}</span>"

      else
        str += "<span font_family=\"Monaco\"> </span>"
      end
      str += "<span font_family=\"Monaco\"> </span>"
    end
    str += "</span>"
    @label.set_markup(str)
  end

  def addPossible(i)
    set_hints((@possibles + [i]).uniq)
  end

  def delPossible(i)
    set_hints((@possibles - [i]))
  end
  def set_color(color)
    red = color.red
    green = color.green
    blue = color.blue
<<<<<<< HEAD

    css=<<-EOT
    #cell{
      background: rgb(#{red},#{green},#{blue});
    }
    EOT
    css_provider = Gtk::CssProvider.new
    css_provider.load :data=>css
    apply_css(self,css_provider)
  end
=======
			css=<<-EOT
				#cell{
				background: rgb(#{red},#{green},#{blue});
			}
			EOT
  		css_provider = Gtk::CssProvider.new
  		css_provider.load :data=>css
  		apply_css(self,css_provider)
	end
>>>>>>> 0727e697e995a32335e81f4c38298dff8e909ba5

  def reset_color
    css=<<-EOT
    #cell{
      background: #444A58;
    }
    EOT
    css_provider = Gtk::CssProvider.new
    css_provider.load :data=>css
    apply_css(self,css_provider)
  end

  def apply_css(widget,provider)
    widget.style_context.add_provider provider,GLib::MAXUINT
    if(widget.is_a?(Gtk::Container))
      widget.each_all do |child|
        apply_css(child,provider)
      end
    end
  end

  def isPossible?(i)
    return @possibles.include?(i)
  end

  def set_value(v)
    @cell.value=v
    if(v!=0)
      @label.set_markup("<span font='#{@fontSize}' >"+v.to_s+"</span>")
    else
      @label.set_markup("")
    end
  end
end

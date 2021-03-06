#!/usr/bin/env ruby

# encoding: UTF-8

##
# Author:: DEZERE Florian
# License:: MIT Licence
#
# https://github.com/Drakirus/Sudoku
#

require 'gtk3'

class GlobalOpts

  attr_reader :selectColor, :backgroundColor, :chiffreColor,
    :surligneColor,         :erreurAutoriser, :surlignageSurvol

  @@backgroundColor="#757550507b7b"
  @@selectColor="#72729f9fcfcf"
  @@chiffreColor="#eeeeeeeeecec"
  @@surligneColor="#adad7f7fa8a8"
  @@erreurAutoriser=true
  @@surlignageSurvol=false


  def initialize()
    @backgroundColor  = @@backgroundColor.to_s
    @selectColor      = @@selectColor.to_s
    @chiffreColor     = @@chiffreColor.to_s
    @surligneColor    = @@surligneColor.to_s
    @erreurAutoriser  = @@erreurAutoriser
    @surlignageSurvol = @@surlignageSurvol
  end

  def self.getBackgroundColor()
    return @@backgroundColor
  end

  def self.setBackgroundColor(backgroundColor)
    @@backgroundColor = backgroundColor
  end

  def self.getSelectColor()
    return @@selectColor
  end

  def self.setSelectColor(selectColor)
    @@selectColor = selectColor
  end

  def self.getChiffreColor()
    return @@chiffreColor
  end

  def self.setChiffreColor(chiffreColor)
    @@chiffreColor = chiffreColor
  end

  def self.getSurligneColor()
    return @@surligneColor
  end

  def self.setSurligneColor(surligneColor)
    @@surligneColor = surligneColor
  end

  def self.setErreurAutoriser(boolean)
    @@erreurAutoriser = boolean
  end

  def self.getErreurAutoriser()
    return @@erreurAutoriser
  end

  def self.setSurlignageSurvol(boolean)
    @@surlignageSurvol = boolean
  end

  def self.getSurlignageSurvol()
    return @@surlignageSurvol
  end

  def self.serialized
    obj = GlobalOpts.new
    File.open(File.dirname(__FILE__) +"/../save_color.yaml", "w+") do |f|
      YAML.dump(obj, f)
    end
  end

  def self.load
    if File.file? File.dirname(__FILE__) +"/../save_color.yaml"
      obj = YAML.load_file(File.dirname(__FILE__) +"/../save_color.yaml")
    else
      obj = GlobalOpts.new
    end
    self.setBackgroundColor(Gdk::Color.parse(obj.backgroundColor))
    self.setSelectColor(Gdk::Color.parse(obj.selectColor))
    self.setChiffreColor(Gdk::Color.parse(obj.chiffreColor))
    self.setSurligneColor(Gdk::Color.parse(obj.surligneColor))
    self.setErreurAutoriser(obj.erreurAutoriser)
    self.setSurlignageSurvol(obj.surlignageSurvol)
  end
end

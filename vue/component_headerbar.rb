#!/usr/bin/env ruby

# encoding: UTF-8

##
# Author:: DEZERE Florian
# License:: MIT Licence
#
# https://github.com/Drakirus/Sudoku
#

require "gtk3"
require_relative './component_timer.rb'

class HeadBar

    attr_reader :header
    private_class_method :new

    def self.create(overlay, title, subtitle, compboard)
        new(overlay, title, subtitle, compboard)
    end

    def initialize(overlay, title, subtitle, compboard)
        @title, @subtitle = title, subtitle

        @header = Gtk::HeaderBar.new
        @header.show_close_button = true
        @header.title = @title
        # @header.set_has_subtitle = true
        @header.subtitle = @subtitle

        @buttonSettings = Gtk::Button.new
        iconSettings = Gio::ThemedIcon.new("emblem-system-symbolic")
        imageSettings = Gtk::Image.new(:icon => iconSettings, :size => :button)
        @buttonSettings.add(imageSettings)
        @buttonSettings.signal_connect "clicked" do
          unless overlay.isOverlayVisible?
            @time.toggle
            overlay.cleanOverlay
            option = Option.new
            overlay.addToOverlay option
            overlay.showOverlay

            option.signal_retour do
              @time.toggle
              overlay.hideOverlay
              compboard.updateBoardColor
            end
          end
        end
        @header.pack_end(@buttonSettings)

        @btnNewGame = Gtk::Button.new
        iconNewGame = Gio::ThemedIcon.new("appointment-new-symbolic")
        imageNewGame = Gtk::Image.new(:icon => iconNewGame, :size => :button)
        @btnNewGame.add(imageNewGame)
        @btnNewGame.signal_connect "clicked" do
          unless overlay.isOverlayVisible?
            @time.toggle

            newgame = NewGame.new
            overlay.cleanOverlay
            overlay.addToOverlay newgame
            overlay.showOverlay

            newgame.signal_retour do
              if newgame.board
                compboard.updateBoard newgame.board
                @time.raz
              end
              @time.toggle
              overlay.cleanOverlay
              overlay.hideOverlay
              overlay.raz_cursor
            end
          end
        end
        @header.pack_end(@btnNewGame)

        @buttonSuivant = Gtk::Button.new
        imageSuivant = Gtk::Image.new(:icon_name => "edit-undo-symbolic", :size => :button)
        @buttonSuivant.add(imageSuivant)
        @header.pack_start(@buttonSuivant)

        @buttonPrecedent = Gtk::Button.new
        imagePrecedent = Gtk::Image.new(:icon_name => "edit-redo-symbolic", :size => :button)
        @buttonPrecedent.add(imagePrecedent)
        @header.pack_start(@buttonPrecedent)

        labelTime = Gtk::Label.new
        @time = Timer.create labelTime
        # @time.toggle

        @buttonTime = Gtk::Button.new
        iconTime = Gio::ThemedIcon.new("alarm-symbolic.symbolic")
        imageTime = Gtk::Image.new(:icon => iconTime, :size => :button)
        @buttonTime.signal_connect("clicked") do
          @time.toggle
          if @time.running
            overlay.cleanOverlay
            # label = Gtk::Label.new("<span weight='ultrabold' font='40'>Pause</span>")
            # label.use_markup = true
            # overlay.addToOverlay label
            overlay.showOverlay
          else
            overlay.hideOverlay
          end
        end
        @buttonTime.add(imageTime)
        @header.pack_start(@buttonTime)
        @header.pack_start(labelTime)

        return @header
    end

    def setVisibleSettings(b)
        if b
            @header.pack_end(@buttonSettings)
        else
            @header.remove(@buttonSettings)
        end
    end

    def setVisibleSuivant(b)
        if b
            @header.pack_start(@buttonSuivant)
        else
            @header.remove(@buttonPrecedent)
        end
    end

    def setVisiblePrecedent(b)
        if b
            @header.pack_start(@buttonPrecedent)
        else
            @header.remove(@buttonPrecedent)
        end
    end

    def setVisibleTimer(b)
        if b
            @header.pack_start(@labelTime)
        else
            @header.remove(@labelTime)
        end
    end
end
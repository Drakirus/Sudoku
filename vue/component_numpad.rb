require 'gtk3'

Dir[File.dirname(__FILE__) + '../class/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '*.rb'].each {|file| require file }


class NumpadComponent < Gtk::Frame
  #variables
  attr_accessor :value #valeur retourner
  attr_reader :statut #gère l'édition des cases : indice ou valeur

  private_class_method :new

  #méthode d'instance
  def NumpadComponent.create panel
    new(panel)
  end

  def initialize panel
    super()
    @panel=panel
    @value=0
    table = Gtk::Table.new(9,6,true)

    numButtons=Array.new(3){Array.new(3)}

    0.upto(2){|y|
      0.upto(2){|x|
        val=x+y*3+1
        numButtons[x][y]=Gtk::Button.new(:label=>val.to_s, :use_underline => true)
        numButtons[x][y].signal_connect("clicked"){
          @value=val
          @panel.recupereNumber(@value)
        }
        table.attach(numButtons[x][y],2*x,2*(x+1),2*y,2*(y+1))
      }
    }

    buttonPen = Gtk::RadioButton.new "Stylo"
    buttonPen.signal_connect('clicked'){@statut=true}


    buttonFullPossibilities = Gtk::Button.new(:label=>"ajouter tous les indices !", :use_underline => true)
    buttonFullPossibilities.signal_connect('clicked'){
      cells = @panel.grid.board.unusedCells
      cells.each do |cell|
        possibles = @panel.grid.board.possibles(cell)
        @panel.grid.cellsView[cell.row][cell.col].set_hints(possibles)
      end


    }


    buttonCrayon = Gtk::RadioButton.new buttonPen,"Crayon"
    buttonCrayon.signal_connect('clicked'){@statut=false}

    buttonGomme = Gtk::Button.new(:label=>"gomme", :use_underline => true)
    buttonGomme.signal_connect('clicked'){
        @panel.recupereNumber(0)
    }

    table.attach(buttonPen,0,2,7,8)
    table.attach(buttonCrayon,2,4,7,8)
    table.attach(buttonGomme,4,6,7,8)
    table.attach(buttonFullPossibilities,0,6,8,9)
    add(table)

    show_all()
  end

end

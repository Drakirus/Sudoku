#!/usr/bin/env ruby

# encoding: UTF-8

##
# Author:: CHAMPION Pierre
# License:: MIT Licence
#
# https://github.com/Drakirus/Sudoku
#

#:nodoc:
require_relative './cell_class.rb'
require 'yaml'

# === Gestion de cases dans une planche de Sudoku
# === Variables d'instance
# - +rows+	  -> (*PRIVATE*) Hash des lignes<br>
# - +columns+ -> (*PRIVATE*) Hash des colonnes<br>
# - +boxes+		-> (*PRIVATE*) Hash des "familles" des boxes<br>
# - +cells+	  -> (*PRIVATE*) Tableau des valeurs des Cell
#
class Board
  attr_accessor :difficulty, :time
  attr_reader :bUseSolution, :bMakeError
  def initialize(numbers)#:nodoc:
    # Hash
    @rows = {}
    @columns = {}
    @boxes = {}
    # Tableau
    @cells = []
    @time = 0
    @bUseSolution = false
    @bMakeError = false


    # parcourir les cases du Sudoku
    9.times do |row|

      9.times do |col|

        # le num de la box
        box= (3 * (row / 3)) + (col / 3)

        cell = Cell.creer(row, col, box)

        # valeur initial
        if numbers==nil
          cell.value = 0
        else
          cell.value = numbers.pop
        end

        # Met des tableaux dans les hashs (INIT)
        @rows[row] = [] if !@rows.has_key?(row)
        @columns[col] = [] if !@columns.has_key?(col)
        @boxes[box] = [] if !@boxes.has_key?(box)

        # Ajout des cases dans les conteneurs
        @rows[row] << cell
        @columns[col] << cell
        @boxes[box] << cell
        @cells << cell

      end
    end
  end

  # Représentation d'une planche
  # * *Arguments*    :
  #   - +numbers+ -> Liste des numbre a mettre dans la planche
  # * *Returns*
  #   - Board
  # * Exemple
  #    planche_base="
  #    0 2 3   4 5 6   7 8 9
  #    4 5 6   7 8 9   1 2 3
  #    7 8 9   1 2 3   4 5 6
  #
  #    2 1 4   3 6 5   8 9 7
  #    3 6 5   8 9 7   2 1 4
  #    8 9 7   2 1 4   3 6 5
  #
  #    5 3 1   6 4 2   9 7 8
  #    6 4 2   9 7 8   5 3 1
  #    9 7 8   5 3 1   6 4 2
  #    "
  #    x = Board.creer(planche_base.delete("\s|\n")
  #      .split("").reverse.map(&:to_i))
  #    print x
  def self.creer(numbers=nil)
    new(numbers)
  end
  private_class_method :new


  include Comparable
  # Méthode de comparaison entre différente instance de Board
  # * *Arguments*    :
  #   - +other+ -> autre Board a compare
  # * *Returns*
  #   - true/false
  def ==(other)
    each_with_coord do |cell,i,j|
      if cell!=other.cellAt(i,j)
        return false
      end
    end
    return true
  end

  # Obtenir la Cell a la place coordonne
  # * *Arguments*    :
  #   - +i+ -> la ligne
  #   - +j+ -> la colonne
  # * *Returns*
  #   - Cell
  def cellAt(i,j)
      @rows[i][j]
  end

  # iterateur qui loop sur les cases
  # avec comme information la case, ligne, colonne, boxe
  def each_with_coord
    9.times do |i|
      9.times do |j|
        yield @rows[i][j], i, j, @rows[i][j].box
      end
    end
  end

  # Obtenir les Cell qui sont défini.
  # * *Returns*
  #   - Array of Cell
  def usedCells
    @cells.inject([]) do |result, cell|
      result << cell if not cell.vide?
      result
    end
  end

  # Obtenir les Cell qui sont vide.
  # * *Returns*
  #   - Array of Cell
  def unusedCells
    @cells.inject([]) do |result, cell|
      result << cell if cell.vide?
      result
    end
  end

  # Obtenir les Cell de meme value dans la planche
  # * *Arguments*
  #   - +Cell+ -> cell (Valeur)
  # * *Returns*
  #   - Array of Cell
  def sameCellsValue(cellArg)
    @cells.inject([]) do |result, cell|
      result << cell if cell.value == cellArg.value
      result
    end
  end

  # Retourne toutes les Cell sur la meme *ligne* *colonne* et *boxe* d'une Cell.
  # * *Arguments*    :
  #   - +cell+ -> Cell du puzzle
  # * *Returns*
  #   - Array of Cell
  def linked(cell)
    @rows[cell.row] + @columns[cell.col] + @boxes[cell.box]
  end

  # Retourne toutes les valeurs qu'une Cell *Ne-peut-pas* prendre.<br>
  # *Valeur-de-la-Cell-exclu*
  # * *Arguments*    :
  #   - +cell+ -> Cell du puzzle
  # * *Returns*
  #   - Array of numbers
  def excluded(cell)
    excluded = linked(cell).inject([]) do |result, cellloop|
      result << cellloop.value if not cellloop.vide?
      result
    end
    excluded.uniq - [cell.value]
  end

  # Retourne toutes les valeurs qu'une Cell peut prendre.
  # * *Arguments*    :
  #   - +cell+ -> Cell du puzzle
  # * *Returns*
  #   - Array of numbers
  def possibles(cell)
    ((1..9).to_a - excluded(cell))
  end

  # Echange 2 lignes d'une planche.
  # * *Arguments*    :
  #   - +index_row1+ -> num de la ligne
  #   - +index_row2+ -> num de la ligne2
  #   - +force+ -> si true autorise les swap entre boxes {rdoc-image:data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAA8FBMVEX//////wCQkJAwMDBxcQAAAADe3gD9/QDT09OsrKzz8/P6+gD//zGpqans7AD//1X6+vbm5r36+nvW1gBlZRkrKzOCgoLs7JhiYmMpKSLr69uIiIj//yP//3xZWVne3q8qKi2qqgFsbC0aGhpTUycbGw9raxfy8prz8+je3rhkZAAYGBze3qnPzxEFBR1ZWSbAwADU1Iizsz5+fgHt7VE/PxnT08ZDQ0NwcHDHx8efnwC3txSRkQPCwlrz8zJMTFB3dxzl5eU3Nz/S0lH//0uQkD3Y2Gm9vT2Dg10yMgAAAAyjo2lTUw08PAAKCgCBgVBOcdPBAAABFklEQVQokW2Qf1eCMBSGd61JtAElFbShQWaFRFFoomVlpaX9+v7fJjY0Hfb8s5295z33uUNoARuO++gfmPP68lwZrQdhjZpPvrGWsDNLM4PDhr6tvu/s1igQe2//YEsNzh1LAzCDlmuolaM6fUgSah83uVJhjuU94tkPCXx1SlinBGM8BfvUX60IJfKN8ReoYoWSbKhiUkn7xDgtieVKANoHnk0gryzFmNwBqq2pOMylWCgKALT3LgLyJyaURAADWx4LMakk8N7SDshKIVb8Uk58iU/mFSl2UUxYCUh8FeVTri0PNIF3k3bkhSTtZmagoUeqBeb8Et93o4wjdjfYVGl3I9flCN1mvY0SDTfTxSb9SgnO9dEv8K0fkCJzF2cAAAAASUVORK5CYII=}[http://coucou/]
  # * *Returns*
  #   - Board
  def swapRow(index_row1, index_row2, force=false)
    swap(index_row1, index_row2, @rows, force)
  end


  # Echange 2 colonnes d'une planche.
  # * *Arguments*    :
  #   - +index_columns1+ -> num de la colonne
  #   - +index_columns2+ -> num de la colonne2
  #   - +force+ -> si true autorise les swap entre boxes {rdoc-image:data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAA8FBMVEX//////wCQkJAwMDBxcQAAAADe3gD9/QDT09OsrKzz8/P6+gD//zGpqans7AD//1X6+vbm5r36+nvW1gBlZRkrKzOCgoLs7JhiYmMpKSLr69uIiIj//yP//3xZWVne3q8qKi2qqgFsbC0aGhpTUycbGw9raxfy8prz8+je3rhkZAAYGBze3qnPzxEFBR1ZWSbAwADU1Iizsz5+fgHt7VE/PxnT08ZDQ0NwcHDHx8efnwC3txSRkQPCwlrz8zJMTFB3dxzl5eU3Nz/S0lH//0uQkD3Y2Gm9vT2Dg10yMgAAAAyjo2lTUw08PAAKCgCBgVBOcdPBAAABFklEQVQokW2Qf1eCMBSGd61JtAElFbShQWaFRFFoomVlpaX9+v7fJjY0Hfb8s5295z33uUNoARuO++gfmPP68lwZrQdhjZpPvrGWsDNLM4PDhr6tvu/s1igQe2//YEsNzh1LAzCDlmuolaM6fUgSah83uVJhjuU94tkPCXx1SlinBGM8BfvUX60IJfKN8ReoYoWSbKhiUkn7xDgtieVKANoHnk0gryzFmNwBqq2pOMylWCgKALT3LgLyJyaURAADWx4LMakk8N7SDshKIVb8Uk58iU/mFSl2UUxYCUh8FeVTri0PNIF3k3bkhSTtZmagoUeqBeb8Et93o4wjdjfYVGl3I9flCN1mvY0SDTfTxSb9SgnO9dEv8K0fkCJzF2cAAAAASUVORK5CYII=}[http://coucou/]
  # * *Returns*
  #   - Board
  def swapColumns(index_columns1, index_columns2, force=false)
    swap(index_columns1, index_columns2, @columns, force)
  end

  # Echange 2 conteneur d'une planche.
  # * *Arguments*    :
  #   - +index_columns1+ -> num de la index
  #   - +index_columns2+ -> num de la index
  #   - +force+ -> si true autorise les swap entre boxes {rdoc-image:data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAA8FBMVEX//////wCQkJAwMDBxcQAAAADe3gD9/QDT09OsrKzz8/P6+gD//zGpqans7AD//1X6+vbm5r36+nvW1gBlZRkrKzOCgoLs7JhiYmMpKSLr69uIiIj//yP//3xZWVne3q8qKi2qqgFsbC0aGhpTUycbGw9raxfy8prz8+je3rhkZAAYGBze3qnPzxEFBR1ZWSbAwADU1Iizsz5+fgHt7VE/PxnT08ZDQ0NwcHDHx8efnwC3txSRkQPCwlrz8zJMTFB3dxzl5eU3Nz/S0lH//0uQkD3Y2Gm9vT2Dg10yMgAAAAyjo2lTUw08PAAKCgCBgVBOcdPBAAABFklEQVQokW2Qf1eCMBSGd61JtAElFbShQWaFRFFoomVlpaX9+v7fJjY0Hfb8s5295z33uUNoARuO++gfmPP68lwZrQdhjZpPvrGWsDNLM4PDhr6tvu/s1igQe2//YEsNzh1LAzCDlmuolaM6fUgSah83uVJhjuU94tkPCXx1SlinBGM8BfvUX60IJfKN8ReoYoWSbKhiUkn7xDgtieVKANoHnk0gryzFmNwBqq2pOMylWCgKALT3LgLyJyaURAADWx4LMakk8N7SDshKIVb8Uk58iU/mFSl2UUxYCUh8FeVTri0PNIF3k3bkhSTtZmagoUeqBeb8Et93o4wjdjfYVGl3I9flCN1mvY0SDTfTxSb9SgnO9dEv8K0fkCJzF2cAAAAASUVORK5CYII=}[http://coucou/]
  #   - +conteneur+ -> @rows, @columns
  # * *Returns*
  #   - Board
  private def swap(index1, index2, conteneur, force=false)
    if index1 / 3 != index2 / 3 and force == false
      raise "Tried to swap non-boxed #{conteneur.class}"
    end
    for x in (0..(conteneur[index2]).length-1) do
      temp = conteneur[index1][x].value
      conteneur[index1][x].value = conteneur[index2][x].value
      conteneur[index2][x].value = temp
    end
    return self
  end

  # Echange 2 groupe de colonnes d'une planche.
  # * *Arguments*    :
  #   - +index1+  -> num du groupe de colonne1
  #   - +index2+  -> num du groupe de colonne2
  # * *Returns*
  #   - Board
  def swapStack(index1, index2)
    boxesLoop{ |v| swapColumns(index1 * 3 + v, index2 * 3 + v, true) }
  end

  # Echange 2 groupe de lignes d'une planche.
  # * *Arguments*    :
  #   - +index1+  -> num du groupe de ligne1
  #   - +index2+  -> num du groupe de ligne2
  # * *Returns*
  #   - Board
  def swapBand(index1, index2)
    boxesLoop{ |v| swapRow(index1 * 3 + v, index2 * 3 + v, true) }
  end

  # Permet de parcourir les boxes. DRY
  private def boxesLoop
    3.times do |v|
      yield v
    end
  end

  # Copie la planche.
  # * *Returns*
  #   - Board (indépendant)
  def copie
    values = []
    9.times do |index|
      @rows[index].each do |cell|
        values << cell.value
      end
    end
    res = Board.creer(values.reverse)
    self.each_with_coord do |cell,i,j|
      if cell.freeze?
        res.cellAt(i,j).freeze
      end
    end
    return res
  end


  # Vérifie que la planche est valide.
  # * *Returns*
  #   - true/false
  def valid?
    valid = (0..9).to_a
    # parcourir tours le conteneurs
    [@rows, @columns, @boxes].each do |set|
      # pour chaque lignes, colonnes, boxes
      9.times do |index|
        # creation d'un tableau des valeurs
        values = []
        set[index].each do |cell|
          values << cell.value
        end

        # une case de meme valeur par set (oublie le 0)
        if not (values.select { |e| values.count(e) > 1 } - [0]).empty?
          return false
        end
        # Touts les chiffre sont des chiffre possibles
        if not (values - valid).length == 0
          return false
        end
      end
    end
    true
  end

  # Vérifie que la planche est Fini et valide (VICTOIRE).
  # * *Returns*
  #   - true/false
  def complete?
     unusedCells.length == 0 and valid?
  end

  # Une fois la grille générer les valeurs pas défaut sont inchantable
  def freeze
    each_with_coord do |cell|
      cell.freeze if not cell.vide?
    end
    return self
  end

  # création d'une représentation en chaine de caractères.
  # * Exemple
  #    1 2 3   4 5 6   7 8 9
  #    4 5 6   7 8 9   1 2 3
  #    7 8 9   1 2 3   4 5 6
  #
  #    2 1 4   3 6 5   8 9 7
  #    3 6 5   8 9 7   2 1 4
  #    8 9 7   2 1 4   3 6 5
  #
  #    5 3 1   6 4 2   9 7 8
  #    6 4 2   9 7 8   5 3 1
  #    9 7 8   5 3 1   6 4 2
  def to_s
    output = "\n"
    9.times do |index|
      @rows[index].each_with_index do |cell, indextab|
        output += "  " if indextab % 3 == 0
        if cell.value != 0
          output += cell.value.to_s
        else
          output += "_"
        end
        output +=  " "
      end
      output += "\n"
      output += "\n" if index % 3 == 2
    end
    return output
  end

  # Serialize une planche.
  # * *Arguments*    :
  #   - +nameFic+  -> le nom du fichier pour la sauvegarde
  def serialized(nameFic)
    # file = File.open(nameFic, "w+")
    # puts("Coucou je serialize")
    # jsonSave = YAML::dump(self)
    # file.write(jsonSave)
    # file.close

    File.open(nameFic, "w+") do |f|
      # Marshal.dump(self, f)
      YAML.dump(self, f)
    end
  end

  # Serialize une planche.
  # * *Arguments*    :
  #   - +nameFic+  -> le nom du fichier pour la sauvegarde
  # * *Returns*      :
  #   - le fichier chargé et convertit en langage machine
  def self.unserialized(nameFic)
    # file = File.open(nameFic, "r")
    # jsonSave = file.read
    # data = JSON.parse(json)
    # self = data
    return YAML.load_file(nameFic)
    # return Marshal.load(File.read(nameFic))
  end

  # tabs des snapshot
  @@images_undo = []
  @@images_redo = []

  # new branch in undo history
  @@newbrach = true

  # Serialize une planche dans une file de snapshot
  # permet undo redo
  def snapshot
    if not @@images_redo.empty? and @@newbrach
      @@images_undo << @@images_redo.last
      @@newbrach = false
    end
    @@images_undo << Marshal.dump(self)
    return @@images_undo.length
  end

  # get last undo
  def retrive_undo
    if not @@images_undo.empty?
      img = @@images_undo.pop
      board = Marshal.load(img)
      @@images_redo << img
      @@newbrach = true
      if board == self
        board = retrive_undo
      end
      return board
    else
      print "end undo list\n"
      self
    end
  end

  # get last redo
  def retrive_redo
    if not @@images_redo.empty?
      img = @@images_redo.pop
      board = Marshal.load(img)
      @@images_undo << img
      if board == self
        board = retrive_redo
      end
      return board
    else
      print "end redo list\n"
      self
    end
  end

  def hasUseSolution
    @bUseSolution = true
  end

  def hasMakeError
    @bMakeError = true
  end
end

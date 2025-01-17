require_relative 'label'
require_relative 'item'
require_relative 'game'
require_relative 'book'
require_relative 'author'
require_relative 'genre'
require_relative 'music_album'
require 'date'
require 'json'

class App
  attr_accessor :genre, :author, :source, :label, :publish_date, :cover_state, :choice, :labels, :books, :games
  attr_reader :id, :archived

  GameTemplate = Struct.new(:genre, :author, :source, :label, :publish_date)

  def initialize
    @labels = []
    @books = []
    @genres = []
    @music_album = []
    @games = []
  end

  def list_all_genres
    if @genres.empty?
      puts 'No genre exists '
    else
      @genres.each do |genre|
        puts 'Genres: '
        puts "        #{genre.name}"
      end
    end
  end

  def genre_options
    genre_name = gets.chomp
    genre = Genre.new(genre_name)
    @genres << genre
  end

  def list_all_labels
    if @labels.empty?
      puts 'No labels found'
    else
      @labels.each do |label|
        puts "Title: #{label.title} | Color: #{label.color}"
      end
    end
  end

  def create_album
    print 'Music genre: '
    genre = genre_options
    print 'Music Artist: '
    author = gets.chomp
    print 'Music Source: '
    source = gets.chomp
    print 'Add Music Label: '
    label = label_options
    print 'Music production date (yyyy-mm-dd): '
    production_date = gets.chomp
    on_spotify = on_spotify_option
    music_album = Struct.new(:genre, :author, :source, :label, :publish_date)
    album_info = music_album.new(genre, author, source, label, production_date)
    album = Album.new(album_info, on_spotify: on_spotify)
    @music_album << {
      id: album.id,
      genre: album_info.genre[0].name,
      author: album_info.author,
      source: album_info.source,
      label: album_info.label[0].title,
      date: album_info.publish_date,
      on_spotify: on_spotify
    }
    puts 'Album created successfully'
  end

  def on_spotify_option
    print 'Is Music on Spotify? '
    print 'Yes/No: '
    on_spotify = gets.chomp
    check_spotify(on_spotify)
  end

  def check_spotify(on_spotify)
    case on_spotify.downcase
    when 'yes'
      true
    when 'no'
      false
    else
      puts 'Invalid input, please try again'
      on_spotify_option
    end
  end

  def save_data
    all_data = [@genres, @music_album, @books, @labels]
    file_paths = ['./genre.json', './music_album.json', './books.json', './labels.json']

    all_data.zip(file_paths).each do |data, file_path|
      saver = JsonHandler.new(data, file_path)
      saver.save
    end
    puts 'Data saved successfully'
  end

  class JsonHandler
    def initialize(data, file_path)
      @data = data
      @file_path = file_path
    end

    def save
      opts = {
        array_nl: "\n",
        object_nl: "\n",
        indent: '  ',
        space_before: ' ',
        space: ' '
      }

      existing_data = []
      if File.file?(@file_path)
        file_data = File.read(@file_path)
        existing_data = JSON.parse(file_data) unless file_data.strip.empty?
      end

      existing_data += if existing_data.is_a?(Array)
                         @data.map(&:to_hash)
                       else
                         [@data.map(&:to_hash)]
                       end

      File.write(@file_path, JSON.pretty_generate(existing_data, opts))
    end
  end

  def load_data_from_file(file_path)
    return puts 'No data availabe' unless file_exists?(file_path)

    file_data = read_file_data(file_path)
    return puts 'No data availabe' if file_data.empty?

    saved_data = JSON.parse(file_data, symbolize_names: true)
    handler_for(file_path).call(saved_data)
  end

  def list_all_music_albums
    if @music_album.empty?
      puts 'No album found'
    else
      puts '---------------Albums---------------'
      @music_album.each do |album|
        puts "Genre: #{album.genre[0].name} Author: #{album.author}  Publication: #{album.publish_date} Spotify: #{album.source}"
      end
    end
  end

  def create_book
    print "Book's genre: "
    @genre = genre_options
    print "Book's author: "
    author = gets.chomp
    print "Book's source: "
    source = gets.chomp
    print "Book's label title: "
    label = label_options
    print "Book's publish date (yyyy-mm-dd): "
    publish_date = gets.chomp
    print "Book's publisher: "
    publisher = gets.chomp
    print "Book's cover state (good/bad): "
    cover_state = gets.chomp
    book = Book.new({ genre: @genre[0].name, author: author, source: source, label: label[0].title, publish_date: publish_date,
                      publisher: publisher, cover_state: cover_state })
    books.push(book)
    puts 'Book created succesfully', ''
  end

  def label_options
    label_title = gets.chomp
    print "Label's color: "
    label_color = gets.chomp
    label = Label.new(label_title, label_color)
    labels.push(label)
  end

  def game_info_g
    puts 'Genre: '
    genre = gets.chomp
    puts 'Author: '
    author = gets.chomp
    puts 'Source: '
    source = gets.chomp
    puts 'Label: '
    label = gets.chomp
    puts 'Publish Date[yyyy-mm-dd]: '
    date = gets.chomp
    GameTemplate.new(genre, author, source, label, date)
  end

  def create_game
    game_info = game_info_g
    puts 'Is it a multiplayer game?[y/n]: '
    answer = gets.chomp
    multiplayer = false
    multiplayer = true if answer == 'y'
    puts 'When was the game last played[yyyy-mm-dd]?: '
    last_played_at = gets.chomp
    game = Game.new(game_info, multiplayer, last_played_at)
    @games << {
      id: game.id,
      genre: game_info.genre,
      author: game_info.author,
      source: game_info.source,
      label: game_info.label,
      date: game_info.publish_date,
      multiplayer: multiplayer,
      last_played_at: last_played_at
    }
    puts 'Grame created successfully!'
  end

  def list_games
    @games.each_with_index do |game, index|
      puts "-------------Game #{index + 1}-------------"
      puts "Genre: #{game[:genre]}"
      puts "Author: #{game[:author]}, Source: #{game[:source]}, Label: #{game[:label]}"
      puts "Date: #{game[:date]}, Multiplayer: #{game[:multiplayer]}, Last Played Date: #{game[:last_played_at]}"
      puts '-------------------------------------------'
    end
  end

  def list_all_authors
    puts '————-List of authors—————'
    @games.each_with_index do |game, index|
      puts "#{index}: #{game[:author]}"
    end
  end

  def add_games_from_file(arr)
    @games += arr if arr != []
  end
end

def file_exists?(file_path)
  File.file?(file_path)
end

def read_file_data(file_path)
  File.read(file_path).strip
end

def handler_for(file_path)
  {
    './labels.json' => ->(data) { handle_labels_data(data) },
    './books.json' => ->(data) { handle_books_data(data) },
    './music_album.json' => ->(data) { handle_music_album_data(data) },
    './genre.json' => ->(data) { handle_genre_data(data) }
  }.fetch(file_path, ->(_) {})
end

def handle_labels_data(data)
  labels_titles = data.map { |label| { color: label[:color], title: label[:title] } }
  puts(labels_titles.map { |label| "#{label[:title]} (#{label[:color]})" })
end

def handle_books_data(data)
  books_titles = data.map { |book| { genre: book[:genre], author: book[:author] } }
  puts(books_titles.map { |book| "Author:#{book[:author]} | Genre:#{book[:genre]}" })
end

def handle_music_album_data(data)
  music_albums = data.map { |album| { author: album[:author], date: album[:date], on_spotify: album[:on_spotify] } }
  puts(music_albums.map do |album|
         "Author:#{album[:author]} | Publish date: #{album[:date]} | On Spotify?:#{album[:on_spotify]}"
       end)
end

def handle_genre_data(data)
  genre_data = data.map { |genre| { name: genre[:name] } }
  puts(genre_data.map { |genre| genre[:name].to_s })
end

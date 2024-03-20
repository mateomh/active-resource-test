class Pokemon < ActiveResource::Base
  self.site = 'https://pokeapi.co/api/v2/'
  self.include_format_in_path = false

  def self.collection_path(prefix_options = {}, query_options = nil)
    # This overrides the path to get a collection of elements
    'pokemon'
  end

  def self.element_path(id, prefix_options = {}, query_options = {})
    # This overrides the path to get a single element
    "pokemon/#{id}"
  end

  def load(attributes, remove_root = false, persisted = false)
    # This determines which attributes are loaded to the object from the
    # response data
    if attributes.is_a?(Hash)
      attributes = attributes.slice(
        'id',
        'url',
        'name',
        'abilities',
        'base_experience',
        'cries',
        'game_indices',
        'forms',
        'height',
        'weight',
        'moves',
        'types',
        'stats',
        'sprites',
        'order'
      )
    end
    super(attributes, remove_root, persisted)
  end

  def self.find(*arguments)
    # This overrides the find method used to look for elements
    # The find method is used all the time, the methods
    # Pokemon.all, Pokemon.first, Pokemon.last, Pokemon.where
    # are just wrappers of the .find method
    scope = arguments.slice!(0)
    options = arguments.slice!(0) || {}

    case scope
      when :all
        find_every(options)
      when :first
        collection = find_every(options)
        collection && collection.first
      when :last
        collection = find_every(options)
        collection && collection.last
      else
        find_single(scope)
    end
  end

  private

  def self.find_every(options)
    response = self.connection.get("#{site}#{collection_path}")
    parsed_response = parse_response(response)
    # Creates the collection of Pokemon objects
    instantiate_collection(parsed_response || [])
  end

  def self.find_single(id)
    response = self.connection.get("#{site}#{element_path(id)}")
    parsed_response = parse_response(response)
    # Creates an instance of the Pokemon object
    instantiate_record(parsed_response)
  end

  def self.parse_response(response)
    parsed_response = JSON.parse(response.body)

    # This logic is based on the structure of the response from
    # the poke api, it has to be adjusted if the response has a
    # special format like in this case where the collection comes
    # under the results key but for a single pokemon the full
    # response has the data
    if parsed_response['results'].is_a?(Array)
      parsed_response['results']
    else
      parsed_response
    end
  end
end
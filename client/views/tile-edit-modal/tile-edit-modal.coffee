#
#   Template.tileEditModal
#
###
Template.tileEditModal.categories = ->
  console.log "hi"
  cats = Tiles.find({owner: Meteor.userId()}).fetch().map (it) ->
    return it.category
  console.log cats
  return cats
###
Template.tileEditModal.helpers
  'settings': ->
    return {
      position: top
      limit: 5
      rules: [
        collection: Tiles
        field: "category"
        template: Template.categoryResult
        selector: map (it) ->
          return it.category
      ]
    }
Template.tileEditModal.rendered = ->
  #Meteor.typeahead.inject()
  instantiateTileEditModal @
Template.tileEditModal.events
  'click #save-tile-edit': (event, template) ->
    tileEditModal.showLoading()
    _tile = tileEditModal.getTile() # get user's changes
    if _tile.errors?  #Something critical like a title or category is missing!  Abort save.
      for e in _tile.errors
        toast e, 6500, "danger"
      return false
    else # Save that shit!
      if !_tile._id?  # tile is new!
        pos = {}
        k = 0
        for cat, i in @categories
          if cat.title is _tile.category
            _tile.pos =
              category: i
              tile: cat.tiles.length
            break
          else
            k++
        if !_tile.pos? # no matching category!  add tile in last category, first tile position.
          _tile.pos =
            category: k
            tile: 0
      _id = _tile._id
      delete _tile['_id']
      Meteor.call "saveTile", _tile, _id, (error, response) ->
        if error
          toast "Error saving tile: #{error}", 6000, "danger"
          tileEditModal.hideLoading()
        else
          toast "Tile saved successfully!", 4000, "success"
          tileEditModal.close()
    return false
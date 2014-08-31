Polymer 'wl-chat',
  chat: {title: "Unknown", messages: [{name: "System", msg: "Waiting for data..."}], members: {}}
  keys: (o)->
    return [] if !o?
    Object.keys o
  stringify: (o)->
    JSON.stringify o
  chatValue: ""
  change: _.debounce((event)->
    if document.activeElement is this
      field = @shadowRoot.querySelector('paper-input')
      msg = @chatValue
      field.inputValue = ""
      field.commit()
      $("wl-chat").blur()
      $("body").focus()
      this.fire('sendchat', {message:msg})
  , 500, {leading: true, trailing: false})

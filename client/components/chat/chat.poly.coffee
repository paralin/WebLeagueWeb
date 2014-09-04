Polymer 'wl-chat',
  chat: {title: "Unknown", messages: [{name: "System", msg: "Waiting for data..."}], members: {}}
  keys: (o)->
    return [] if !o?
    Object.keys o
  stringify: (o)->
    JSON.stringify o
  chatValue: ""
  keypressHandler: (event, detail, sender)->
    if event.keyCode == 13
      field = @shadowRoot.querySelector('paper-input')
      msg = field.inputValue
      field.inputValue = ""
      field.commit()
      #$("wl-chat").blur()
      #$("body").focus()
      if msg isnt ""
        this.fire('sendchat', {message:msg})

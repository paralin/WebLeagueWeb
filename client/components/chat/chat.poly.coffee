timeout = null
Polymer 'wl-chat',
  observe:
    'chat.messages': 'scrollDown'
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
  scrollDown: ->
    element = @shadowRoot.querySelector(".msg-container")
    if timeout?
      clearTimeout timeout
    timeout = setTimeout(->
      if element.scrollTop > element.scrollHeight-element.clientHeight-50
        element.scrollTop = element.scrollHeight-element.clientHeight
    , 5)

Polymer 'wl-chat',
  chat: {title: "Unknown", messages: [{name: "System", msg: "Waiting for data..."}], members: {}}
  keys: (o)->
    return [] if !o?
    Object.keys o
  stringify: (o)->
    JSON.stringify o
  chatMessageInput: ""

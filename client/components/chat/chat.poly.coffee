Polymer 'wl-chat',
  chat: {title: "Unknown", messages: [{name: "System", msg: "Waiting for data..."}], members: {}}
  keys: (o)->
    console.log o
    Object.keys o
  stringify: (o)->
    console.log JSON.stringify o
    JSON.stringify o

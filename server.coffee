express = require 'express'

app = express()

app.use express.logger()
app.use express.static(__dirname + '/public')

app.listen 1618
console.log 'Listening on port 1618'


###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")
roots = require("roots-express")
assets = require("connect-assets")
roots.add_compiler assets

app = express()
app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use assets()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

routes.set app
server = http.createServer(app).listen(app.get("port"), ->
  console.log "Server listening on port " + app.get("port") + "\n Control + C to stop"
)
roots.watch server
exports.set = (app) ->
  app.get "/", homePage
  
###
GET home page.
### 
homePage = (req, res) ->
  res.render "index",
    title: "Express"
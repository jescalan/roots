fs        = require("fs")
Path      = require("path")
rootPath  = Path.resolve(__dirname, 'rage')

module.exports = ->
  @When /^I replace "([^"]*)" with "([^"]*)"$/, (filePath, content) ->
    fs.writeFileSync(Path.join(rootPath, filePath), content)

  @Then /^I should see a "([^"]*)" tag with "([^"]*)"$/, (tag, content) ->
    new @Widget({root: tag}).read("span").should.eventually.eql(content)

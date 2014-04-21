test_tpl_name = 'roots-testing-template'
test_tpl_path = 'https://github.com/jenius/sprout-test-template.git'

describe 'template', ->

  describe 'add', ->

    it 'should error if only given a name', ->
      Roots.template.add(name: 'wow').should.be.rejected

    it 'should error if given a name and uri, but uri is invalid', ->
      Roots.template.add(name: 'wow', uri: 'fail').should.be.rejected

    it 'should add a new template if given a valid name and uri', ->
      Roots.template.add(name: test_tpl_name, uri: test_tpl_path)
        .then(-> Roots.template.list().should.include(test_tpl_name))
        .then(-> Roots.template.remove(name: test_tpl_name))
        .then(-> Roots.template.list().should.not.include(test_tpl_name))
        .should.be.fulfilled

  describe 'list', ->

    it 'should list all templates', ->
      Roots.template.list().should.be.a('array')

  describe 'remove', ->

    # TODO: really this should return a rejected promise
    it 'should error if not given a name', ->
      (-> Roots.template.remove()).should.throw()

    it 'should error if trying to remove a non-existant template', ->
      Roots.template.remove(name: 'wow').should.be.rejected

    it 'should remove a template if it exists', ->
      Roots.template.add(name: test_tpl_name, uri: test_tpl_path)
        .then(-> Roots.template.list().should.include(test_tpl_name))
        .then(-> Roots.template.remove(name: test_tpl_name))
        .then(-> Roots.template.list().should.not.include(test_tpl_name))
        .should.be.fulfilled

  describe 'default', ->

    it 'should error if not given a name', ->
      Roots.template.default().should.be.rejected

    it 'should error if the name given is not an installed template', ->
      Roots.template.default(name: 'wow').should.be.rejected

    it 'should make a template the default if the name given is installed', ->
      Roots.template.add(name: test_tpl_name, uri: test_tpl_path)
        .then(-> Roots.template.default(name: test_tpl_name))
        .then(-> Roots.template.remove(name: test_tpl_name))
        .then(-> Roots.template.default(name: 'roots-base'))
        .should.be.fulfilled

  describe 'reset', ->
    it 'should ask to confirm via command line'
    it 'should not ask to confirm via command line if override is passed'
    it 'should remove all templates and reset global config'

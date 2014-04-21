test_tpl_path = 'https://github.com/jenius/sprout-test-template.git'

describe 'template', ->

  describe 'add', ->
    it 'should error if only given a name'
    it 'should error if given a name and uri, but uri is invalid'
    it 'should add a new template if given a valid name and uri'

  describe 'list', ->
    it 'should list all templates'

  describe 'remove', ->
    it 'should error if not given a name'
    it 'should error if trying to remove a non-existant template'
    it 'should remove a template if it exists'

  describe 'default', ->
    it 'should error if not given a name'
    it 'should error if the name given is not an installed template'
    it 'should make a template the default if the name given is installed'

  describe 'reset', ->
    it 'should ask to confirm via command line'
    it 'should not ask to confirm via command line if override is passed'
    it 'should remove all templates and reset global config'

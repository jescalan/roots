describe 'analytics', ->

  it 'should track events when the __track function is called', ->
    __track('test', { wow: 'such test' }).should.be.fulfilled

  it 'should be able to disable analytics through the api', ->
    Roots.analytics(disable: true)
    __track('test', { wow: 'such test' }).should.eventually.be.false

  it 'should be able to enable analytics through the api', ->
    Roots.analytics(enable: true)
    __track('test', { wow: 'such test' }).should.be.fulfilled

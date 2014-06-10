{EventEmitter} = require('events')
fs             = require 'fs'
path           = require 'path'
Config         = require './config'
Extensions     = require './extensions'
child_process  = require 'child_process'
cpus           = require('os').cpus().length
W              = require 'when'
uuid           = require 'node-uuid'
_              = require 'lodash'

###*
 * @class
 * @classdesc main roots class, public api for roots
###

class Roots extends EventEmitter

  ###*
   * Given a path to a project, set up the config and return a roots instance
   * @param  {[type]} root - path to a folder
   * @return {Function} - instance of the Roots class
  ###

  constructor: (@root, opts={}) ->
    @root = path.resolve(@root)
    if not fs.existsSync(@root) then throw new Error("path does not exist")
    @extensions = new Extensions(@)
    @config = new Config(@, opts)
    set_up_workers.call(@, opts)

  ###*
   * Alternate constructor, creates a new roots project in a given folder and
   * returns a roots instance for this project. Takes an object with these keys:
   *
   * path: path to the folder you'd like to create and initialize a project in
   * template: name of the template you'd like to use (default: base)
   * overrides: data to pass to the template, skips prompts
   * defaults: sets default values for the template's prompts
   *
   * @param  {Object} opts - options object, described above
   * @return {Promise} Promise for a Roots class instance
  ###

  @new: (opts) ->
    New = require('./api/new')
    (new New(@)).exec(opts)

  ###*
   * Exposes an API to manage your roots project templates through sprout.
   * See api/template for details. The defineGetter hack makes it such that
   * while you can call roots.template.x like an object, the dependencies
   * needed for it are lazy-loaded only when you actually make the call.
   * This boosts the require time of this file by ~400ms.
  ###

  @__defineGetter__('template', -> require('./api/template'))

  ###*
   * Compiles a roots project. Wow.
   *
   * @return {Promise} promise for finished compile
  ###

  compile: ->
    # delegate this to the workers
    # fs parse, then queue up each of the files
    Compile = require('./api/compile')
    (new Compile(@)).exec()

  ###*
   * Watches a folder for changes and compiles whenever changes happen.
   *
   * @return {Object} [chokidar](https://github.com/paulmillr/chokidar) instance
  ###

  watch: ->
    Watch = require('./api/watch')
    (new Watch(@)).exec()

  ###*
   * Removes a project's output folder.
   * @return {Promise} promise for removed output folder
  ###

  clean: ->
    Clean = require('./api/clean')
    (new Clean(@)).exec()

  ###*
   * If an irrecoverable error has occurred, exit the application with
   * as clear an error as possible and a specific exit code.
   *
   * @param {Integer} code - numeric error code
   * @param {String} details - any additional details to be printed
  ###

  bail: require('./api/bail')

  # TODO: move worker/queue logic to a separate module

  ###*
   * Accepts a job and adds it to the queue for the worker with the least number
   * of current jobs in its queue. If it previously had an empty queue, it kicks
   * off the job. Once the job is complete, translates the results into a
   * fulfilled or rejected promise and resolves.
   *
   * What this is doing in general is a bunch of levels deep into async-land and
   * I think is also worth reviewing, both for myself and others looking at this
   * code. So roots processess all the files in parallel and fires off as many
   * compile tasks at the same time as it possibly can. This function gets hit
   * with all of them, say, 50 files, more or less at once, almost instantly.
   * The throttle in this situation is actually how fast your computer can
   * physically crunch through the cpu-intensive compile tasks, and that's
   * limited to the number of cores you have. A worker is created for each core,
   * and the files are divided up evenly between the workers. Since this happens
   * in a child process, it does not block the main thread and is asynchrnonous.
   * In addition, after each task is completed, we check and re-balance the
   * workload between all workers, in case it has become inbalanced due to some
   * files taking longer than others to compile.
   *
   * This function returns a promise, which is fulfilled as soon as the file
   * is done compiling. For some, this might be quite fast, and for others it
   * can only happen after a bunch of other files in the queue before it are
   * processed. Therefore, some promises can take much longer than others due
   * to the order they are queued up in. This is however as fast as your
   * computer can physically handle it.
   *
   * @param  {String} cat - category the file is in
   * @param  {File} file - file to be compiled
  ###

  queue: (cat, file) ->
    deferred = W.defer()

    worker = _.min(@workers, ((w) -> w.queue.length))
    job_id = uuid.v1()

    @taskmaster.once job_id, (data) ->
      if data == true then deferred.resolve() else deferred.reject(data)
      if worker.queue.length > 0 then queue_next(worker)
      # balance_workers()

    worker.queue.push([job_id, cat, file])
    if worker.queue.length == 1 then queue_next(worker)

    return deferred.promise

  ###*
   * Creates a worker for each cpu core and adds a queue property to it.
   * Creates a taskmaster, which is an event emitter that listens to all workers
   * and emits events with the job's id when a job is completed.
   *
   * @private
  ###

  set_up_workers = (opts) ->
    @workers = [0...cpus].map =>
      worker = child_process.fork(path.join(__dirname, 'worker'), [@root, opts])
      worker.queue = []
      worker

    @taskmaster = new EventEmitter
    for worker in @workers
      worker.on('message', (msg) => @taskmaster.emit(msg.id, msg.data))

  ###*
   * Ensures that queue lengths are as even as possible between all workers so
   * that the workload is distrubuted fairly.
   *
   * @private
  ###

  balance_workers = ->
    # - get length of each worker
    # - move tasks from the end of longer ones to the end of shorter ones
    # - if one of them is zero and recieves a task, run queue_next() to kick off

  ###*
   * Starts the next job in a worker's queue.
   *
   * @private
   * @param  {child_process} worker - roots worker process
  ###

  queue_next = (worker) ->
    worker.send(worker.queue.shift())

module.exports = Roots

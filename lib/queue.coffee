W    = require 'when'
uuid = require 'node-uuid'
_    = require 'lodash'

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

module.exports = (cat, file) ->
  deferred = W.defer()

  worker = _.min(@workers, ((w) -> w.queue.length))
  job_id = uuid.v1()

  @taskmaster.once job_id, (data) =>
    worker.queue.shift()
    if data == true then deferred.resolve() else deferred.reject(data)
    if worker.queue.length > 0 then queue_next(worker)
    @workers = balance_workers(@workers)

  worker.queue.push([job_id, cat, file])
  if worker.queue.length == 1 then queue_next(worker)

  return deferred.promise

###*
 * Ensures that queue lengths are as even as possible between all workers so
 * that the workload is distrubuted fairly.
 *
 * @private
 *
 * @param {Array} w - array of worker queues
###

balance_workers = (w) ->
  w = w.sort((a,b) -> a.queue.length > b.queue.length)
  for i in [0..w.length/2]
    tmp = w[i].queue.length
    w[i].queue = balance_pairs(w[i], w[w.length-i-1])
    if tmp is 0 and w[i].queue.length is 1 then queue_next(w[i])
  return w

###*
 * Helper method for balance_workers.
 *
 * @private
 *
 * @param  {Array} a - worker queue, larger
 * @param  {Array} b - another wotker queue, smaller
 * @return {Array} a modified version of `a`, evened out with `b`
###

balance_pairs = (a,b) ->
  s = (b.queue.length - a.queue.length)/2
  a.queue.concat(b.queue.splice(b.queue.length-s, s))

###*
 * Starts the next job in a worker's queue.
 *
 * @private
 * @param  {child_process} worker - roots worker process
###

queue_next = (worker) ->
  worker.send(worker.queue[0])

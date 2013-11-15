# Collection View Helpers
# -----------------------

###*
 * Sort a collection of dynamic content. By default sorts by 'order'
 * property, special handling for dates, and accepts ascending and
 * descending as options.
 * @param  {Array} ary - the array you want to sort
 * @param  {Object} opts - sorting options
 * @return {Array} your array, sorted
###

exports.sort = (ary, opts) ->
  opts ||= {}
  opts.by = opts.by || 'order'

  if opts.order == 'asc'
    fn = (a, b) -> if (a[opts.by] > b[opts.by]) then -1 else 1
  else
    fn = (a, b) -> if (a[opts.by] < b[opts.by]) then -1 else 1

  if opts.by == 'date'
    fn = (a,b) -> if (new Date(a[opts.by]) > new Date(b[opts.by])) then -1 else 1

  if opts.fn then fn = opts.fn

  ary.sort(fn)

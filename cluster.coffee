cluster = require 'cluster'
numCPUs = require('os').cpus().length
if cluster.isMaster
  # Fork workers.
  i = 0
  while i < numCPUs
    cluster.fork()
    i++
  cluster.on 'exit', (worker, code, signal) ->
    console.log 'worker ' + worker.process.pid + ' died'
    return
else
  # Workers can share any TCP connection
  # In this case its a HTTP server
  require './server'

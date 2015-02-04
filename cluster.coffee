numCPUs  = require('os').cpus().length
rssWarn  = 256 * 1024 * 1024
cluster  = require 'cluster'

workers = {}
createWorker = ->
  worker = cluster.fork()
  worker.lastCb = (new Date).getTime() - 1000
  workers[worker.process.pid] = worker
  worker.on 'message', (m) ->
    worker.lastCb = (new Date).getTime()
    if m.memory and m.memory.rss > rssWarn
      console.warn "Worker #{m.process} using too much memory (#{m.memory.rss})."

if cluster.isMaster
  # Fork workers.
  i = 0
  while i < numCPUs
    createWorker()
    i++
  cluster.on 'exit', (worker, code, signal) ->
    console.log 'worker %d died (%s). restarting...', worker.process.pid, signal || code
    createWorker()

  setInterval (->
    time = (new Date).getTime()
    for pid, worker of workers
      if worker.lastCb + 5000 < time
        console.log "Long running worker #{pid} killed"
        worker.kill()
        delete workers[pid]
        createWorker()
  ), 1000

else
  require './server'
  sendStats = ->
    process.send
      cmd: 'reportMem'
      memory: process.memoryUsage()
      process: process.pid
  setInterval sendStats, 1000

#!/usr/bin/env coffee

http    = require 'http'
fs      = require 'fs'
request = require 'request'
URL     = require 'url'
resize  = require './stream-resizer'

send_ok = (res) ->
  console.log "OK"
  res.writeHead 200, "Content-Type": "image/jpeg"

send_not_found = (res) ->
  console.log "404"
  res.writeHead 404
  res.end()

send_error = (res) ->
  console.log "500"
  res.writeHead 500
  res.end()

dispatcher = (req, res) ->
  query = (URL.parse req.url, true).query

  url     = query.url
  tool    = resize[query.tool || "imagemagick"]
  width   = 1024 unless (width = +query.width) and 0 < width < 2880
  quality = 70 unless (quality = +query.quality) and 0 < quality < 100

  unless tool and url
    send_not_found res
    return

  reader = request.get(url).on 'error', (err) -> console.log(err)
  reader.on 'error', -> send_not_found res
  reader.on 'response', -> send_ok res
  tool reader, res, width, quality

(http.createServer dispatcher).listen process.env.PORT || 8080

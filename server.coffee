#!/usr/bin/env coffee

http    = require 'http'
fs      = require 'fs'
request = require 'request'
url     = require 'url'
resize  = require './stream-resizer'

send_ok = (res) ->
  res.writeHead 200, "Content-Type": "image/jpeg"

send_not_found = (res) ->
  res.writeHead 404
  res.end()

send_error = (res) ->
  res.writeHead 500
  res.end()

dispatcher = (req, res) ->
  options = (url.parse req.url, true).query

  if not options.url
    send_not_found res
    return

  console.log "requesting #{options.url}"

  reader = request.get(options.url).on 'error', (err) -> console.log(err)
  reader.on 'error', -> send_not_found res
  reader.on 'response', -> send_ok res
  resize.mozjpeg reader, res, options.width || 1024, options.quality || 70

(http.createServer dispatcher).listen process.env.PORT || 8080

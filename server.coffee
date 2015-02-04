#!/usr/bin/env coffee
http    = require 'http'
fs      = require 'fs'
request = require 'request'
URL     = require 'url'
resize  = require './stream-resizer'

send_ok = (res) ->
  res.writeHead 200, "Content-Type": "image/jpeg"

send_not_found = (res) ->
  res.writeHead 404
  res.end()

send_error = (res) ->
  res.writeHead 500
  res.end()

send_forbidden = (res) ->
  res.writeHead 403
  res.end()

valid_referers = if process.env.VALID_REFERERS then process.env.VALID_REFERERS.split ':' else []

dispatcher = (req, res) ->
  if valid_referers.length
    referer = URL.parse req.headers['referer'] || ''
    if !~valid_referers.indexOf referer.hostname
      send_forbidden res
      return

  query = (URL.parse req.url, true).query

  url     = query.url
  tool    = resize[query.tool || "imagemagick"]
  width   = 1024 unless (width = +query.width) and 0 < width < 2880
  quality = 70 unless (quality = +query.quality) and 0 < quality < 100
  path    = query.path

  unless tool and (url or path)
    send_not_found res
    return

  reader = if url
    request.get url
  else
    fs.createReadStream path

  reader.on 'error', (err) ->
    console.log err
    send_not_found res
  res.on 'error', -> send_not_found res
  reader.on 'response', -> send_ok res

  tool reader, res, width, quality, -> send_error res

(http.createServer dispatcher).listen process.env.PORT || 8080

child_process = require 'child_process'

mozjpeg = (reader, writer, width, quality, error) ->
  args = [
    'jpg:-'
    '-resize', width
    '-quality', quality
    'png:-'
  ]

  convert = child_process.spawn 'convert', args
  convert.on 'error', error

  args = [
    '-optimize'
    '-dct', 'float'
    '-quality', quality
  ]
  cjpeg = child_process.spawn 'jpeg', args
  cjpeg.on 'error', error

  reader.pipe convert.stdin
  convert.stdout.pipe cjpeg.stdin
  cjpeg.stdout.pipe writer

  convert.stderr.pipe writer
  cjpeg.stderr.pipe writer

imagemagick = (reader, writer, width, quality, error) ->
  args = [
    'jpg:-'
    '-resize', width
    '-quality', quality
    'jpg:-'
  ]

  convert = child_process.spawn 'convert', args
  convert.on 'error', error

  reader.pipe convert.stdin
  convert.stdout.pipe writer

  convert.stderr.pipe writer

sharp = require 'sharp'

sharp_tranform = (reader, writer, width, quality, error) ->
  transformer = sharp().resize(+width).quality(quality)
  transformer.on 'error', error

  reader.pipe(transformer).pipe writer

module.exports = exports =
  mozjpeg: mozjpeg
  imagemagick: imagemagick
  sharp: sharp_tranform

child_process = require 'child_process'

mozjpeg = (reader, writer, width, quality) ->
  args = [
    'jpg:-'
    '-resize', width
    '-quality', quality
    'png:-'
  ]

  convert = child_process.spawn 'convert', args

  args = [
    '-optimize'
    '-dct', 'float'
    '-quality', quality
  ]
  cjpeg = child_process.spawn 'cjpeg', args

  reader.pipe convert.stdin
  convert.stdout.pipe cjpeg.stdin
  cjpeg.stdout.pipe writer

  convert.stderr.pipe process.stdout
  cjpeg.stderr.pipe process.stdout

imagemagick = (reader, writer, width, quality) ->
  args = [
    'jpg:-'
    '-resize', width
    '-quality', quality
    'jpg:-'
  ]

  convert = child_process.spawn 'convert', args

  reader.pipe convert.stdin
  convert.stdout.pipe writer

  convert.stderr.pipe process.stdout

sharp = require 'sharp'

sharp_tranform = (reader, writer, width, quality) ->
  transformer = sharp().resize(+width).quality(quality)

  reader.pipe(transformer).pipe writer

module.exports = exports =
  mozjpeg: mozjpeg
  imagemagick: imagemagick
  sharp: sharp_tranform

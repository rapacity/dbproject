



staload "libc/SATS/stdlib.sats"

fun magick_convert(str: string): int =
  system("convert " + str)


fun make_thumbnail(dimensions: string, src: string, dest: string): int =
  magick_convert("'" + src + "' -thumbnail '" + dimensions + "' '" + dest + "'")





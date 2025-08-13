def "main mass" [...files: string] {
  # let out = $files
  #   | wrap filename
  #   | insert media_name {$in.filename | parse-medianame}
  #   | insert resolution {$in.filename | parse-resolution}
  #   | insert rip {$in.filename | parse-rip}
  #   | insert hdr {$in.filename | parse-hdr}
  #   | insert codec {$in.filename | parse-codec}
  #   | insert ext {$in.filename | parse-ext}
  #   | insert newName {$in.media_name}

  let out = $files | each {parse-all $in}

  print ($out | update filename {path basename})
}

def main [file: string, --target-base-dir: string] {
  if not ($file | path exists) {
    print "This file doesn't exists"
    exit 1
  }
  if ($file | path type) != 'file' {
    print "Not a file"
    exit 1
  }

  let file = $file | path expand --strict --no-symlink

  let data = parse-all $file --interactive
  print $data

  let continue = ['Yes', 'No'] | input list 'Looks good ?'
  if $continue != 'Yes' {
    exit 1
  }

  let target_base_dir = $target_base_dir | default ($file | path dirname)

  let target_dir = $"($target_base_dir)/($data.media_name)"

  let cmd_mkdir = $"mkdir -p '($target_dir)'"
  let cmd_ln = $"ln '($file)' '($target_dir)/($data.target_name)'"
  let cmd_cleanup = $"rm '($file)'"

  ^wl-copy $cmd_mkdir
  ['Continue'] | input list $"Copied: ($cmd_mkdir)"

  ^wl-copy $cmd_ln
  ['Continue'] | input list $"Copied: ($cmd_ln)"

  ^wl-copy $cmd_cleanup
  ['Continue'] | input list $"Copied: ($cmd_cleanup)"
}

def parse-all [file: string, --interactive] {
  let data = {
    filename: $file
    media_name: ($file | parse-medianame)
    extra: ''
    resolution: ($file | parse-resolution)
    rip: ($file | parse-rip)
    hdr: ($file | parse-hdr)
    codec: ($file | parse-codec)
    ext: ($file | parse-ext)
  }

  let data = if $interactive {
    {
      filename: $data.filename
      media_name: (input --default $data.media_name "Media name: ")
      extra: (input "Extra: ")
      resolution: (input --default $data.resolution "Resolution: ")
      rip: (input --default $data.rip "Rip: ")
      hdr: (input --default $data.hdr "HDR: ")
      codec: (input --default $data.codec "Codec: ")
      ext: (input --default $data.ext "Ext: ")
    }
  } else {
    $data
  }

  mut target_name = $data.media_name
  if ($data.extra | is-not-empty) {
    $target_name += '.' + $data.extra
  }
  if ($data.resolution | is-not-empty) {
    $target_name += '.' + $data.resolution
  }
  if ($data.rip | is-not-empty) {
    $target_name += '.' + $data.rip
  }
  if ($data.hdr | is-not-empty) {
    $target_name += '.' + $data.hdr
  }
  $target_name += '.' + $data.codec
  $target_name += '.' + $data.ext


  { ...$data, target_name: $target_name  }
}

def parse-medianame []: string -> string {
  path basename
    | parse --regex '^(?<name>.+[^a-zA-Z0-9][12]\d{3}\)?)[^a-zA-Z0-9]'
    | get -o 0.name
    | default ''
}

def parse-resolution []: string -> string {
  path basename
    | parse --regex '[^a-zA-Z0-9](?<resolution>(?:720|1080|2160)p|UHD)[^a-zA-Z0-9]'
    | get -o 0.resolution
    | default ''
    | str replace 'UHD' '2160p'
}

def parse-rip []: string -> string {
  path basename
    | parse --regex '(?i)[^a-zA-Z0-9](?<rip>blu-?ray|[a-z]+rip|web[a-z-]*|h?dts)[^a-zA-Z0-9]'
    | get -o 0.rip
    | default ''
    | str replace --regex '(?i)blu-?ray' 'BluRay'
    | str replace --regex '(?i)web-?dl' 'WEB-DL'
}

def parse-hdr []: string -> string {
  path basename
    | parse --regex '(?i)[^a-zA-Z0-9](?<hdr>[a-z0-9]*hdr[a-z0-9]*)[^a-zA-Z0-9]'
    | get -o 0.hdr
    | default ''
    | str replace --regex '.+' 'HDR'
}

def parse-codec []: string -> string {
  path basename
    | parse --regex '(?i)[^a-zA-Z0-9](?<codec>[hx]\.?26[456]|av1|avc|hevc)[^a-zA-Z0-9]'
    | get -o 0.codec
    | default ''
    | str replace --regex '(?i)[hx]\.?264' 'AVC'
    | str replace --regex '(?i)[hx]\.?265' 'HEVC'
    | str replace --regex '(?i)av1' 'AV1'
}

def parse-ext []: string -> string {
  parse --regex '(?i)\.(?<ext>[a-zA-Z0-9]+)$'
    | get 0.ext
    | str downcase
}

# vim: set tabstop=2 shiftwidth=2 expandtab :

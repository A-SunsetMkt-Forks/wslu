#!/usr/bin/env bats

#wslusc testing

teardown() {
  echo "removal for temporary shortcuts"
  rm -rf "`out/wslupath -D`/test1.lnk"
  rm -rf "`out/wslupath -D`/test2.lnk"

}

@test "wslusc - No parameter" {
  run out/wslusc
  [ "$status" -eq 21 ]
}

@test "wslusc - Help" {
  run out/wslusc --help
  [ "${lines[0]}" = "wslusc - Part of wslu, a collection of utilities for Windows 10 Windows Subsystem for Linux" ]
  [ "${lines[1]}" = "Usage: wslusc (--env [PATH]|--name [NAME]|--icon [ICO FILE]|--gui|--help|--version) [COMMAND]" ]
}

@test "wslusc - Help - Alt." {
  run out/wslusc -h
  [ "${lines[0]}" = "wslusc - Part of wslu, a collection of utilities for Windows 10 Windows Subsystem for Linux" ]
  [ "${lines[1]}" = "Usage: wslusc (--env [PATH]|--name [NAME]|--icon [ICO FILE]|--gui|--help|--version) [COMMAND]" ]
}

@test "wslusc - without GUI" {
  run out/wslusc test1
  [ -f "`out/wslupath -D`/test1.lnk" ]
}

@test "wslusc - with GUI" {
  run out/wslusc -g test2
  [ -f "`out/wslupath -D`/test2.lnk" ]
}

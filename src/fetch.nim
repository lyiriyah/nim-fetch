import terminal, osproc, os, math, strutils
import std/exitprocs

enableTrueColors()

let
  username = getEnv("USER")
  hostname = execProcess("hostname")
  distroname = execProcess("cat /etc/os-release | grep -oP \"(?<=^PRETTY_NAME=).+\" | tr -d \"\\\"\" ")
  cpuname = execProcess("lscpu | grep \"Model name\" | tr -s \" \" | awk '{for(i=3;i<=NF;++i)printf $i\"\"FS ; print \"\"}'")
  editor = getEnv("EDITOR")
  shell = execProcess("basename $(echo $SHELL)")
  architecture = execProcess("lscpu | grep Arch | tr -s \" \" | awk '{print $2}'")
  memory = execProcess("free -h | sed -n '2p' | awk '{print $2}'")
  usedmem = execProcess("printf \"%s/%s\n\" \"$(free -h | sed -n '2p' | awk '{print $3}')\" \"$(free -h | sed -n '2p' | awk '{print $2}')\"")
  userhostlen = username.len + hostname.len

stdout.styledWrite(fgGreen, username, resetStyle, "@", fgGreen, hostname)

for c in 1..userhostlen:
  if c == int(round(userhostlen / 2)):
    stdout.write("\u252C")
  elif c == userhostlen:
    stdout.write("\u2500\n")
  else:
    stdout.write("\u2500")

stdout.styledWrite(fgBlue, indent("distro", (8 - "distro".len)), resetStyle,
    " \u2502 ", distroname)
stdout.styledWrite(fgBlue, indent("arch", (8 - "arch".len)), resetStyle,
    " \u2502 ", architecture)
stdout.styledWrite(fgBlue, indent("editor", (8 - "editor".len)), resetStyle,
    " \u2502 ", editor & "\n")
stdout.styledWrite(fgBlue, indent("shell", (8 - "shell".len)), resetStyle,
    " \u2502 ", shell)
stdout.styledWrite(fgBlue, indent("cpu", (8 - "cpu".len)), resetStyle,
    " \u2502 ", cpuname)
stdout.styledWrite(fgBlue, indent("memory", (8 - "memory".len)), resetStyle,
    " \u2502 ", memory)
stdout.styledWrite(fgBlue, indent("usage", (8 - "usage".len)), resetStyle,
    " \u2502 ", usedmem)

addExitProc(resetAttributes) # restore terminal attrs

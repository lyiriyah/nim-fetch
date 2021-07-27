import terminal, osproc, os, math, strutils, tables, sequtils
import std/exitprocs

enableTrueColors()

let
  hostuser = execProcess("hostname").strip(chars={'\n'}) & "@" & getEnv("USER")
  cpuname = execProcess("lscpu | grep \"Model name\" | tr -s \" \" | awk '{for(i=3;i<=NF;++i)printf $i\"\"FS ; print \"\"}'")
  editor = getEnv("EDITOR")
  shell = execProcess("basename $(echo $SHELL)")
  architecture = execProcess("lscpu | grep Arch | tr -s \" \" | awk '{print $2}'")
  memory = execProcess("free -h | sed -n '2p' | awk '{print $2}'")
  usedmem = execProcess("printf \"%s/%s\n\" \"$(free -h | sed -n '2p' | awk '{print $3}')\" \"$(free -h | sed -n '2p' | awk '{print $2}')\"")

proc getCpuUsage(): string =
  let firstLine = "/proc/stat".readLines(1)[0]
  let vals = firstline.splitWhitespace()[1..^1].map(parseInt)
  let totalTime = sum(vals)
  let notIdlePerc = (1 - (vals[3] / totalTime)) * 100
  return $(round(notIdlePerc, 1)) & "%\n"

proc getDistro(): string =
  let file = "cat /etc/os-release"
  let grepcmd = r"grep -oP ""(?<=^PRETTY_NAME=).+"" "
  let trcmd = "tr -d \"\\\"\""
  let pipe = "|"
  return execProcess(file & pipe & grepcmd & pipe & trcmd)

let outtable = {
  "host@user": hostuser & "\n",
  "distro": getDistro(),
  "arch": architecture,
  "editor": editor & "\n",
  "shell": shell,
  "cpu": cpuname,
  "cpu usage": getCpuUsage(),
  "memory": memory,
  "mem usage": usedmem,
}.toOrderedTable()

var outkeys = newSeq[string]()

for k in keys(outtable):
  outkeys.add(k)

let largestkey = max(outkeys.mapIt(it.len))

for k, v in pairs(outtable):
    stdout.styledWrite(fgBlue, align(k, max(outkeys.mapIt(it.len))), resetStyle, " \u2502 ", v)

addExitProc(resetAttributes) # restore terminal attrs

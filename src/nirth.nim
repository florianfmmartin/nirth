from std/strutils import contains, parseInt, splitWhitespace

type
  VM = object
    stack: seq[int]
    compileFlag: bool
    compiledWords: string

proc ctrlc() {.noconv.} =
  echo("\nGood bye!")
  quit()

setControlCHook(ctrlc)

proc startCompile(vm: var VM) =
  vm.compileFlag = true
  vm.compiledWords &= "::::"

proc compile(vm: var VM, input: string) =
  vm.compiledWords &= (" " & input)

proc endCompile(vm: var VM) =
  vm.compiledWords &= " ;;;; "
  vm.compileFlag = false

proc processNonCompilingInput(vm: var VM, input: string): bool =
  case input:
    of "show":
      echo(vm.stack)
    of "bye":
      ctrlc()
    of "+": # (b a -- [b+a])
      let
        a = vm.stack.pop()
        b = vm.stack.pop()
      vm.stack.add(b + a)
    of "-": # (b a -- [b-a])
      let
        a = vm.stack.pop()
        b = vm.stack.pop()
      vm.stack.add(b - a)
    of "*": # (b a -- [b*a])
      let
        a = vm.stack.pop()
        b = vm.stack.pop()
      vm.stack.add(b * a)
    of "/": # (b a -- [b/a])
      let
        a = vm.stack.pop()
        b = vm.stack.pop()
      vm.stack.add(b div a)
    of "%": # (b a -- [b%a])
      let
        a = vm.stack.pop()
        b = vm.stack.pop()
      vm.stack.add(b mod a)
    of "pop": # (b a -- b)
      let a = vm.stack.pop()
      echo(a)
    of ":":
      let _ = 0
      vm.startCompile()
    of "compiler":
      echo(vm.compiledWords)
    of ";":
      echo("Not in compile mode...")
    else:
      if (vm.compiledWords.contains((":::: " & input))):
        echo("`" & input & "` exists in dictionary...")
      else:
        echo("I don't know what `" & input & "` means...")
        return false
  return true

proc processInput(vm: var VM, input: string): bool =
  if vm.compileFlag:
    case input:
      of "compiler":
        echo(vm.compiledWords)
      of ";":
        let _ = 0
        vm.endCompile()
      else:
        let _ = 0
        vm.compile(input)
  else:
    try:
      let integer = parseInt(input)
      vm.stack.add(integer)
    except ValueError:
      try:
          return vm.processNonCompilingInput(input)
      except IndexDefect:
        echo("Stack underflow by `" & input & "` ...")
        return false
  return true

proc main() {.raises: [].} =
  var
    vm: VM = VM(stack: @[])
    input: string
    input_array: seq[string]
    ok: bool = true

  echo("Welcome to Nirth!")

  while ok:
    try:
      stdout.write(">>>> ")
      input = readLine(stdin)
    except IOError:
      ok = false
      echo("^D\nGood bye!")

    input_array = input.splitWhitespace()

    for i in input_array:
      ok = ok and vm.processInput(i)

    if ok:
      echo("ok.")

when isMainModule:
  main()

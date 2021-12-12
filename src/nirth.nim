from std/strutils import parseInt, splitWhitespace

type
  VM = object
    stack: seq[int]

proc ctrlc() {.noconv.} =
  echo("\nGood bye!")
  quit()

setControlCHook(ctrlc)

proc processInput(vm: var VM, input: string): bool =
  try:
    let integer = parseInt(input)
    vm.stack.add(integer)
  except ValueError:
    try:
      case input:
        of "show":
          echo(vm.stack)
        of "bye":
          ctrlc()
        of "+": # (b a -- [a+b])
          let
            a = vm.stack.pop()
            b = vm.stack.pop()
          vm.stack.add(a + b)
        else:
          echo("I don't know what `" & input & "` means...")
          return false
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
      echo("Good bye!")

    input_array = input.splitWhitespace()

    for i in input_array:
      ok = ok and vm.processInput(i)

    if ok:
      echo("ok.")

when isMainModule:
  main()

from std/strutils import contains, find, parseInt, splitWhitespace

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

proc processArrayOfWords(vm: var VM, input_array: seq[string], ok: var bool, silent: bool = false) =

  #### processInput
  proc processInput(vm: var VM, input: string): bool =

    #### processNonCompilingInput
    proc processNonCompilingInput(vm: var VM, input: string): bool =
      
      #### runWord
      proc runWord(vm: var VM, word: string): bool =
        var ok = true
        let
          formattedWord = ":::: " & word & " "
          startIndex = vm.compiledWords.find(formattedWord)
          endIndex = vm.compiledWords.find(";;;;", start=startIndex)
          wordDefinition = vm.compiledWords[startIndex..<endIndex]
          wordDefinitionList = wordDefinition.splitWhitespace()
          definitionList = wordDefinitionList[2..^1]
        vm.processArrayOfWords(definitionList, ok, silent=true)
        if (not ok):
          echo("Error caused by `" & word & "`")
        return ok
      #### runWord

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
          if (vm.compiledWords.contains((":::: " & input & " "))):
            # echo("`" & input & "` exists in dictionary...")
            return vm.runWord(input)
          else:
            echo("I don't know what `" & input & "` means...")
            return false
      return true
    #### processNonCompilingInput

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
  #### processInput

  for i in input_array:
    ok = ok and vm.processInput(i)
  if ok and (not silent):
    echo("ok.")

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

    vm.processArrayOfWords(input_array, ok)

when isMainModule:
  main()

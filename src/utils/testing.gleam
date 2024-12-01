import gleam/erlang/process
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import tempo/duration
import tempo/time

pub type TestCase {
  TestCase(input_file: String, expected: Option(String))
}

pub fn check_solution(solver: fn(String) -> String, cases: List(TestCase)) {
  let successful = cases |> list.count(check_input(solver, _)) |> int.to_string
  let total = list.length(cases) |> int.to_string

  // Sleep for 10ms, because output becomes confused otherwise..
  process.sleep(10)
  case total == successful {
    True ->
      io.println(green(
        "\nSuccessful test cases: " <> successful <> "/" <> total,
      ))
    False ->
      io.println(red("\nSuccessful test cases: " <> successful <> "/" <> total))
  }
}

fn check_input(solver: fn(String) -> String, input: TestCase) -> Bool {
  // Sleep for 10ms, because output becomes confused otherwise..
  process.sleep(10)

  let TestCase(file, expected) = input

  io.println("")
  io.println(string.repeat("-", 20) <> file <> string.repeat("-", 20))

  let t_1 = time.now_local()
  let solution = solver(file)
  let time_delta = time.difference(time.now_local(), t_1) |> duration.format
  io.println("Finished: " <> file <> " in " <> time_delta)
  io.println("Solution: " <> solution)

  case expected {
    Some(expected) if expected == solution -> {
      io.println(green("Correct!"))
      True
    }
    Some(expected) -> {
      io.println_error(red("Expected: " <> expected))
      False
    }
    None -> True
  }
}

const color_green = "\u{001b}[38;5;2m"

const color_red = "\u{001b}[38;5;9m"

const color_reset = "\u{001b}[0m"

pub fn green(text: String) -> String {
  color_green <> text <> color_reset
}

pub fn red(text: String) -> String {
  color_red <> text <> color_reset
}

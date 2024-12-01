import gleam/string
import simplifile

pub fn readlines(filename: String) -> List(String) {
  let assert Ok(input) = filename |> simplifile.read()
  input |> string.trim() |> string.split("\n")
}

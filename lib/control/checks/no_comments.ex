defmodule Control.Checks.NoComments do
  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      Free-form comments are not allowed.

      Prefer `@moduledoc`/`@doc` for documentation, and self-documenting names and
      structure for everything else. Comments drift out of sync with the code.
      """
    ]

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    source_file
    |> SourceFile.source()
    |> comment_lines()
    |> Enum.map(&issue_for(issue_meta, &1))
  end

  defp comment_lines(source) do
    case Code.string_to_quoted_with_comments(source) do
      {:ok, _quoted, comments} -> Enum.map(comments, & &1.line)
      _ -> []
    end
  end

  defp issue_for(issue_meta, line) do
    format_issue(issue_meta,
      message: "Remove this comment; use @doc/@moduledoc or clearer code instead.",
      line_no: line
    )
  end
end

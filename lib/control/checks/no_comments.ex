defmodule Control.Checks.NoComments do
  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      Free-form comments are not allowed, in code or in `~H` templates.

      Prefer `@moduledoc`/`@doc` for documentation, and self-documenting names and
      structure for everything else. Comments drift out of sync with the code.
      Template comments, `<%!-- --%>` and `<!-- -->`, count too.
      """
    ]

  @template_comment ~r/<%!--|<!--/

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)

    source_file
    |> SourceFile.source()
    |> comment_lines()
    |> Enum.concat(Credo.Code.prewalk(source_file, &collect_template_comment_lines/2))
    |> Enum.map(&issue_for(issue_meta, &1))
  end

  defp comment_lines(source) do
    case Code.string_to_quoted_with_comments(source) do
      {:ok, _quoted, comments} -> Enum.map(comments, & &1.line)
      _ -> []
    end
  end

  defp collect_template_comment_lines({:sigil_H, meta, [{:<<>>, _, [template]}, _]} = ast, lines)
       when is_binary(template) do
    {ast, lines ++ template_comment_lines(template, first_template_line(meta))}
  end

  defp collect_template_comment_lines(ast, lines), do: {ast, lines}

  defp first_template_line(meta) do
    if meta[:delimiter] in [~s("""), "'''"], do: meta[:line] + 1, else: meta[:line]
  end

  defp template_comment_lines(template, first_line) do
    @template_comment
    |> Regex.scan(template, return: :index)
    |> Enum.map(fn [{offset, _length}] ->
      template
      |> binary_part(0, offset)
      |> String.split("\n")
      |> length()
      |> Kernel.+(first_line - 1)
    end)
  end

  defp issue_for(issue_meta, line) do
    format_issue(issue_meta,
      message: "Remove this comment; use @doc/@moduledoc or clearer code instead.",
      line_no: line
    )
  end
end

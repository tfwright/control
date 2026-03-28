defmodule Control.Checks.SingleAssertionPerTest do
  use Credo.Check,
    base_priority: :high,
    category: :design,
    explanations: [
      check: """
      Each test block should contain exactly one assertion.

      # preferred
      test "returns nil", %{result: result} do
        assert result == nil
      end

      # not preferred
      test "returns nil and logs", %{result: result, log: log} do
        assert result == nil
        assert log =~ "error"
      end
      """
    ]

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:test, meta, [_name | rest]} = ast, issues, issue_meta) do
    count = rest |> get_body() |> count_assertions()

    if count != 1 do
      issue =
        format_issue(issue_meta,
          message: "Test block should contain exactly one assertion, found #{count}.",
          trigger: "test",
          line_no: meta[:line]
        )

      {ast, [issue | issues]}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}

  defp get_body([_context, [do: body]]), do: body
  defp get_body([[do: body]]), do: body
  defp get_body(_), do: nil

  defp count_assertions(nil), do: 0

  defp count_assertions({:__block__, _, statements}) do
    Enum.count(statements, &assertion?/1)
  end

  defp count_assertions(statement) do
    if assertion?(statement), do: 1, else: 0
  end

  defp assertion?({name, _, _}) when is_atom(name) do
    name_str = Atom.to_string(name)
    String.starts_with?(name_str, "assert") or String.starts_with?(name_str, "refute")
  end

  defp assertion?(_), do: false
end

defmodule Control.Checks.NoSetupInTest do
  use Credo.Check,
    base_priority: :high,
    category: :design,
    explanations: [
      check: """
      Test blocks should contain only assertions. Any other expression — including
      function calls and variable bindings — is setup and belongs in the
      describe-level `setup` callback.

      # preferred
      describe "with a user" do
        setup do
          %{result: Accounts.get_user(user.id)}
        end

        test "returns the user", %{result: result} do
          assert result.email == "user@example.com"
        end
      end

      # not preferred
      test "returns the user" do
        result = Accounts.get_user(user.id)
        assert result.email == "user@example.com"
      end
      """
    ]

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:test, _meta, [_name | rest]} = ast, issues, issue_meta) do
    new_issues =
      rest
      |> get_body()
      |> top_level_statements()
      |> Enum.reject(&assertion?/1)
      |> Enum.map(&to_issue(&1, issue_meta))

    {ast, issues ++ new_issues}
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}

  defp get_body([_context, [do: body]]), do: body
  defp get_body([[do: body]]), do: body
  defp get_body(_), do: nil

  defp top_level_statements(nil), do: []
  defp top_level_statements({:__block__, _, statements}), do: statements
  defp top_level_statements(statement), do: [statement]

  defp assertion?({name, _, _}) when is_atom(name) do
    name_str = Atom.to_string(name)
    String.starts_with?(name_str, "assert") or String.starts_with?(name_str, "refute")
  end

  defp assertion?(_), do: false

  defp to_issue({_, meta, _}, issue_meta) do
    format_issue(issue_meta,
      message:
        "Test block contains setup. Move non-assertion expressions to the `setup` callback.",
      trigger: "test",
      line_no: meta[:line]
    )
  end
end

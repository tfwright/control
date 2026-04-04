defmodule Control.Checks.MultiRunSingleOp do
  use Credo.Check,
    base_priority: :high,
    category: :design,
    explanations: [
      check: """
      Use `Ecto.Multi.insert/3`, `Ecto.Multi.update/3`, or `Ecto.Multi.delete/3`
      instead of `Ecto.Multi.run/3` when the callback only performs a single
      database operation.

      # preferred
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:record, fn _changes -> %MySchema{field: value} end)

      # not preferred
      Ecto.Multi.new()
      |> Ecto.Multi.run(:record, fn _repo, _changes -> Repo.insert(%MySchema{field: value}) end)
      """
    ]

  @repo_ops [:insert, :update, :delete]

  def run(%SourceFile{} = source_file, params) do
    issue_meta = IssueMeta.for(source_file, params)
    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse(
    {{:., meta, [{:__aliases__, _, [:Ecto, :Multi]}, :run]}, _, args} = ast,
    issues,
    issue_meta
  ) do
    case List.last(args) do
      {:fn, _, [{:->, _, [_params, body]}]} ->
        if single_repo_op?(body) do
          op = body |> last_statement() |> repo_op_name()
          issue = format_issue(issue_meta,
            message: "Use `Ecto.Multi.#{op}` instead of `Ecto.Multi.run` for a single `Repo.#{op}` call.",
            trigger: "Ecto.Multi.run",
            line_no: meta[:line]
          )
          {ast, issues ++ [issue]}
        else
          {ast, issues}
        end
      _ ->
        {ast, issues}
    end
  end

  defp traverse(ast, issues, _issue_meta), do: {ast, issues}

  defp single_repo_op?(body), do: body |> last_statement() |> repo_op_name() |> then(&(not is_nil(&1)))

  defp last_statement({:__block__, _, statements}), do: List.last(statements)
  defp last_statement(statement), do: statement

  defp repo_op_name({{:., _, [{:__aliases__, _, _}, op]}, _, _}) when op in @repo_ops, do: op
  defp repo_op_name({:|>, _, [_, {{:., _, [{:__aliases__, _, _}, op]}, _, _}]}) when op in @repo_ops, do: op
  defp repo_op_name(_), do: nil
end

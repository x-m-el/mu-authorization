defmodule Acl.UserGroups do
  alias Acl.UserGroups.Config, as: Config
  alias Acl.GroupSpec, as: GroupSpec

  @doc """
  Filters the useage_groups for a particular useage.

  The usage can be specified top-level with the typo "useage" and at a
  lower level with the key usage.  An error will be thrown when the
  wrong key is used at a certain position.
  """
  @spec user_groups_for(Config.t(), GroupSpec.useage_method()) :: Config.t()
  def user_groups_for(user_groups, useage) do
    user_groups
    |> Enum.reduce([], fn group_spec, acc ->
      case group_spec do
        %GraphCleanup{} ->
          [group_spec | acc]

        %GroupSpec{} ->
          base_usage = group_spec.useage

          graphs =
            (group_spec.graphs || [])
            |> Enum.filter(fn graph_spec ->
              effective_usage =
                if match?(nil, graph_spec.usage) do
                  base_usage
                else
                  graph_spec.usage
                end

              Enum.member?(effective_usage, useage)
            end)

          # Add to the mix if graphs were found
          case graphs do
            [] -> acc
            _ -> [%{group_spec | graphs: graphs} | acc]
          end
      end
    end)
    |> Enum.reverse()
  end

  @doc """
  Yields all the user groups for the supplied useage.
  """
  @spec for_use(GroupSpec.useage_method()) :: Config.t()
  def for_use(useage) do
    Config.user_groups()
    |> user_groups_for(useage)
  end
end

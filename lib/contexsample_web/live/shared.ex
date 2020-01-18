defmodule ContexSampleWeb.Shared do
  import Phoenix.HTML
  import Phoenix.LiveView, only: [assign: 2]

  def update_chart_options_from_params(socket, params) do
    options =
      socket.assigns.chart_options
      |> clear_message()
      |> update_if_int(:series, params["series"], 20)
      |> update_if_int(:points, params["points"], 5000)
      |> update_if_int(:categories, params["categories"], 40)
      |> update_type(params["type"])
      |> update_orientation(params["orientation"])
      |> Map.put(:show_legend, params["show_legend"])
      |> Map.put(:show_selected, params["show_selected"])
      |> Map.put(:time_series, params["time_series"])
      |> Map.put(:title, params["title"])
      |> Map.put(:colour_scheme, params["colour_scheme"])

     assign(socket, chart_options: options)
  end

  def colour_options(), do: simple_option_list(~w(default themed custom warm pastel nil))
  def yes_no_options(), do: simple_option_list(~w(yes no))
  def chart_type_options(), do: simple_option_list(~w(stacked grouped))
  def chart_orientation_options(), do: simple_option_list(~w(vertical horizontal))


  def lookup_colours("pastel"), do: :pastel1
  def lookup_colours("default"), do: :default
  def lookup_colours("warm"), do: :warm
  def lookup_colours("themed"), do: ["ff9838", "fdae53", "fbc26f", "fad48e", "fbe5af", "fff5d1"]
  def lookup_colours("custom"), do: ["004c6d", "1e6181", "347696", "498caa", "5da3bf", "72bbd4", "88d3ea", "9eebff"]
  def lookup_colours("nil"), do: nil
  def lookup_colours(_), do: nil

  def simple_option_list(options), do: Enum.map(options, &%{name: &1, value: &1})

  def raw_select(name, id, options, current_item) do
    beginning_bit = ~E|<select  type="select" name="<%= name %>" id="<%= id %>">|

    middle_bit = Enum.map(options, fn o ->
      selected = if o.value == current_item, do: "selected", else: ""
      ~E|<option value="<%= o.value %>" <%= selected %>><%= o.name %></option>|
    end)

    end_bit = ~E|</select>|
    [beginning_bit, middle_bit, end_bit]
  end

  def list_to_comma_string(nil), do: ""
  def list_to_comma_string(list), do: Enum.join(list, ", ")

  defp clear_message(map), do: Map.put(map, :friendly_message, [])

  defp add_message(map, msg) do
    existing = case map[:friendly_message] do
      [] -> ["Are you trying to crash the demo server?!. Feel free to clone the repo if you want to test the limits. The BEAM generally keeps up - browser rendering is usually where things drag."]
      [_|_] = val -> val
    end
    Map.put(map, :friendly_message, [msg | existing])
  end

  defp update_if_int(map, _key, nil, _max), do: map
  defp update_if_int(map, key, possible_value, max) do
    case Integer.parse(possible_value) do
      {val, ""} ->
        if val > max do
          Map.put(map, key, max)
          |> add_message("Maximum for #{key} is #{max}")
        else
          if val > 0, do: Map.put(map, key, val), else: map
        end
      _ ->
        map
    end
  end

  defp update_type(options, raw) do
    case raw do
      "stacked" -> Map.put(options, :type, :stacked)
      "grouped" -> Map.put(options, :type, :grouped)
      _-> options
    end
  end

  defp update_orientation(options, raw) do
    case raw do
      "horizontal" -> Map.put(options, :orientation, :horizontal)
      "vertical" -> Map.put(options, :orientation, :vertical)
      _-> options
    end
  end

end

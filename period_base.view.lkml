view: period_base {
  extension: required

  parameter: period {
    description: "Prior Period for Comparison"
    type: string
    allowed_value: {
      value: "day"
      label: "Day"
    }
    allowed_value: {
      value: "week"
      label: "Week (Mon - Sun)"
    }
    allowed_value: {
      value: "month"
      label: "Month"
    }
    allowed_value: {
      value: "quarter"
      label: "Quarter"
    }
    allowed_value: {
      value: "year"
      label: "Year"
    }
    allowed_value: {
      value: "7 day"
      label: "Last 7 Days"
    }
    allowed_value: {
      value: "28 day"
      label: "Last 28 Days"
    }
    allowed_value: {
      value: "91 day"
      label: "Last 91 Days"
    }
    allowed_value: {
      value: "364 day"
      label: "Last 364 Days"
    }
    default_value: "28 day"
  }
  dimension: date_period {
    type: date
    convert_tz: no
    label_from_parameter: period
    group_label: "Event"
    sql: TIMESTAMP({% if ga_sessions.period._parameter_value contains "day" %}
        {% if ga_sessions.period._parameter_value == "'7 day'" %}${date_date_7_days_prior}
        {% elsif ga_sessions.period._parameter_value == "'28 day'" %}${date_date_28_days_prior}
        {% elsif ga_sessions.period._parameter_value == "'91 day'" %}${date_date_91_days_prior}
        {% elsif ga_sessions.period._parameter_value == "'364 day'" %}${date_date_364_days_prior}
        {% else %}${date_date}
        {% endif %}
      {% elsif ga_sessions.period._parameter_value contains "week" %}${date_week}
      {% elsif ga_sessions.period._parameter_value contains "month" %}${date_month_date}
      {% elsif ga_sessions.period._parameter_value contains "quarter" %}${date_quarter_date}
      {% elsif ga_sessions.period._parameter_value contains "year" %}${date_year_date}
      {% endif %}) ;;
    allow_fill: no
  }
  dimension: date_end_of_period {
    type: date
    convert_tz: no
    label_from_parameter: period
    group_label: "Event"
    sql: TIMESTAMP({% if ga_sessions.period._parameter_value contains "day" %}
        {% if ga_sessions.period._parameter_value == "'7 day'" %}DATE_ADD(${date_period}, INTERVAL 7 DAY)
        {% elsif ga_sessions.period._parameter_value == "'28 day'" %}DATE_ADD(${date_period}, INTERVAL 28 DAY)
        {% elsif ga_sessions.period._parameter_value == "'91 day'" %}DATE_ADD(${date_period}, INTERVAL 91 DAY)
        {% elsif ga_sessions.period._parameter_value == "'364 day'" %}DATE_ADD(${date_period}, INTERVAL 364 DAY)
        {% else %}${date_date}
        {% endif %}
      {% elsif ga_sessions.period._parameter_value contains "week" %}DATE_ADD(${date_period}, INTERVAL 1 WEEK)
      {% elsif ga_sessions.period._parameter_value contains "month" %}DATE_ADD(${date_period}, INTERVAL 1 MONTH)
      {% elsif ga_sessions.period._parameter_value contains "quarter" %}DATE_ADD(${date_period}, INTERVAL 1 QUARTER)
      {% elsif ga_sessions.period._parameter_value contains "year" %}DATE_ADD(${date_period}, INTERVAL 1 YEAR)
      {% endif %}) ;;
    allow_fill: no
  }
  dimension: date_period_latest {
    description: "Is the selected period (This Period) the current period?"
    type: yesno
    group_label: "Event"
    sql: ${date_period} < CURRENT_DATE() AND ${date_end_of_period} >= CURRENT_DATE() ;;
    # expression: ${date_period} <= now() AND ${date_end_of_period} >= now() ;;
  }
  dimension: date_period_comparison_period {
#     hidden: yes
    description: "Is the selected period (This Period) in the last two periods?"
    type: yesno
    group_label: "Event"
    sql: ${date_period} >= {% if ga_sessions.period._parameter_value contains "day" %}
        {% if ga_sessions.period._parameter_value == "'7 day'" %}DATE_ADD(CURRENT_DATE(), INTERVAL -2*7 DAY)
        {% elsif ga_sessions.period._parameter_value == "'28 day'" %}DATE_ADD(CURRENT_DATE(), INTERVAL -2*28 DAY)
        {% elsif ga_sessions.period._parameter_value == "'91 day'" %}DATE_ADD(CURRENT_DATE(), INTERVAL -2*91 DAY)
        {% elsif ga_sessions.period._parameter_value == "'364 day'" %}DATE_ADD(CURRENT_DATE(), INTERVAL -2*364 DAY)
        {% else %}${date_date}
        {% endif %}
      {% elsif ga_sessions.period._parameter_value contains "week" %}DATE_ADD(CURRENT_DATE(), INTERVAL -2 WEEK)
      {% elsif ga_sessions.period._parameter_value contains "month" %}DATE_ADD(CURRENT_DATE(), INTERVAL -2 MONTH)
      {% elsif ga_sessions.period._parameter_value contains "quarter" %}DATE_ADD(CURRENT_DATE(), INTERVAL -2 QUARTER)
      {% elsif ga_sessions.period._parameter_value contains "year" %}DATE_ADD(CURRENT_DATE(), INTERVAL -2 YEAR)
      {% endif %} ;;
  }
  dimension: date_period_dynamic_grain {
    hidden: yes
    type: date
    convert_tz: no
    group_label: "Event"
    label: "{% if ga_sessions.period._parameter_value contains 'year'
    # or ga_sessions.period._parameter_value contains '364 day' %}Month{% elsif ga_sessions.period._parameter_value contains 'quarter'
    #or ga_sessions.period._parameter_value contains '91 day' %}Week{% else %}Date{% endif %}"
    sql: {% if ga_sessions.period._parameter_value contains 'year'
        or ga_sessions.period._parameter_value contains '364 day' %}${date_month_date}
      {% elsif ga_sessions.period._parameter_value contains 'quarter'
        or ga_sessions.period._parameter_value contains '91 day' %}${date_week}
      {% else %} ${date_raw}
      {% endif %} ;;
    allow_fill: no
  }
  dimension: date_day_of_period {
    hidden: yes
    type: number
    label: "{% if ga_sessions.period._parameter_value contains 'day' %}Day of Period
    {% elsif ga_sessions.period._parameter_value contains 'week' %}Day of Week
    {% elsif ga_sessions.period._parameter_value contains 'month' %}Day of Month
    {% elsif ga_sessions.period._parameter_value contains 'quarter' %}Day of Quarter
    {% elsif ga_sessions.period._parameter_value contains 'year' %}Day of Year
    {% endif %}"
    group_label: "Event"
    sql: {% if ga_sessions.period._parameter_value contains "day" %}
        {% if ga_sessions.period._parameter_value == "'7 day'" %}${date_day_of_7_days_prior}
        {% elsif ga_sessions.period._parameter_value == "'28 day'" %}${date_day_of_28_days_prior}
        {% elsif ga_sessions.period._parameter_value == "'91 day'" %}${date_day_of_91_days_prior}
        {% elsif ga_sessions.period._parameter_value == "'364 day'" %}${date_day_of_364_days_prior}
        {% else %}0
        {% endif %}
      {% elsif ga_sessions.period._parameter_value contains "week" %}${date_day_of_week_index}
      {% elsif ga_sessions.period._parameter_value contains "month" %}${date_day_of_month}
      {% elsif ga_sessions.period._parameter_value contains "quarter" %}${date_day_of_quarter}
      {% elsif ga_sessions.period._parameter_value contains "year" %}${date_day_of_year}
      {% endif %} ;;
    # html: {{ value | plus: 1 }} - {{ date_date }};;
    # required_fields: [date_date]
    }
  dimension: date_last_period {
    group_label: "Event"
    label: "Prior Period"
    type: date
    convert_tz: no
    sql: DATE_ADD(${date_period}, INTERVAL -{% if ga_sessions.period._parameter_value == "'7 day'" %}7{% elsif ga_sessions.period._parameter_value == "'28 day'" %}28{% elsif ga_sessions.period._parameter_value == "'91 day'" %}91{% elsif ga_sessions.period._parameter_value == "'364 day'" %}364{% else %}1{% endif %} {% if ga_sessions.period._parameter_value contains "day" %}day{% elsif ga_sessions.period._parameter_value contains "week" %}week{% elsif ga_sessions.period._parameter_value contains "month" %}month{% elsif ga_sessions.period._parameter_value contains "quarter" %}quarter{% elsif ga_sessions.period._parameter_value contains "year" %}year{% endif %}) ;;
    allow_fill: no
  }
}

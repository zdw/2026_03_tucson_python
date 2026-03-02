#!/usr/bin/env python3

# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Zack Williams

import csv
import jinja2
import datetime

def jinja_env(template_dir):
    """
    Returns a Jinja2 enviroment loading files from template_dir
    """

    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(template_dir),
        autoescape=jinja2.select_autoescape(["html"]),
        undefined=jinja2.StrictUndefined,
        trim_blocks=True,
        lstrip_blocks=True,
    )

    def tsdatetime(value, fmt="%Y-%m-%d %H:%M:%S %Z"):
        dateval = datetime.datetime.fromtimestamp(
            int(value), tz=datetime.timezone.utc
        )
        return dateval.strftime(fmt)

    env.filters["tsdatetime"] = tsdatetime

    return env

def render_to_file(j2env, context, template_name, path):
    """
    Render out a template to file
    """

    template = j2env.get_template(template_name)

    with open(path, "w") as outfile:
        outfile.write(template.render(context))

if __name__ == "__main__":

    j2env = jinja_env("./templates")

    with open('logs.csv', newline='') as csvfile:

        # template generation time
        gen_t = datetime.datetime.now(datetime.timezone.utc)
        gen_str = gen_t.strftime("%Y-%m-%d %H:%M:%S %Z")

        # read the CSV as a dictionary
        csv_dict = csv.DictReader(csvfile)

        context = {
          "gen_time": gen_str,
          "log_headers": csv_dict.fieldnames,
          "log_rows": list(csv_dict),
        }

        render_to_file(j2env, context, "log1.html.jinja", "log1.html")
        render_to_file(j2env, context, "log2.html.jinja", "log2.html")
        render_to_file(j2env, context, "log3.html.jinja", "log3.html")

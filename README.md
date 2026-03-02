# March 2026 Tucson Python: Jinja & Ansible Tutorial

In this tutorial, you'll learn about practical ways templating is used in the
Python ecosystem, with an eye to how it's used for system configuration.

## Requirements

To run this tutorial make sure that you have the following tools installed:

- Python 3 (tested with 3.13)
- Docker

Then run `make prep` in the root.

This will create a virtualenv in `venv_tutorial` and build the docker container
used for testing with Ansible Molecule.

## Why Templating?

Templating helps you inject data into files that have an arbitrary format. This
allows you to easily create:

- A document format, like Markdown or HTML

- A configuration file

- Any text formats that don't easily map to a python data structure.

- Partial portions of any of these, that could be combined.

[Template processors](https://en.wikipedia.org/wiki/Template_processor) perform
this combining data and a template into output documents. See also the
wikipedia [list of templating
engines](https://en.wikipedia.org/wiki/Comparison_of_web_template_engines).

Some advantages:

- Encourages better separation of code from presentation logic. Larger teams
  could divide work between developers (writing code) and designers (making
  templates).

- You can easily make multiple templates with the same input data, which can
  look wildly different.

## Where shouldn't you use templating?

Templating isn't a good solution is if there's an existing serialization
between native data structures and the format.  For example, JSON and YAML
formats already have library or package functions like `.load()` and `.dump()`
that will convert those formats to and from a Python dictionary, and they have
roughly a 1:1 alignment.

> Note: A cautionary example of how not to do things is the Helm tool used with
> K8s, which uses Go templating inside of YAML which can be a challenge to
> debug.

## Jinja and Templating

[Jinja](https://jinja.palletsprojects.com/en/stable/) is a popular python
package for creating templates.

> Etymology Note: Jinja (神社 in kanji) is Japanese for "Shinto shrine".

Jinja operates by adding template tags, which use curly quotes - the most
common kinds are:

- Return a variable: `{{ variable }}`

- Control structures: `{% if variable == "something" %} only shown if true
  {% endif %}`

Also, various additional characters such as `-` are used for whitespace control
- you may want to put that `{% end %}` on it's own line but not create an empty
line, which can be done with `{%- end -%}`

> Note: The PyPI package name is [Jinja2](https://pypi.org/project/Jinja2/),
> separate from the original Jinja, even though the current version is 3.x.

Much more information about how to create templates can be found in the
[Template Designer
Documentation](https://jinja.palletsprojects.com/en/stable/templates/).

### What should I name my templates?

Typically jinja templates have an additional `.jinja` (or historically `.j2`)
extension added, which is removed when they are rendered.

Some implementations don't add this extension, which can cause problems with
linters that match on file extension but aren't expecting the template tags.

> Tip: If you like editor highlighting of a language but you're editing a
> template file that ends in `.jinja`, instruct the the editor to highlight
> with a different file format.  In Vim this is done with the `set
> filetype=html` (replacing `html` with your desired language) using command
> mode.

### An example of using and extending Jinja
Let's say you have a list of log output, and you want to make a web page that
makes them easier to display for human interpretation

Each line has a timestamp in unix seconds since epoch, a log level (INFO,
ERROR, WARN), and a text message.

In the output, you want the time to be displayed in a human format, the lines
to have colors relative to their level, and then the message.

There's a script that will perform these actions - to run it, source the
virtualenv  (`source venv_tutorial/bin/activate`) then go into the `jinja/`
directory and run:

   python log_render.py

And look at the HTML output int he same directory

There are 3 templates in `jinja/templates` that are used to convert the data to
HTML. They each generate a different format, and share a common HTML wrapper:

1. This generates a list of the log data
2. This generates a table of the same data, with a header
3. This filters the table for only some of the data

Note that the Python code has no changes in the data format, but the output
is changed.

## Copier

[Copier](https://copier.readthedocs.io/en/stable/) is a "scaffolding" tool that
allows you to use templating to create structured file and directory
structures, and update them after the fact.

> Note: [Copier has a comparison
> page](https://copier.readthedocs.io/en/stable/) with other similar tools.

In this tutorial, we'll used a Copier template to make an Ansible Role. The
role template is found the `copier/` directory, but see the section below
about making a role to use it.

## Ansible

[Ansible](https://docs.ansible.com/projects/ansible/latest/getting_started/introduction.html)
is a tool to automate system configuration of servers, network devices, and
basically anything with a CLI. It is written in Python.

> Etymology Note: The term "ansible" is from an Ursula K. Le Guin novel, where
> it's a Faster-than-Light (FTL) communications device. Ansible the software
> tool is not nearly this fast.

Traditionally, a System Administrator would manually perform configuration
actions - installing the OS, changing configuration files, installing
additional software, and performing maintenance tasks.

As the number of systems grew, and there was a desire to move to a more DevOps
style of work, manually performing tasks ceased to be viable - it wasn't
repeatable as frequently people wouldn't perform steps the same way every time.
Early on, sysadmins would write shell scripts or scripting language automation
that did this sort of configuration, but those were difficult to maintain, and
frequently were quite complex and hard to test.

Ansible provides a structured way of performing these actions, with the
following design philosophy:

- Idempotency - A set of tasks can be re-run multiple times without changing
  anything.

- SSH - Ansible's remote control is over SSH, so it can work with nearly any
  system you have SSH access to. No agent or setup is required, other than
  Python needs to be installed on the target system.

- Imperative - Relies on the user to define the steps to be taken. This can be
  contrasted with declarative systems such as Terraform, which have a different
  mode of operation and set of tradeoffs.

- Linting and testability - Ansible's ecosystem has tooling for linting and to
  test against a variety of containerized or and VM environments, before running
  on a production environment.

### Ansible Concepts

A [full list of
concepts](https://docs.ansible.com/projects/ansible/latest/getting_started/basic_concepts.html)
can be found in the documentation, but the one's we'll be looking at are these:

- Tasks: A specific action. Originally these were bare words like `template,
  but are now namespaced with the form: `ansible.builtin.template`.  Task
  namespaces come from a specific
  [Collection](https://docs.ansible.com/projects/ansible/latest/collections/index.html).

- Roles: A reusable set of ansible tasks and configuration.

- Playbook: A file that describes which plays to run.

- Play: Executing a set of Roles and Tasks given in a Playbook.

In this tutorial, we'll be creating a new Role that deploys a Python web
application behind a [nginx](https://nginx.org) reverse proxy - this is a
typical configuration when TLS termination is required.

### Creating a role with Copier

Run copier with:

    copier copy copier ansible/roles/

(the 3rd argument is the source copier template directory, the 4th is the
destination directory)

Copier will ask you questions - enter the following:

    🎤 What is the Ansible role name?
       deploy
    🎤 What OS families should be supported by this role?
       [Debian]
    🎤 What license does this role use?
       MIT
    🎤 What is your name (for license attribution)?
       Your Name Here
    🎤 What year for the license?
       2026

Then look at the directory structure created in `ansible/roles/deploy` - it
should fairly closely match the [role directory
structure](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_reuse_roles.html#role-directory-structure).

### Testing an Ansible role with Molecule

Molecule is a testing framework for Ansible roles.  It allows you to test a
role by running it against a Docker container or VM.  Beyond checks for
functionality, it also verifies that tasks are idempotent. You can also write
functionality tests.

> NOTE: If you're testing generation of roles, don't do it in a folder that is
> `.gitignore` 'd or Molecule will break with a [cryptic error that looks like
> it can't open a file that
> exists](https://github.com/ansible/molecule/issues/4117).  I wasted about an
> hour with this.

Molecule needs to know where to find roles, as one role can include another -
this can be set via a environmental variable:

    cd ansible/roles
    export ANSIBLE_ROLES_PATH=$(pwd)

To see what a molecule test looks like, run:

    cd deploy
    molecule test

### Adding configuration to the Ansible role

In the `deploy` role, we're going to deploy the Flask app that Tim and Zack
created for the January meeting, which is found at
https://github.com/timcolson/workshop-1001

> NOTE: this is not production ready. You'd want gunicorn or some other WSGI
> runner instead of running Flask directly, and then a webserver like nginx for
> TLS termination or load balancing

The app will be installed with it's own user/group for isolation, and in a
specific directory - create some default values for this by adding to
`defaults/main.yml` - note later on in this section how these values are used
with Jinja templating:

    workshop_username: "workshop"
    workshop_groupname: "workshop"
    workshop_comment: "Workshop 1001"
    workshop_working_dir: "/opt/workshop"

An ansible best practice is to namespace software installations by OS type. Add
this to `tasks/Debian.yml`:

    - name: Install System Packages
      ansible.builtin.apt:
        name:
          - "git"
          - "python3"
          - "python3-pip"
          - "python3-venv"

    - name: Create systemd unit file for the service
      ansible.builtin.template:
        src: "{{ item }}.jinja"
        dest: "/etc/systemd/system/{{ item }}"
        owner: "root"
        group: "root"
        mode: "0644"
      with_items:
        - "workshop.service"
      notify:
        - "Start-workshop"

This uses a template of a systemd service unit file - create the `templates/`
directory, and in it make the file `workshop.service.jinja`, containing:

    [Unit]
    Description=Workshop-1001
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=simple

    User={{ workshop_username }}
    Group={{ workshop_groupname }}
    WorkingDirectory={{ workshop_working_dir }}

    ExecStart={{ workshop_working_dir }}/venv/bin/flask --app app.py run

    Restart=on-failure
    RestartSec=30
    PrivateTmp=true

    [Install]
    WantedBy=multi-user.target

Then create the main tasks that are run in `tasks/main.yml`

    - name: Include OS-specific vars
      ansible.builtin.include_vars: "{{ ansible_facts['os_family'] }}.yml"

    - name: Include OS-specific tasks
      ansible.builtin.include_tasks: "{{ ansible_facts['os_family'] }}.yml"

    - name: Create group for workshop
      ansible.builtin.group:
        name: "{{ workshop_groupname }}"

    - name: Create user for workshop
      ansible.builtin.user:
        name: "{{ workshop_username }}"
        group: "{{ workshop_groupname }}"
        comment: "{{ workshop_comment }}"
        shell: "/usr/sbin/nologin"
        system: true
        password_lock: true

    - name: Download the repo
      ansible.builtin.git:
        repo: "https://github.com/timcolson/workshop-1001"
        dest: "{{ workshop_working_dir }}"
      notify:
        - "Restart-workshop"

    - name: Create virtualenv
      ansible.builtin.pip:
        virtualenv: "{{ workshop_working_dir }}/venv"
        requirements: "{{ workshop_working_dir }}/requirements.txt"
        virtualenv_command: "python3 -m venv"
      notify:
        - "Restart-workshop"

As the service would need to be restarted on config change, create a few handlers:

    - name: Start-workshop
      ansible.builtin.service:
        name: "workshop"
        state: "started"
        enabled: true

    - name: Restart-workshop
      ansible.builtin.service:
        name: "workshop"
        state: "restarted"

Once this is complete, run `molecule converge` to see Ansible configure the
test container with your changes.

From the repo root, you can also run `make docker-exec` and then run `ps ax` to
see that the flask app is running.

### Adding functional verification with Molecule

Molecule supports verification of a role by adding tests to the
`molecule/default/verify.yml` file.

Edit this file and add:

    - name: Test that the app is running
      ansible.builtin.uri:
        url: http://127.0.0.1:5000/
        status_code: 200
        return_content: true
      register: webpage
      failed_when: "'Recipe Browser' not in webpage.content"

Then run `molecule verify` and see if the tests pass.

## Credits

I (Zack Williams) created the entire repo, except for the data in
`jinja/logs.csv` which I asked `Qwen3.5-27B-UD-Q4_K_XL.gguf` to create with this
prompt:

    Please generate a CSV file containing a set of generic log messages, with
    the following format: The first column is a unix timestamp between the
    years of 2024 and 2025, the second column is a text string either INFO,
    ERROR, WARN, the third column be a random log message of 3-10 words.

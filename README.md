# valkyrie

Transfer data between databases

## Installation

    gem install valkyrie

## Usage

    $ valkyrie mysql://localhost/myapp_development postgres://localhost/myapp_development
    Transferring 5 tables:
    delayed_jobs:   100% |=========================================| Time: 00:00:00
    messages:       100% |=========================================| Time: 00:00:00
    participants:   100% |=========================================| Time: 00:00:02
    schema_migrati: 100% |=========================================| Time: 00:00:00
    settings:       100% |=========================================| Time: 00:00:00

## Character encoding issues

If you have character encoding issues -- for example, with an old MySQL database, and you're fine with ignoring old invalid characters, try this:

1. Use the mysql2 gem (use the connection string mysql2://localhost...); the mysql gem seems to have character encoding issues
2. Add the encoding option to force-encode all strings to a particular encoding. This will ignore invalid or unknown characters.

        $ valkyrie mysql2://localhost/myapp_development postgres://localhost/myapp_development UTF-8


## License

    MIT
